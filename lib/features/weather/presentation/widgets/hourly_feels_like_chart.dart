import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class HourlyFeelsLikeChart extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HourlyFeelsLikeChart({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return const Center(child: Text('Không có dữ liệu cảm giác', style: TextStyle(color: Colors.white)));
    }

    // Use forecast.temperature as proxy for feels-like if not provided per hour
    final temps = hourlyList.map((h) => h.temperature).toList();
    double minT = temps.reduce((a, b) => a < b ? a : b);
    double maxT = temps.reduce((a, b) => a > b ? a : b);
    final pad = 1.5;
    minT -= pad;
    maxT += pad;

    final spots = [
      for (final h in hourlyList)
        FlSpot(h.dateTime.hour.toDouble(), h.temperature),
    ];

    return SizedBox(
      height: 172,
      child: LineChart(
        LineChartData(
          minY: minT,
          maxY: maxT,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: ((maxT - minT).abs() / 4).clamp(1, 10).toDouble(),
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}h',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.pinkAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.pinkAccent.withOpacity(0.25),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
