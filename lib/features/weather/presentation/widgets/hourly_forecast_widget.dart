import 'package:flutter/material.dart';
import '../../domain/entities/forecast.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Forecast> hourlyData;
  final bool darkMode;
  const HourlyForecastWidget({
    super.key,
    required this.hourlyData,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayList = hourlyData
        .where(
          (f) =>
              f.dateTime.isAfter(now) &&
              f.dateTime.difference(now).inHours < 25,
        )
        .toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'Không có dự báo giờ',
          style: TextStyle(color: darkMode ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayList.length,
        separatorBuilder: (_, __) => SizedBox(width: 6),
        itemBuilder: (context, idx) {
          final f = displayList[idx];
          final isNow =
              idx == 0 ||
              (f.dateTime.hour == now.hour && f.dateTime.day == now.day);
          final hourLabel = isNow ? 'Bây giờ' : '${f.dateTime.hour}:00';
          return Column(
            children: [
              Text(
                '${f.temperature.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNow
                      ? (darkMode ? Colors.lightBlueAccent : Colors.blue)
                      : (darkMode ? Colors.white : Colors.black),
                ),
              ),
              Icon(
                _getWeatherIcon(f.description ?? ''),
                color: isNow
                    ? (darkMode ? Colors.lightBlueAccent : Colors.blueAccent)
                    : (darkMode ? Colors.amber.shade200 : Colors.amber),
                size: 24,
              ),
              SizedBox(height: 5),
              Text(
                hourLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: isNow
                      ? (darkMode ? Colors.lightBlueAccent : Colors.blue)
                      : (darkMode ? Colors.white70 : Colors.black),
                ),
              ),
              Text(
                '${f.windSpeed.toStringAsFixed(1)}km/h',
                style: TextStyle(
                  fontSize: 11,
                  color: darkMode ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getWeatherIcon(String desc) {
    desc = desc.toLowerCase();
    if (desc.contains('rain') ||
        desc.contains('shower') ||
        desc.contains('mưa'))
      return Icons.umbrella;
    if (desc.contains('storm') || desc.contains('thunder'))
      return Icons.flash_on;
    if (desc.contains('snow') || desc.contains('tuyết')) return Icons.ac_unit;
    if (desc.contains('sun') || desc.contains('clear') || desc.contains('nắng'))
      return Icons.wb_sunny;
    if (desc.contains('cloud') ||
        desc.contains('overcast') ||
        desc.contains('mây'))
      return Icons.cloud;
    return Icons.cloud;
  }
}
