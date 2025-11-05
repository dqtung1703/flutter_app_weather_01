import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

class HumidityChartWidget extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HumidityChartWidget({required this.hourlyList, super.key});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return Center(
        child: Text('Không có dữ liệu', style: TextStyle(fontSize: 17)),
      );
    }
    final spots = hourlyList
        .asMap()
        .entries
        .map(
          (e) => FlSpot(e.key.toDouble(), (e.value.humidity ?? 0).toDouble()),
        )
        .toList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Độ ẩm theo giờ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.cyan,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.cyan.withOpacity(0.17),
                    ),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
                gridData: FlGridData(show: true, horizontalInterval: 10),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Divider(),
          Text(
            "Chi tiết theo giờ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          ...hourlyList.map(
            (f) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${f.dateTime.day.toString().padLeft(2, '0')}/${f.dateTime.month.toString().padLeft(2, '0')} ${f.dateTime.hour.toString().padLeft(2, '0')}h',
                  ),
                  Text(
                    '${f.humidity}%',
                    style: TextStyle(fontWeight: FontWeight.w500),
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
