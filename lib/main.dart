
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'services/weather_service.dart';
import 'models/weather_model.dart';
import 'theme.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  WeatherData? _weather;
String _cityName = 'Finding your location...';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _updateError('Location services are disabled.');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _updateError('Location permission denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _updateError(
          'Location permission permanently denied. '
          'Enable it in your device settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final service = WeatherService();

// Busca o nome da cidade.
try {
  final city = await service.fetchCityName(
    position.latitude,
    position.longitude,
  );

  if (mounted) {
    setState(() {
      _cityName = city;
    });
  }
} catch (e) {
  debugPrint('City lookup error: $e');

  if (mounted) {
    setState(() {
      _cityName = 'Location unavailable';
    });
  }
}

// Busca os dados meteorológicos.
await _fetchWeather(
  position.latitude,
  position.longitude,
);
    } catch (e) {
      _updateError('Error fetching location: $e');
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final service = WeatherService();

      final data = await service.fetchWeather(lat, lon);

      if (!mounted) return;

      setState(() {
        _weather = data;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error fetching weather data: $e';
        _isLoading = false;
      });
    }
  }

  void _updateError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Color _getBackground() {
    if (_weather == null) {
      return AppTheme.primaryColor;
    }

    switch (_weather!.condition) {
      case 'Rainy':
      case 'Rain Showers':
      case 'Thunderstorm':
        return const Color(0xFF263B50);

      case 'Snowy':
        return const Color(0xFF34495E);

      case 'Clear Sky':
      case 'Mainly Clear':
        return const Color(0xFF1A2A6C);

      default:
        return AppTheme.primaryColor;
    }
  }

  TextStyle _textStyle({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = _getBackground();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background,
              background.withOpacity(0.8),
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _errorMessage.isNotEmpty
                  ? _buildErrorUI()
                  : _buildWeatherUI(),
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white70,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _determinePosition,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherUI() {
    if (_weather == null) {
      return Center(
        child: Text(
          'No weather data available.',
          style: _textStyle(),
        ),
      );
    }

    final weather = _weather!;

    return RefreshIndicator(
      color: AppTheme.secondaryColor,
      onRefresh: _determinePosition,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(
      Icons.location_on,
      color: Colors.white70,
      size: 20,
    ),
    const SizedBox(width: 6),
    Flexible(
      child: Text(
        _cityName,
        textAlign: TextAlign.center,
        style: _textStyle(
          size: 17,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 76,
                weight: FontWeight.bold,
              ),
            ),

            Text(
              weather.condition,
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 23,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 35),

            // Informações meteorológicas
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _infoCard(
                  icon: Icons.water_drop,
                  title: 'Humidity',
                  value: '${weather.humidity.toStringAsFixed(0)}%',
                ),
                _infoCard(
                  icon: Icons.air,
                  title: 'Wind',
                  value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                ),
                _infoCard(
                  icon: Icons.wb_sunny,
                  title: 'UV Index',
                  value: weather.uvIndex.toStringAsFixed(1),
                ),
                _infoCard(
                  icon: Icons.speed,
                  title: 'Pressure',
                  value: '${weather.pressure.toStringAsFixed(0)} hPa',
                ),
                _infoCard(
                  icon: Icons.visibility,
                  title: 'Visibility',
                  value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Nascer e pôr do sol
            if (weather.sunrise != null && weather.sunset != null)
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sunInfo(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Sunrise',
                      time: weather.sunrise!,
                    ),
                    _sunInfo(
                      icon: Icons.nights_stay_outlined,
                      title: 'Sunset',
                      time: weather.sunset!,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            const Divider(color: Colors.white24),

            const SizedBox(height: 20),

            Text(
              'Hourly Forecast',
              style: _textStyle(
                size: 20,
                weight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weather.hourlyForecast.length < 24
                    ? weather.hourlyForecast.length
                    : 24,
                itemBuilder: (context, index) {
                  final forecast = weather.hourlyForecast[index];

                  return Container(
                    width: 95,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(forecast.time),
                          style: _textStyle(
                            size: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.cloud_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${forecast.temperature.toStringAsFixed(0)}°C',
                          style: _textStyle(
                            size: 16,
                            weight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          forecast.condition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _textStyle(
                            size: 10,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            Text(
              'Daily Forecast',
              style: _textStyle(
                size: 20,
                weight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...weather.dailyForecast.map(
              (forecast) => _dailyForecastCard(forecast),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: _determinePosition,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh weather'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return SizedBox(
      width: 145,
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 17,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunInfo({
    required IconData icon,
    required String title,
    required DateTime time,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 25,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: _textStyle(
            size: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: _textStyle(
            size: 18,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _dailyForecastCard(DailyForecast forecast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              DateFormat('EEE, MMM d').format(forecast.date),
              style: _textStyle(
                size: 13,
                weight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${forecast.temperature.toStringAsFixed(0)}° / '
              '${forecast.minTemperature.toStringAsFixed(0)}°',
              textAlign: TextAlign.center,
              style: _textStyle(
                size: 13,
                weight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              forecast.condition,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle(
                size: 11,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
