import 'package:flutter/material.dart';
import 'package:olly_app/auth/auth_service.dart';
import 'package:olly_app/model/weather_model.dart';
import 'package:olly_app/services/service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // services
  final _weatherServices = WeatherServices('74ae829b502fc5dbae3a402a0918b4f8');
  final _authService = AuthService();

  WeatherData? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  // fetch weather by city name
  Future<void> _fetchWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherServices.getWeatherByCity(cityName);

      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Unable to find weather for "$cityName".\nPlease try another city.';
        _isLoading = false;
      });
    }
  }

  // show city search dialog
  void _showCitySearch() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter city name...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context);
              _fetchWeatherByCity(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _fetchWeatherByCity(controller.text.trim());
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // fetch weather data from the api
  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherServices.getCurrentWeather();

      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  String _getFriendlyError(Object error) {
    final msg = error.toString();

    if (msg.contains('Location permissions are permanently denied')) {
      return 'Location access is disabled.\nPlease enable it in Settings.';
    }

    if (msg.contains('Location permissions are denied')) {
      return 'Location permission denied.\nPlease allow location access.';
    }

    if (msg.contains('Unable to get current location')) {
      return 'Cannot get your location.\nPlease check if location services are enabled.';
    }

    if (msg.contains('Failed to load weather data')) {
      return 'Unable to fetch weather data.\nPlease check your internet connection.';
    }

    return 'Something went wrong.\nPlease try again.';
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Widget _buildWeatherIcon(String condition, bool isNight) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (condition.toLowerCase()) {
      case 'clear':
        iconData = isNight ? Icons.nightlight_round : Icons.wb_sunny;
        iconColor = isNight ? Colors.blue.shade100 : Colors.yellow.shade300;
        break;
      case 'clouds':
        iconData = Icons.cloud;
        iconColor = Colors.white;
        break;
      case 'rain':
      case 'drizzle':
        iconData = Icons.grain;
        iconColor = Colors.blue.shade200;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm;
        iconColor = Colors.yellow.shade200;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        iconColor = Colors.blue.shade50;
        break;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
        iconData = Icons.foggy;
        iconColor = Colors.grey.shade300;
        break;
      default:
        iconData = isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined;
        iconColor = isNight ? Colors.blue.shade100 : Colors.yellow.shade300;
    }

    return Icon(
      iconData,
      size: 120,
      color: iconColor,
    );
  }

  // get gradient colors based on time of day
  List<Color> _getGradientColors(bool isNight) {
    if (isNight) {
      return [
        const Color(0xFF0f0c29),
        const Color(0xFF302b63),
        const Color(0xFF24243e),
      ];
    } else {
      return [
        Colors.blue.shade400,
        Colors.blue.shade600,
        Colors.blue.shade800,
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authService.getCurrentUserEmail();
    final isNight = _weather?.isNightTime ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Weather',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            if (isNight) ...[
              const SizedBox(width: 8),
              const Icon(Icons.nightlight_round,
                  color: Colors.white70, size: 20),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showCitySearch,
            tooltip: 'Search city',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchWeather,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getGradientColors(isNight),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Fetching weather data...',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _fetchWeather,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // User email
                            if (userEmail != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      userEmail,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 40),

                            // location icon
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),

                            // city name
                            Text(
                              _weather?.cityName ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // weather icon
                            _buildWeatherIcon(
                              _weather?.mainCondition ?? '',
                              isNight,
                            ),

                            const SizedBox(height: 20),

                            // temperature
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_weather?.temperature.round() ?? '--'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 80,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                const Text(
                                  '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // weather condition
                            Text(
                              _weather?.mainCondition ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 60),

                            // weather card with additional info
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.thermostat,
                                    'Temperature',
                                    '${_weather?.temperature.round() ?? '--'}°C',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.wb_sunny,
                                    'Condition',
                                    _weather?.mainCondition ?? 'Unknown',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.location_city,
                                    'Location',
                                    _weather?.cityName ?? 'Unknown',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
