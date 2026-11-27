class WeatherData {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final double uvIndex;
  final double pressure;
  final double visibility;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? airQuality;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.pressure,
    required this.visibility,
    this.sunrise,
    this.sunset,
    this.airQuality,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final currentTime = DateTime.parse(current['time'] as String);

    final hourlyTimes = (hourly['time'] as List)
        .map((value) => DateTime.parse(value as String))
        .toList();

    final temperatures = hourly['temperature_2m'] as List;
    final weatherCodes = hourly['weather_code'] as List;
    final uvValues = hourly['uv_index'] as List;
    final visibilityValues = hourly['visibility'] as List;

    // Localiza o horário mais próximo do horário atual.
    int closestIndex = 0;
    int smallestDifference = 999999999;

    for (int i = 0; i < hourlyTimes.length; i++) {
      final difference = hourlyTimes[i].difference(currentTime).inMinutes.abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        closestIndex = i;
      }
    }

    double getHourlyValue(List values) {
      if (values.isEmpty || closestIndex >= values.length) {
        return 0;
      }

      final value = values[closestIndex];
      return value is num ? value.toDouble() : 0;
    }

    final hourlyForecast = <HourlyForecast>[];

    // Monta a previsão horária.
    for (int i = 0; i < hourlyTimes.length; i++) {
      hourlyForecast.add(
        HourlyForecast(
          time: hourlyTimes[i],
          temperature: (temperatures[i] as num).toDouble(),
          condition: getWeatherCondition(
            (weatherCodes[i] as num).toInt(),
          ),
        ),
      );
    }

    final dailyTimes = daily['time'] as List;
    final maxTemperatures = daily['temperature_2m_max'] as List;
    final minTemperatures = daily['temperature_2m_min'] as List;
    final dailyCodes = daily['weather_code'] as List;

    final dailyForecast = <DailyForecast>[];

    // Monta a previsão diária.
    for (int i = 0; i < dailyTimes.length; i++) {
      dailyForecast.add(
        DailyForecast(
          date: DateTime.parse(dailyTimes[i] as String),
          temperature: (maxTemperatures[i] as num).toDouble(),
          minTemperature: (minTemperatures[i] as num).toDouble(),
          condition: getWeatherCondition(
            (dailyCodes[i] as num).toInt(),
          ),
        ),
      );
    }

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      condition: getWeatherCondition(
        (current['weather_code'] as num).toInt(),
      ),
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      uvIndex: getHourlyValue(uvValues),
      pressure: (current['pressure_msl'] as num).toDouble(),
      visibility: getHourlyValue(visibilityValues),
      sunrise: daily['sunrise'] != null &&
              (daily['sunrise'] as List).isNotEmpty
          ? DateTime.parse((daily['sunrise'] as List).first as String)
          : null,
      sunset: daily['sunset'] != null &&
              (daily['sunset'] as List).isNotEmpty
          ? DateTime.parse((daily['sunset'] as List).first as String)
          : null,
      airQuality: null,
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }

  static String getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Céu Limpo';
      case 1:
        return 'Predominantemente Limpo';
      case 2:
        return 'Parcialmente Nublado';
      case 3:
        return 'Encoberto';
      case 45:
      case 48:
        return 'Nevoeiro';
      case 51:
      case 53:
      case 55:
        return 'Garoa';
      case 56:
      case 57:
        return 'Garoa Congelante';
      case 61:
      case 63:
      case 65:
        return 'Chuva';
      case 66:
      case 67:
        return 'Chuva Congelante';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Neve';
      case 80:
      case 81:
      case 82:
        return 'Pancadas de Chuva';
      case 85:
      case 86:
        return 'Pancadas de Neve';
      case 95:
        return 'Trovoada';
      case 96:
      case 99:
        return 'Trovoada com Granizo';
      default:
        return 'Condição Desconhecida';
    }
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final double temperature;
  final double minTemperature;
  final String condition;

  DailyForecast({
    required this.date,
    required this.temperature,
    required this.minTemperature,
    required this.condition,
  });
}
