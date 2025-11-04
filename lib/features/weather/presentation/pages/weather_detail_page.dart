import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/app_locator.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/usecases/get_hourly_forecast.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherDetailPage extends StatefulWidget {
  final String city;
  final double lat;
  final double lon;
  final DateTime day;
  const WeatherDetailPage({
    Key? key,
    required this.city,
    required this.lat,
    required this.lon,
    required this.day,
  }) : super(key: key);

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  List<Forecast> hourlyForecast = [];
  bool loading = true;
  bool darkMode = false;
  bool showFahrenheit = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    setState(() => loading = true);
    final repo = sl<WeatherRepository>();
    hourlyForecast = await GetHourlyForecast(
      repo,
    ).callByLatLon(widget.lat, widget.lon, widget.day);
    setState(() => loading = false);
  }

  String temp(double c) =>
      showFahrenheit ? "${(c * 9 / 5 + 32).round()}°F" : "${c.round()}°C";

  IconData getWeatherIcon(String? description) {
    final keyword = (description ?? '').toLowerCase();
    if (keyword.contains("rain")) return Icons.grain;
    if (keyword.contains("clear")) return Icons.wb_sunny;
    if (keyword.contains("cloud")) return Icons.cloud;
    if (keyword.contains("storm") || keyword.contains("thunder"))
      return Icons.flash_on;
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: darkMode
          ? [const Color(0xFF334155), const Color(0xFF111827)]
          : [const Color(0xFF6EC6F4), const Color(0xFF2983E2)],
    );

    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xFF111827)
          : const Color(0xFF6EC6F4),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Dự báo ${widget.city}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Quản lý thành phố yêu thích",
          color: darkMode ? Colors.white : Colors.black,
          onPressed: () {
            // Sử dụng GoRouter để điều hướng đến trang favorites
            context.go('/favorites'); // hoặc context.go(AppRoutes.favorites)
          }, // context.go('/favorites') nếu dùng go_router
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới dữ liệu thời tiết",
            color: darkMode ? Colors.white : Colors.black,
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6_rounded),
            tooltip: "Bật/tắt Dark Mode",
            color: darkMode ? Colors.yellow : Colors.grey,
            onPressed: () => setState(() => darkMode = !darkMode),
          ),
          IconButton(
            icon: Icon(
              showFahrenheit ? Icons.thermostat_auto : Icons.thermostat,
              color: showFahrenheit
                  ? Colors.red
                  : (darkMode ? Colors.white : Colors.black),
            ),
            tooltip: "Đổi đơn vị °C/°F",
            onPressed: () => setState(() => showFahrenheit = !showFahrenheit),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              decoration: BoxDecoration(gradient: gradient),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 70, 14, 22),
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.city,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Dự báo 6 ngày",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CARD DỰ BÁO THEO GIỜ
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DỰ BÁO THEO GIỜ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourlyForecast.length > 7
                                ? 7
                                : hourlyForecast.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final f = hourlyForecast[i];
                              final isNow = i == 0;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isNow
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isNow
                                          ? "Bây giờ"
                                          : "${f.dateTime.hour.toString().padLeft(2, '0')}:00",
                                      style: TextStyle(
                                        color: isNow
                                            ? Color(0xFF1B61F5)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Icon(
                                    getWeatherIcon(f.description),
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    temp(f.temperature),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isNow
                                          ? Color(0xFF1B61F5)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(6, (idx) {
                    final now = DateTime.now().add(Duration(days: idx));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    idx == 0
                                        ? "Hôm nay"
                                        : "Thứ ${now.weekday + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${now.day}/${now.month}/${now.year}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.cloud,
                                  color: Colors.white,
                                  size: 33,
                                ),
                                Text(
                                  temp(20 + idx.toDouble()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 19,
                                  ),
                                ),
                                Text(
                                  temp(17 + idx.toDouble()),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
