import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/app_locator.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/usecases/get_hourly_forecast.dart';
import '../../domain/usecases/get_daily_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import 'package:weather_icons/weather_icons.dart';

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
  List<Forecast>? hourlyForecast;
  List<Forecast>? dailyForecast;
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
    try {
      final hourData = await GetHourlyForecast(
        repo,
      ).callByLatLon(widget.lat, widget.lon, widget.day);

      final dayData = await GetDailyForecast(
        repo,
      ).callByLatLon(widget.lat, widget.lon);
      setState(() {
        hourlyForecast = hourData;
        dailyForecast = dayData;
        loading = false;
      });
    } catch (e) {
      print('API error: $e');
      setState(() {
        hourlyForecast = [];
        dailyForecast = [];
        loading = false;
      });
    }
  }

  String temp(double c) =>
      showFahrenheit ? "${(c * 9 / 5 + 32).round()}°F" : "${c.round()}°C";

  IconData getWeatherIcon(String? description) {
    final keyword = (description ?? '').toLowerCase();
    if (keyword.contains("rain") ||
        keyword.contains("shower") ||
        keyword.contains("mưa"))
      return Icons.umbrella;
    if (keyword.contains("storm") ||
        keyword.contains("thunder") ||
        keyword.contains("dông"))
      return Icons.flash_on;
    if (keyword.contains("snow") || keyword.contains("tuyết"))
      return Icons.ac_unit;
    if (keyword.contains("sun") ||
        keyword.contains("clear") ||
        keyword.contains("nắng"))
      return Icons.wb_sunny;
    if (keyword.contains("cloud") ||
        keyword.contains("overcast") ||
        keyword.contains("mây"))
      return Icons.cloud;
    return Icons.cloud; // fallback mặc định
  }

  String getViDayName(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day)
      return 'Hôm nay';
    switch (d.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        return '';
    }
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

    final int hourlyCount = hourlyForecast?.length ?? 0;
    final int dailyCount = dailyForecast?.length ?? 0;
    final List<Forecast> hourList = hourlyForecast ?? [];
    final List<Forecast> dayList = dailyForecast ?? [];

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
            context.go('/favorites');
          },
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
          : (hourlyCount == 0 && dailyCount == 0)
          ? const Center(
              child: Text(
                'Không có dữ liệu thời tiết!',
                style: TextStyle(color: Colors.white),
              ),
            )
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
                    "Dự báo $dailyCount ngày",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CARD DỰ BÁO THEO GIỜ
                  if (hourlyCount > 0)
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
                              itemCount: hourList.length > 7
                                  ? 7
                                  : hourList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final f = hourList[i];
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
                  // CARD DỰ BÁO NGÀY THEO API
                  if (dailyCount > 0)
                    ...List.generate(dayList.length, (idx) {
                      final f = dayList[idx];
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
                                          : getViDayName(f.dateTime),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${f.dateTime.day}/${f.dateTime.month}/${f.dateTime.year}",
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
                                    getWeatherIcon(f.description),
                                    color: Colors.white,
                                    size: 33,
                                  ),
                                  Text(
                                    temp(f.maxTemp),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 19,
                                    ),
                                  ),
                                  Text(
                                    temp(f.minTemp),
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
