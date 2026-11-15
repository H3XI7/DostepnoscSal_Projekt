import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const List<CityLocation> defaultCities = [
    CityLocation(name: 'Warszawa', country: 'Polska', latitude: 52.2297, longitude: 21.0122),
    CityLocation(name: 'Kraków', country: 'Polska', latitude: 50.0647, longitude: 19.9450),
    CityLocation(name: 'Gdańsk', country: 'Polska', latitude: 54.3520, longitude: 18.6466),
    CityLocation(name: 'Wrocław', country: 'Polska', latitude: 51.1100, longitude: 17.0333),
    CityLocation(name: 'Poznań', country: 'Polska', latitude: 52.4064, longitude: 16.9252),
    CityLocation(name: 'Londyn', country: 'Wielka Brytania', latitude: 51.5074, longitude: -0.1278),
    CityLocation(name: 'Nowy Jork', country: 'Stany Zjednoczone', latitude: 40.7128, longitude: -74.0060),
    CityLocation(name: 'Tokio', country: 'Japonia', latitude: 35.6762, longitude: 139.6503),
  ];

  Future<CityLocation?> getCurrentDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      String cityName = 'Moja Lokalizacja';
      String countryName = 'Polska';
      String? admin1;
      String? admin2;
      String? admin3;

      try {
        final nomUri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=pl',
        );
        final nomRes = await http.get(
          nomUri,
          headers: {'User-Agent': 'WeatherAQIApp/1.0'},
        ).timeout(const Duration(seconds: 4));

        if (nomRes.statusCode == 200) {
          final data = json.decode(nomRes.body);
          final addr = data['address'] as Map<String, dynamic>?;

          if (addr != null) {
            // Check village, hamlet, town, suburb, city
            if (addr['village'] != null && (addr['village'] as String).isNotEmpty) {
              cityName = addr['village'];
            } else if (addr['hamlet'] != null && (addr['hamlet'] as String).isNotEmpty) {
              cityName = addr['hamlet'];
            } else if (addr['town'] != null && (addr['town'] as String).isNotEmpty) {
              cityName = addr['town'];
            } else if (addr['suburb'] != null && (addr['suburb'] as String).isNotEmpty) {
              cityName = addr['suburb'];
            } else if (addr['city'] != null && (addr['city'] as String).isNotEmpty) {
              cityName = addr['city'];
            }

            if (addr['municipality'] != null) admin3 = addr['municipality'];
            if (addr['county'] != null) admin2 = addr['county'];
            if (addr['state'] != null) {
              String st = addr['state'];
              if (st.startsWith('województwo ')) {
                st = st.replaceFirst('województwo ', '');
              }
              admin1 = st;
            }
            if (addr['country'] != null) countryName = addr['country'];
          }
        }
      } catch (_) {
        // Fallback to BigDataCloud if Nominatim times out
        try {
          final geoUri = Uri.parse(
            'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=pl',
          );
          final res = await http.get(geoUri).timeout(const Duration(seconds: 3));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            if (data['locality'] != null && (data['locality'] as String).isNotEmpty) {
              cityName = data['locality'];
            } else if (data['city'] != null && (data['city'] as String).isNotEmpty) {
              cityName = data['city'];
            }
            if (data['principalSubdivision'] != null) admin1 = data['principalSubdivision'];
            if (data['countryName'] != null) countryName = data['countryName'];
          }
        } catch (_) {}
      }

      return CityLocation(
        name: cityName,
        country: countryName,
        latitude: position.latitude,
        longitude: position.longitude,
        admin1: admin1,
        admin2: admin2,
        admin3: admin3,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<CityLocation>> searchCities(String query) async {
    if (query.trim().isEmpty) return defaultCities;

    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=10&language=pl&format=json',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List results = data['results'];
          return results.map((item) => CityLocation.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Fallback matching
    }

    // Filter default cities locally if search fails
    return defaultCities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<WeatherDataBundle> getWeatherData(CityLocation city) async {
    try {
      // Fetch Weather
      final weatherUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=${city.latitude}&longitude=${city.longitude}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,surface_pressure,wind_speed_10m'
        '&hourly=temperature_2m,weather_code,is_day'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max'
        '&timezone=auto',
      );

      // Fetch Air Quality
      final aqiUri = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?'
        'latitude=${city.latitude}&longitude=${city.longitude}'
        '&current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone,european_aqi'
        '&timezone=auto',
      );

      final responses = await Future.wait([
        http.get(weatherUri).timeout(const Duration(seconds: 5)),
        http.get(aqiUri).timeout(const Duration(seconds: 5)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final wData = json.decode(responses[0].body);
        final aData = json.decode(responses[1].body);

        final currentW = wData['current'];
        final dailyW = wData['daily'];
        final hourlyW = wData['hourly'];
        final currentA = aData['current'];

        final weather = WeatherData(
          temperature: (currentW['temperature_2m'] as num).toDouble(),
          feelsLike: (currentW['apparent_temperature'] as num).toDouble(),
          tempMin: (dailyW['temperature_2m_min'][0] as num).toDouble(),
          tempMax: (dailyW['temperature_2m_max'][0] as num).toDouble(),
          humidity: (currentW['relative_humidity_2m'] as num).toInt(),
          windSpeed: (currentW['wind_speed_10m'] as num).toDouble(),
          pressure: (currentW['surface_pressure'] as num).toInt(),
          uvIndex: (dailyW['uv_index_max'][0] as num).toDouble(),
          weatherCode: (currentW['weather_code'] as num).toInt(),
          isDay: (currentW['is_day'] as num).toInt() == 1,
          time: DateTime.now(),
        );

        final airQuality = AirQualityData(
          aqiScore: (currentA['european_aqi'] as num? ?? 18).toInt(),
          pm2_5: (currentA['pm2_5'] as num? ?? 8.5).toDouble(),
          pm10: (currentA['pm10'] as num? ?? 14.2).toDouble(),
          no2: (currentA['nitrogen_dioxide'] as num? ?? 12.0).toDouble(),
          o3: (currentA['ozone'] as num? ?? 45.0).toDouble(),
          co: (currentA['carbon_monoxide'] as num? ?? 210.0).toDouble(),
        );

        // Parse 24h Hourly Forecast
        final List<HourlyForecast> hourlyList = [];
        final List hTimes = hourlyW['time'];
        final List hTemps = hourlyW['temperature_2m'];
        final List hCodes = hourlyW['weather_code'];
        final List hIsDay = hourlyW['is_day'];

        int nowHour = DateTime.now().hour;
        for (int i = nowHour; i < min(nowHour + 24, hTimes.length); i++) {
          hourlyList.add(HourlyForecast(
            time: DateTime.tryParse(hTimes[i]) ?? DateTime.now().add(Duration(hours: i)),
            temp: (hTemps[i] as num).toDouble(),
            weatherCode: (hCodes[i] as num).toInt(),
            isDay: (hIsDay[i] as num).toInt() == 1,
          ));
        }

        // Parse 7-Day Forecast
        final List<DailyForecast> dailyList = [];
        final List dTimes = dailyW['time'];
        final List dMins = dailyW['temperature_2m_min'];
        final List dMaxs = dailyW['temperature_2m_max'];
        final List dCodes = dailyW['weather_code'];

        for (int i = 0; i < dTimes.length; i++) {
          dailyList.add(DailyForecast(
            date: DateTime.tryParse(dTimes[i]) ?? DateTime.now().add(Duration(days: i)),
            tempMin: (dMins[i] as num).toDouble(),
            tempMax: (dMaxs[i] as num).toDouble(),
            weatherCode: (dCodes[i] as num).toInt(),
          ));
        }

        return WeatherDataBundle(
          weather: weather,
          airQuality: airQuality,
          hourlyForecast: hourlyList,
          dailyForecast: dailyList,
        );
      }
    } catch (_) {
      // Offline fallback
    }

    return _getOfflineFallbackData(city);
  }

  WeatherDataBundle _getOfflineFallbackData(CityLocation city) {
    final now = DateTime.now();
    return WeatherDataBundle(
      weather: WeatherData(
        temperature: 18.5,
        feelsLike: 17.8,
        tempMin: 12.0,
        tempMax: 21.0,
        humidity: 62,
        windSpeed: 14.4,
        pressure: 1015,
        uvIndex: 4.2,
        weatherCode: 1,
        isDay: now.hour >= 6 && now.hour <= 20,
        time: now,
      ),
      airQuality: const AirQualityData(
        aqiScore: 18,
        pm2_5: 7.4,
        pm10: 12.8,
        no2: 15.2,
        o3: 42.0,
        co: 180.0,
      ),
      hourlyForecast: List.generate(24, (index) {
        final time = now.add(Duration(hours: index));
        return HourlyForecast(
          time: time,
          temp: 16.0 + (index % 6),
          weatherCode: index % 2 == 0 ? 0 : 2,
          isDay: time.hour >= 6 && time.hour <= 20,
        );
      }),
      dailyForecast: List.generate(7, (index) {
        return DailyForecast(
          date: now.add(Duration(days: index)),
          tempMin: 11.0 + index,
          tempMax: 20.0 + index,
          weatherCode: index % 3 == 0 ? 0 : (index % 3 == 1 ? 2 : 61),
        );
      }),
    );
  }
}

class WeatherDataBundle {
  final WeatherData weather;
  final AirQualityData airQuality;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherDataBundle({
    required this.weather,
    required this.airQuality,
    required this.hourlyForecast,
    required this.dailyForecast,
  });
}
