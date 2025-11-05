import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final Weather weather;
  final bool darkMode;
  const CurrentWeatherWidget({
    super.key,
    required this.weather,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // căn giữa theo trục dọc toàn bộ block
        crossAxisAlignment:
            CrossAxisAlignment.center, // căn giữa ngang từng dòng
        children: [
          Text(
            weather.city,
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${weather.temperature.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: 70,
              color: darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            weather.description,
            style: TextStyle(
              color: darkMode ? Colors.white70 : Colors.grey[700],
              fontSize: 20,
            ),
          ),
          Text(
            'C:${weather.maxTemp}° T:${weather.minTemp}°',
            style: TextStyle(
              color: darkMode ? Colors.white54 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
