
class WeatherData {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];

    if (current == null) {
      throw Exception('The API did not return current weather data.');
    }

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      condition: _getWeatherCondition(
        current['weather_code'] as int,
      ),
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
    );
  }

  static String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';

      case 1:
        return 'Mainly Clear';

      case 2:
        return 'Partly Cloudy';

      case 3:
        return 'Overcast';

      case 45:
      case 48:
        return 'Foggy';

      case 51:
      case 53:
      case 55:
        return 'Drizzle';

      case 56:
      case 57:
        return 'Freezing Drizzle';

      case 61:
      case 63:
      case 65:
        return 'Rainy';

      case 66:
      case 67:
        return 'Freezing Rain';

      case 71:
      case 73:
      case 75:
      case 77:
        return 'Snowy';

      case 80:
      case 81:
      case 82:
        return 'Rain Showers';

      case 85:
      case 86:
        return 'Snow Showers';

      case 95:
        return 'Thunderstorm';

      case 96:
      case 99:
        return 'Thunderstorm with Hail';

      default:
        return 'Unknown Weather';
    }
  }
}
