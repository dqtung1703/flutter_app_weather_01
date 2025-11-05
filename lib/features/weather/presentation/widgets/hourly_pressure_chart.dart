import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class HourlyPressureChart extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HourlyPressureChart({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return const Center(child: Text('Không có dữ liệu áp suất', style: TextStyle(color: Colors.white)));
    }

    final pressures = hourlyList.map((h) => h.pressure.toDouble()).toList();
    double minP = pressures.reduce((a, b) => a < b ? a : b);
    double maxP = pressures.reduce((a, b) => a > b ? a : b);
    // Add padding
    final padding = 5.0;
    minP = (minP - padding);
    maxP = (maxP + padding);

    final spots = [
      for (final h in hourlyList)
        FlSpot(h.dateTime.hour.toDouble(), h.pressure.toDouble()),
    ];

    return SizedBox(
      height: 172,
      child: LineChart(
        LineChartData(
          minY: minP,
          maxY: maxP,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()} hPa',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                interval: ((maxP - minP) / 4).clamp(1, 100).toDouble(),
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
              color: Colors.orangeAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orangeAccent.withOpacity(0.25),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
