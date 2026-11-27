import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl =
      'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,pressure_msl',
        'hourly':
            'temperature_2m,weather_code,uv_index,visibility',
        'daily':
            'temperature_2m_max,temperature_2m_min,weather_code,uv_index_max,sunrise,sunset',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('API Error ${response.statusCode}');
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WeatherData.fromJson(json);
    } catch (e) {
      throw Exception('Weather request failed: $e');
    }
  }

  Future<String> fetchCityName(double lat, double lon) async {
    final uri = Uri.https(
      'api.bigdatacloud.net',
      '/data/reverse-geocode-client',
      {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'localityLanguage': 'pt',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve city name.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final city = data['city']?.toString();
      final locality = data['locality']?.toString();
      final state = data['principalSubdivision']?.toString();

      final name = (city != null && city.isNotEmpty)
          ? city
          : (locality != null && locality.isNotEmpty)
              ? locality
              : null;

      if (name == null) {
        return state ?? 'Localização desconhecida';
      }

      if (state != null && state.isNotEmpty && state != name) {
        return '$name, $state';
      }

      return name;
    } catch (e) {
      return 'Localização atual';
    }
  }
}
