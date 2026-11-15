import 'package:flutter/material.dart';

class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1; // Województwo / Region
  final String? admin2; // Powiat / County
  final String? admin3; // Gmina / Municipality

  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
    this.admin2,
    this.admin3,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'] as String? ?? 'Nieznane',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
      admin2: json['admin2'] as String?,
      admin3: json['admin3'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'admin1': admin1,
      'admin2': admin2,
      'admin3': admin3,
    };
  }

  String get regionSubtitle {
    final parts = <String>[];
    if (admin3 != null && admin3!.isNotEmpty && admin3 != name) {
      parts.add(admin3!);
    }
    if (admin2 != null && admin2!.isNotEmpty && admin2 != name) {
      parts.add(admin2!);
    }
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add('woj. $admin1');
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.isEmpty ? country : parts.join(', ');
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final double uvIndex;
  final int weatherCode;
  final bool isDay;
  final DateTime time;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.uvIndex,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  String get conditionText => getWeatherConditionText(weatherCode);
  IconData get conditionIcon => getWeatherIcon(weatherCode, isDay);
}

class AirQualityData {
  final int aqiScore; // 1-100 or US AQI
  final double pm2_5;
  final double pm10;
  final double no2;
  final double o3;
  final double co;

  const AirQualityData({
    required this.aqiScore,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.co,
  });

  String get statusLabel {
    if (aqiScore <= 20) return 'Bardzo Dobra';
    if (aqiScore <= 40) return 'Dobra';
    if (aqiScore <= 60) return 'Umiarkowana';
    if (aqiScore <= 80) return 'Zła';
    return 'Bardzo Zła';
  }

  Color get statusColor {
    if (aqiScore <= 20) return Colors.greenAccent;
    if (aqiScore <= 40) return Colors.lightGreen;
    if (aqiScore <= 60) return Colors.amberAccent;
    if (aqiScore <= 80) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get healthRecommendation {
    if (aqiScore <= 20) return 'Świetne warunki! Czyste powietrze sprzyja aktywności na zewnątrz.';
    if (aqiScore <= 40) return 'Jakość powietrza jest dobra. Możesz bezpiecznie przebywać na zewnątrz.';
    if (aqiScore <= 60) return 'Jakość umiarkowana. Osoby wrażliwe powinny ograniczyć długi wysiłek.';
    if (aqiScore <= 80) return 'Jakość złe! Unikaj dłuższego przebywania na zewnątrz bez maseczki.';
    return 'Bardzo zła jakość powietrza! Zalecane pozostanie w domu przy zamkniętych okach.';
  }
}

class HourlyForecast {
  final DateTime time;
  final double temp;
  final int weatherCode;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.weatherCode,
    required this.isDay,
  });

  IconData get icon => getWeatherIcon(weatherCode, isDay);
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.weatherCode,
  });

  IconData get icon => getWeatherIcon(weatherCode, true);
}

// Helpers for WMO Weather Codes
String getWeatherConditionText(int code) {
  switch (code) {
    case 0:
      return 'Bezchmurnie';
    case 1:
      return 'Przeważnie słonecznie';
    case 2:
      return 'Częściowe zachmurzenie';
    case 3:
      return 'Zachmurzenie całkowite';
    case 45:
    case 48:
      return 'Mgła';
    case 51:
    case 53:
    case 55:
      return 'Lekka mżawka';
    case 61:
    case 63:
      return 'Umiarkowany deszcz';
    case 65:
      return 'Ulewny deszcz';
    case 71:
    case 73:
    case 75:
      return 'Opady śniegu';
    case 77:
      return 'Ziarna śnieżne';
    case 80:
    case 81:
    case 82:
      return 'Przejściowe opady';
    case 85:
    case 86:
      return 'Zamieć śnieżna';
    case 95:
    case 96:
    case 99:
      return 'Burza z piorunami';
    default:
      return 'Umiarkowanie';
  }
}

IconData getWeatherIcon(int code, bool isDay) {
  switch (code) {
    case 0:
    case 1:
      return isDay ? Icons.wb_sunny : Icons.nights_stay;
    case 2:
      return isDay ? Icons.wb_cloudy : Icons.cloud_queue;
    case 3:
      return Icons.cloud;
    case 45:
    case 48:
      return Icons.cloud_sync;
    case 51:
    case 53:
    case 55:
    case 61:
    case 63:
    case 65:
    case 80:
    case 81:
    case 82:
      return Icons.water_drop;
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return Icons.ac_unit;
    case 95:
    case 96:
    case 99:
      return Icons.thunderstorm;
    default:
      return isDay ? Icons.wb_sunny : Icons.nights_stay;
  }
}
