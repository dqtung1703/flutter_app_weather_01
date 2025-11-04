import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';
import 'package:flutter/material.dart';

class WeatherChart extends StatelessWidget {
  final List<Forecast> data;
  const WeatherChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox.shrink();
    final points = data
        .map((f) => FlSpot(f.dateTime.hour.toDouble(), f.temperature))
        .toList();
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: Colors
                  .blueAccent, // API mới fl_chart chỉ dùng color (ko colors)
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
        ),
      ),
    );
  }
}
