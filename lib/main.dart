
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'theme.dart';
import 'models/weather_model.dart';
import 'services/weather_service.dart';

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
  final WeatherService _weatherService = WeatherService();

  WeatherData? _weatherData;
  String? _cityName;
  String? _errorMessage;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Ative os serviços de localização do dispositivo.',
        );
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão bloqueada. Habilite a localização nas configurações do navegador ou dispositivo.',
        );
      }

      final position = await Geolocator.getCurrentPosition();

      final results = await Future.wait([
        _weatherService.fetchCityName(
          position.latitude,
          position.longitude,
        ),
        _weatherService.fetchWeather(
          position.latitude,
          position.longitude,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _cityName = results[0] as String;
        _weatherData = results[1] as WeatherData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_weatherData == null) {
      return _buildEmpty();
    }

    return _buildDashboard(_weatherData!);
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Buscando informações meteorológicas...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_rounded,
                size: 48,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 18),
              const Text(
                'Não foi possível carregar o clima',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Ocorreu um erro inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchWeatherData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('Dados meteorológicos indisponíveis.'),
    );
  }

  Widget _buildDashboard(WeatherData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 600 ? 18 : 32,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildCurrentWeather(data),
                              const SizedBox(height: 20),
                              _buildHourlyForecast(data),
                            ],
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildWeatherMetrics(data),
                              const SizedBox(height: 20),
                              _buildSunCard(data),
                              const SizedBox(height: 20),
                              _buildDailyForecast(data),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCurrentWeather(data),
                        const SizedBox(height: 20),
                        _buildWeatherMetrics(data),
                        const SizedBox(height: 20),
                        _buildHourlyForecast(data),
                        const SizedBox(height: 20),
                        _buildSunCard(data),
                        const SizedBox(height: 20),
                        _buildDailyForecast(data),
                      ],
                    ),

                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Dados meteorológicos fornecidos pela Open-Meteo',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.cloud_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SkyCast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${_cityName ?? 'Localização atual'} • ${DateFormat('dd/MM/yyyy').format(now)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Atualizar clima',
          onPressed: _fetchWeatherData,
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTheme.secondaryColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(WeatherData data) {
    return GlassCard(
      padding: const EdgeInsets.all(26),
      radius: 28,
      color: const Color(0x302E6BA5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLIMA ATUAL',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 76,
                        fontWeight: FontWeight.w300,
                        height: 1,
                        letterSpacing: -4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.condition,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Temperatura atual',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _weatherIcon(data.condition),
                size: 88,
                color: _weatherColor(data.condition),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: AppTheme.glassBorder,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetrics(WeatherData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Condições meteorológicas',
          subtitle: 'Detalhes do clima atual',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.water_drop_rounded,
                    title: 'Umidade',
                    value: '${data.humidity}%',
                    color: const Color(0xFF69BDEB),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.air_rounded,
                    title: 'Vento',
                    value: '${data.windSpeed} km/h',
                    color: const Color(0xFF9CCCF4),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.wb_sunny_rounded,
                    title: 'Índice UV',
                    value: '${data.uvIndex}',
                    color: AppTheme.sunnyColor,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.speed_rounded,
                    title: 'Pressão',
                    value: '${data.pressure} hPa',
                    color: AppTheme.cloudyColor,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.visibility_rounded,
                    title: 'Visibilidade',
                    value: _formatVisibility(data.visibility),
                    color: AppTheme.secondaryColor,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    icon: Icons.air_rounded,
                    title: 'Qualidade do ar',
                    value: data.airQuality?.toString() ?? 'N/D',
                    color: const Color(0xFF8DD8B2),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(WeatherData data) {
    final forecasts = data.hourlyForecast.take(24).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Previsão por hora',
            subtitle: 'Próximas 24 horas',
          ),
          const SizedBox(height: 20),
          if (forecasts.isEmpty)
            const Text(
              'Previsão horária indisponível.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: forecasts.map((forecast) {
                  return Container(
                    width: 76,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(forecast.time),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Icon(
                          _weatherIcon(forecast.condition),
                          color: _weatherColor(forecast.condition),
                          size: 25,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${forecast.temperature.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSunCard(WeatherData data) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Sol',
            subtitle: 'Nascer e pôr do sol',
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SunInfo(
                  icon: Icons.wb_twilight_rounded,
                  title: 'Nascer do sol',
                  time: _formatTime(data.sunrise),
                  color: AppTheme.sunnyColor,
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: AppTheme.glassBorder,
              ),
              Expanded(
                child: _SunInfo(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Pôr do sol',
                  time: _formatTime(data.sunset),
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(WeatherData data) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Previsão de 7 dias',
            subtitle: 'Temperaturas máximas e mínimas',
          ),
          const SizedBox(height: 14),
          if (data.dailyForecast.isEmpty)
            const Text(
              'Previsão diária indisponível.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            ...data.dailyForecast.map((forecast) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 55,
                      child: Text(
                        DateFormat('EEE', 'en_US')
                            .format(forecast.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _weatherIcon(forecast.condition),
                      color: _weatherColor(forecast.condition),
                      size: 23,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        forecast.condition,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${forecast.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${forecast.minTemperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    final text = condition.toLowerCase();

    if (text.contains('thunder') || text.contains('trovoada')) {
      return Icons.thunderstorm_rounded;
    }

    if (text.contains('rain') ||
        text.contains('chuva') ||
        text.contains('drizzle')) {
      return Icons.cloudy_snowing;
    }

    if (text.contains('snow') || text.contains('neve')) {
      return Icons.ac_unit_rounded;
    }

    if (text.contains('cloud') ||
        text.contains('nublado') ||
        text.contains('overcast')) {
      return Icons.cloud_rounded;
    }

    if (text.contains('fog') || text.contains('neblina')) {
      return Icons.foggy;
    }

    if (text.contains('partly') ||
        text.contains('parcial')) {
      return Icons.cloudy_snowing;
    }

    return Icons.wb_sunny_rounded;
  }

  Color _weatherColor(String condition) {
    final text = condition.toLowerCase();

    if (text.contains('rain') ||
        text.contains('chuva') ||
        text.contains('thunder')) {
      return AppTheme.rainyColor;
    }

    if (text.contains('cloud') || text.contains('nublado')) {
      return AppTheme.cloudyColor;
    }

    return AppTheme.sunnyColor;
  }

  String _formatTime(Object? value) {
    if (value == null) return '--:--';

    final date = DateTime.tryParse(value.toString());

    if (date != null) {
      return DateFormat('HH:mm').format(date);
    }

    final text = value.toString();

    if (text.length >= 16) {
      return text.substring(11, 16);
    }

    return text;
  }

  String _formatVisibility(Object? value) {
    if (value == null) return 'N/D';

    final number = double.tryParse(value.toString());

    if (number == null) return value.toString();

    // Open-Meteo retorna visibilidade em metros.
    return '${(number / 1000).toStringAsFixed(1)} km';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color color;

  const _SunInfo({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
