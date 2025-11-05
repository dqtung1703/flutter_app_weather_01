import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class HourlyHumidityChart extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HourlyHumidityChart({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return const Center(child: Text('Không có dữ liệu độ ẩm', style: TextStyle(color: Colors.white)));
    }

    final spots = hourlyList
        .map((h) => FlSpot(h.dateTime.hour.toDouble(), h.humidity.toDouble()))
        .toList();

    return SizedBox(
      height: 172,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: TextStyle(color: Colors.blue[200], fontSize: 12),
                ),
                interval: 20,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}h',
                  style: TextStyle(color: Colors.blue[100], fontSize: 12),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.lightBlueAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.lightBlueAccent.withOpacity(0.28),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
