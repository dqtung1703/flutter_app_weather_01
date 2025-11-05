import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';
import '../widgets/hourly_temperature_chart.dart';
import 'package:intl/intl.dart';

class HourlyRainChanceChart extends StatelessWidget {
  final List<Forecast> hourlyList;
  const HourlyRainChanceChart({required this.hourlyList, super.key});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return Center(
        child: Text(
          "Không có dữ liệu mưa từng giờ",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    final spots = hourlyList
        .map((h) => FlSpot(h.dateTime.hour.toDouble(), h.rainChance.toDouble()))
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
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}h',
                  style: TextStyle(color: Colors.blue[100], fontSize: 12),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white12, strokeWidth: 1),
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

class DailyForecastPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<Forecast> hourlyList;
  const DailyForecastPage({
    required this.selectedDate,
    required this.hourlyList,
    super.key,
  });

  double get maxTemp => hourlyList.isNotEmpty
      ? hourlyList.map((e) => e.temperature).reduce((a, b) => a > b ? a : b)
      : 0;
  double get minTemp => hourlyList.isNotEmpty
      ? hourlyList.map((e) => e.temperature).reduce((a, b) => a < b ? a : b)
      : 0;
  double get avgHumidity => hourlyList.isNotEmpty
      ? hourlyList.map((e) => e.humidity).reduce((a, b) => a + b) /
            hourlyList.length
      : 0;
  int get maxRainChance => hourlyList.isNotEmpty
      ? hourlyList.map((e) => e.rainChance).reduce((a, b) => a > b ? a : b)
      : 0;
  double get totalRainVolume => hourlyList.isNotEmpty
      ? hourlyList
            .map((e) => e.rainVolume ?? 0)
            .fold<double>(0, (prev, v) => prev + v)
      : 0;

  @override
  Widget build(BuildContext context) {
    final String summary =
        "Trong ngày ${DateFormat('dd/MM', 'vi').format(selectedDate)}: "
        "Nhiệt độ cao nhất ${maxTemp.round()}°C, thấp nhất ${minTemp.round()}°C. "
        "Độ ẩm trung bình: ${avgHumidity.round()}%.";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 239, 235, 235),
        title: Text(
          "Chi tiết ngày ${DateFormat('EEEE, dd/MM/yyyy', 'vi').format(selectedDate)}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ), // màu trắng rõ nét
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Nhiệt độ CAO NHẤT",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${maxTemp.round()}°C",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Nhiệt độ THẤP NHẤT",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${minTemp.round()}°C",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          HourlyTemperatureChart(hourlyList: hourlyList),
          SizedBox(height: 16),
          Text(
            "Khả năng có mưa",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          HourlyRainChanceChart(hourlyList: hourlyList),
          SizedBox(height: 8),
          Text(
            "Khả năng có mưa vào hôm nay: ${maxRainChance}%",
            style: TextStyle(color: Colors.blue[100], fontSize: 15),
          ),
          Text(
            "Khả năng có mưa hàng ngày có xu hướng cao hơn khả năng cho mỗi giờ.",
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
          if (hourlyList.any((e) => e.rainVolume != null)) ...[
            SizedBox(height: 10),
            Text(
              "Tổng lượng mưa hôm nay: ${totalRainVolume.toStringAsFixed(1)} mm",
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
            ),
          ],
          SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                Text(
                  "Độ ẩm trung bình: ${avgHumidity.round()}%",
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
