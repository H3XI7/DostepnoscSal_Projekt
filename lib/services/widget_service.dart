import 'package:home_widget/home_widget.dart';
import '../models/weather_model.dart';

class WidgetService {
  static Future<void> updateHomeWidget({
    required CityLocation city,
    required WeatherData weather,
    required AirQualityData aqi,
    required bool isFahrenheit,
  }) async {
    try {
      final tempVal = isFahrenheit ? (weather.temperature * 9 / 5) + 32 : weather.temperature;
      final unit = isFahrenheit ? '°F' : '°C';

      await HomeWidget.saveWidgetData('widget_city', city.name.toUpperCase());
      await HomeWidget.saveWidgetData('widget_temp', '${tempVal.round()}$unit');
      await HomeWidget.saveWidgetData('widget_condition', weather.conditionText);
      await HomeWidget.saveWidgetData('widget_aqi', 'AQI: ${aqi.statusLabel}');

      await HomeWidget.updateWidget(
        name: 'WeatherWidgetProvider',
        androidName: 'WeatherWidgetProvider',
      );
    } catch (_) {
      // Ignore if home widget not supported or in test environment
    }
  }
}
