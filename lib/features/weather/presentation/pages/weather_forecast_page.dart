import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/weather_forecast_remote_datasource.dart';
import '../../data/models/weather_forecast_model.dart';
import '../../data/repositories/weather_forecast_repository_impl.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import 'dart:convert';

class WeatherForecastPage extends StatefulWidget {
  final String city;

  const WeatherForecastPage({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherForecastPage> createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> with SingleTickerProviderStateMixin {
  late WeatherForecastRepositoryImpl repo;
  List<WeatherForecastModel> forecastList = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isCelsius = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    repo = WeatherForecastRepositoryImpl(
      WeatherForecastRemoteDataSource(http.Client(), 'b0ee8bb4ad5a2fc82fcf925a0ac3d3fb'),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _getForecast();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getForecast() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final cityName = widget.city.split(',').first.trim();
      // Gọi API dự báo (giả định kiểu OpenWeatherMap /forecast)
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=b0ee8bb4ad5a2fc82fcf925a0ac3d3fb&units=metric&lang=vi'),
        headers: {'User-Agent': 'weather-forecast-page'}
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Lấy timezoneOffset từ city
        final timezoneOffset = data['city']?['timezone'] ?? 0;
        final listJson = data['list'] as List;
        forecastList = listJson
          .map((item) => WeatherForecastModel.fromJson(item, timezoneOffset))
          .toList();
        _animationController.forward(from: 0.0);
      } else {
        throw Exception('Không lấy được dữ liệu forecast');
      }
    } catch (e) {
      errorMessage = 'Không thể tải dự báo';
      forecastList = [];
    }
    setState(() { isLoading = false; });
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sun')) return Icons.wb_sunny;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain')) return Icons.water_drop;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('thunder')) return Icons.flash_on;
    return Icons.wb_cloudy;
  }

  String _getDayName(int weekday) {
    const days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return days[weekday - 1];
  }

  Map<String, List<WeatherForecastModel>> _groupByDay() {
    Map<String, List<WeatherForecastModel>> grouped = {};
    for (var forecast in forecastList) {
      final dateKey = '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(forecast);
    }
    return grouped;
  }

  int _convertTemp(double tempC) {
    if (isCelsius) return tempC.round();
    return (tempC * 1.8 + 32).round();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF121A25) : const Color(0xFFF3F6FC);
    final gradTop = isDarkMode ? const Color(0xFF294166) : const Color(0xFF5EB1FF);
    final gradBot = isDarkMode ? const Color(0xFF171926) : const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dự báo ${widget.city.split(',').first}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.blue[900],
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isCelsius ? Icons.thermostat : Icons.thermostat_auto),
            tooltip: isCelsius ? 'Chuyển sang °F' : 'Chuyển sang °C',
            onPressed: () => setState(() => isCelsius = !isCelsius),
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
            tooltip: isDarkMode ? 'Chuyển sáng' : 'Chuyển tối',
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _getForecast,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [gradTop, gradBot],
          ),
        ),
        child: SafeArea(
          child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : errorMessage != null
                ? _buildErrorView()
                : _buildForecastContent(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Có lỗi xảy ra',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _getForecast,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastContent(bool isDark) {
    if (forecastList.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu dự báo',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final groupedForecasts = _groupByDay();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.calendar_month, color: Colors.white.withOpacity(0.93), size: 39),
                const SizedBox(height: 7),
                Text(
                  widget.city.split(',').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dự báo ${groupedForecasts.length} ngày',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHourlySection(),
          const SizedBox(height: 20),
          ...groupedForecasts.entries.map((entry) => _buildDayCard(entry.key, entry.value, isDark)),
        ],
      ),
    );
  }

  Widget _buildHourlySection() {
    final next24Hours = forecastList.take(8).toList();
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.19),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withOpacity(0.24), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'DỰ BÁO THEO GIỜ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 24),
          SizedBox(
            height: 94,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: next24Hours.length,
              itemBuilder: (context, i) {
                final item = next24Hours[i];
                final isNow = i == 0;
                return Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 9),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: isNow ? Colors.white.withOpacity(0.25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        isNow ? 'Bây giờ' : '${item.dateTime.hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          color: isNow ? Colors.white : Colors.white.withOpacity(0.93),
                          fontSize: 12.5,
                          fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${item.iconCode}@2x.png',
                        width: 32, height: 32,
                        errorBuilder: (ctx, err, stack) => Icon(_getWeatherIcon(item.description), color: Colors.white, size: 28),
                      ),
                      Text(
                        '${_convertTemp(item.temperature)}°${isCelsius ? 'C' : 'F'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String dateKey, List<WeatherForecastModel> dayForecasts, bool isDark) {
    final date = dayForecasts.first.dateTime;
    final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;
    final dayName = isToday ? 'Hôm nay' : _getDayName(date.weekday);

    final temps = dayForecasts.map((f) => f.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white.withOpacity(0.19), width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${dayForecasts.first.iconCode}@2x.png',
                    width: 28, height: 28,
                    errorBuilder: (ctx, err, stack) => Icon(_getWeatherIcon(dayForecasts.first.description),
                        color: Colors.white, size: 28
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_convertTemp(maxTemp)}°${isCelsius ? 'C' : 'F'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_convertTemp(minTemp)}°${isCelsius ? 'C' : 'F'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dayForecasts.length,
              itemBuilder: (context, i) {
                final forecast = dayForecasts[i];
                return Container(
                  width: 45,
                  margin: const EdgeInsets.only(right: 7),
                  child: Column(
                    children: [
                      Text(
                        '${forecast.dateTime.hour}h',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Image.network(
                        'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                        width: 17, height: 17,
                        errorBuilder: (ctx, err, stack) => Icon(_getWeatherIcon(forecast.description),
                            color: Colors.white70, size: 17
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_convertTemp(forecast.temperature)}°${isCelsius ? 'C' : 'F'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
