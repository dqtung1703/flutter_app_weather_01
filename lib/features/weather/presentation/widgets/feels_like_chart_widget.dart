import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class FeelsLikeChartWidget extends StatelessWidget {
  final List<Forecast> hourlyList;
  const FeelsLikeChartWidget({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu cảm giác',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cảm giác theo giờ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(
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
                      interval: ((maxT - minT).abs() / 4)
                          .clamp(1, 10)
                          .toDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}°',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}h',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Colors.white12, strokeWidth: 1),
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
          ),
          Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Chi tiết theo giờ",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          ...hourlyList.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${f.dateTime.day.toString().padLeft(2, '0')}/${f.dateTime.month.toString().padLeft(2, '0')} ${f.dateTime.hour.toString().padLeft(2, '0')}h',
                    style: const TextStyle(
                      color: Colors.black87,
                    ), // <-- màu tối rõ
                  ),
                  Text(
                    '${f.temperature.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ), // <-- màu tối rõ
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
