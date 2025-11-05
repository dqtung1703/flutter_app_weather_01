import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HourlyTemperatureChart({required this.hourlyList, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.yellowAccent,
              spots: [
                for (final h in hourlyList)
                  FlSpot(h.dateTime.hour.toDouble(), h.temperature),
              ],
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  "${value.toInt()}°",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                interval: 3,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  "${value.toInt()}h",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                interval: 3,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}
