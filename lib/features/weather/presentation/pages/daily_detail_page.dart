import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';

// Widget vẽ biểu đồ nhiệt độ giờ (line chart)
class HourlyWeatherChart extends StatelessWidget {
  final List<Forecast> hourlyData;
  const HourlyWeatherChart({Key? key, required this.hourlyData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty)
      return Text(
        'Không có dữ liệu từng giờ',
        style: TextStyle(color: Colors.white),
      );
    final colorLine = Colors.yellowAccent;
    final spots = hourlyData
        .map((f) => FlSpot(f.dateTime.hour.toDouble(), f.temperature))
        .toList();
    return Container(
      height: 170,
      padding: EdgeInsets.only(top: 18, left: 10, right: 10),
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}°',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}h',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24),
          ),
          minY:
              hourlyData
                  .map((f) => f.temperature)
                  .reduce((a, b) => a < b ? a : b) -
              2,
          maxY:
              hourlyData
                  .map((f) => f.temperature)
                  .reduce((a, b) => a > b ? a : b) +
              2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorLine,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colorLine.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Trang chi tiết từng ngày UI hiện đại
class DailyDetailPage extends StatelessWidget {
  final Forecast forecast;
  final List<Forecast> hourlyForecast;

  const DailyDetailPage({
    Key? key,
    required this.forecast,
    required this.hourlyForecast,
  }) : super(key: key);

  String getViDayName(DateTime d) {
    final weekday = d.weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Điều kiện thời tiết', style: TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần ngày và nút chọn các ngày
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      7, // Bạn muốn bao nhiêu thì chỉnh ở đây (có thể truyền List<DateTime> vào)
                      (i) => GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 11,
                          ),
                          decoration: BoxDecoration(
                            color: (forecast.dateTime.weekday == i + 1)
                                ? Colors.white10
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: forecast.dateTime.weekday == i + 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                  '${getViDayName(forecast.dateTime)}, ngày ${forecast.dateTime.day} tháng ${forecast.dateTime.month} ${forecast.dateTime.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${forecast.maxTemp.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 50, color: Colors.white),
                  ),
                  Text(
                    '°',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    '${forecast.minTemp.toStringAsFixed(0)}°',
                    style: TextStyle(fontSize: 26, color: Colors.white70),
                  ),
                  const SizedBox(width: 13),
                  Icon(
                    Icons.cloud,
                    color: Colors.white,
                    size: 33,
                  ), // Nên chọn icon đúng kiểu thời tiết
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Độ C (°C)', style: TextStyle(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 8),
              // Biểu đồ nhiệt độ theo giờ
              HourlyWeatherChart(hourlyData: hourlyForecast),
              SizedBox(height: 10),
              // Toggle Thực tế / Cảm nhận (demo, chưa active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: Text('Thực tế'),
                  ),
                  SizedBox(width: 7),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: Text('Cảm nhận'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Nhiệt độ thực tế.',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
              SizedBox(height: 16),
              // Khả năng mưa
              Text(
                'Khả năng có mưa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Khả năng có mưa vào ${getViDayName(forecast.dateTime)}: ${forecast.rainChance}%',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 16),
              Container(
                height: 80,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: forecast.rainChance * 2.5,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 18,
                      child: Text(
                        '${forecast.rainChance}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Thông tin bổ sung
              Row(
                children: [
                  Text(
                    'Gió: ${forecast.windSpeed} km/h',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Độ ẩm: ${forecast.humidity}%',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                '${forecast.description}',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 9),
              // Đường viền mờ cuối page cho đẹp
              Divider(color: Colors.white24, thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
