import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class FiveDaysForecastPage extends StatelessWidget {
  final List<Forecast> dailyForecast;
  final bool darkMode;

  const FiveDaysForecastPage({
    super.key,
    required this.dailyForecast,
    required this.darkMode, // KHÔNG PHẢI bool?, luôn phải truyền
  });

  String getLabel(DateTime day) {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    if (isSameDay(day, yesterday)) return 'Hôm qua';
    if (isSameDay(day, now)) return 'Hôm nay';
    if (isSameDay(day, now.add(Duration(days: 1)))) return 'Ngày mai';
    final labels = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
    return labels[day.weekday % 7];
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  @override
  Widget build(BuildContext context) {
    final maxTemps = dailyForecast.map((f) => f.maxTemp).toList();
    final minTemps = dailyForecast.map((f) => f.minTemp).toList();
    final textColorMain = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text('Dự báo 5 ngày', style: TextStyle(color: textColorMain)),
        iconTheme: IconThemeData(color: textColorMain),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12, left: 6, right: 6),
        child: Column(
          children: [
            // Chart nhiệt độ
            SizedBox(
              height: 130,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        maxTemps.length,
                        (i) => FlSpot(i.toDouble(), maxTemps[i]),
                      ),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: List.generate(
                        minTemps.length,
                        (i) => FlSpot(i.toDouble(), minTemps[i]),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            SizedBox(height: 6),
            // Hàng ngang các ngày
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(dailyForecast.length, (idx) {
                  final f = dailyForecast[idx];
                  final dateStr = '${f.dateTime.day}/${f.dateTime.month}';
                  final label = getLabel(f.dateTime);
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: label == 'Hôm nay'
                          ? Colors.grey.withOpacity(0.09)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColorMain,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 7),
                        Icon(
                          _getWeatherIcon(f.description ?? ''),
                          size: 32,
                          color: Colors.blueGrey,
                        ),
                        Text(
                          '${f.maxTemp.toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: textColorMain,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '${f.minTemp.toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 15,
                            color: darkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '▼ ${f.windSpeed.toStringAsFixed(1)}km/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String desc) {
    desc = desc.toLowerCase();
    if (desc.contains('rain')) return Icons.umbrella;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('sun') || desc.contains('clear')) return Icons.wb_sunny;
    return Icons.cloud;
  }
}
