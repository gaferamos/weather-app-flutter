
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'services/weather_service.dart';
import 'models/weather_model.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
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

  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Obtém a localização do dispositivo
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _updateError("Location services are disabled.");
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _updateError("Location permission denied.");
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _updateError(
          "Location permission permanently denied. "
          "Enable it in your device settings.",
        );
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition();

      await _fetchWeather(
        position.latitude,
        position.longitude,
      );
    } catch (e, stackTrace) {
      debugPrint("LOCATION ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");

      _updateError("Error fetching location: $e");
    }
  }

  // Busca os dados meteorológicos
  Future<void> _fetchWeather(double lat, double lon) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      debugPrint("Latitude: $lat");
      debugPrint("Longitude: $lon");

      final service = WeatherService();

      final data = await service.fetchWeather(lat, lon);

      if (!mounted) return;

      setState(() {
        _weather = data;
        _isLoading = false;
        _errorMessage = "";
      });

      debugPrint("Weather successfully loaded!");
    } catch (e, stackTrace) {
      debugPrint("WEATHER ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");

      if (!mounted) return;

      setState(() {
        _errorMessage = "Error fetching weather data: $e";
        _isLoading = false;
      });
    }
  }

  // Atualiza mensagens de erro
  void _updateError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorUI()
                    : _buildWeatherUI(),
          ),
        ),
      ),
    );
  }

  // Interface de erro
  Widget _buildErrorUI() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white70,
            size: 55,
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: _determinePosition,
            icon: const Icon(Icons.refresh),
            label: const Text("Try again"),
          ),
        ],
      ),
    );
  }

  // Interface principal do clima
  Widget _buildWeatherUI() {
    if (_weather == null) {
      return const Center(
        child: Text(
          "No weather data available.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "${_weather!.temperature.toStringAsFixed(1)}°C",
            style: GoogleFonts.poppins(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Text(
            _weather!.condition,
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoCard(
                "Humidity",
                "${_weather!.humidity.toStringAsFixed(0)}%",
              ),

              const SizedBox(width: 20),

              _infoCard(
                "Wind",
                "${_weather!.windSpeed.toStringAsFixed(1)} km/h",
              ),
            ],
          ),

          const SizedBox(height: 35),

          ElevatedButton.icon(
            onPressed: _determinePosition,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh weather"),
          ),
        ],
      ),
    );
  }

  // Cards de informações meteorológicas
  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
