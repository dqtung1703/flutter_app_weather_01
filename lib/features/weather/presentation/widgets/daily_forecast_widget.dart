import 'package:flutter/material.dart';
import '../../domain/entities/forecast.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Forecast> dailyData;
  final bool darkMode;
  const DailyForecastWidget({
    super.key,
    required this.dailyData,
    this.darkMode = false,
  });

  String getViDayName(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day)
      return 'Hôm nay';
    final weekday = d.weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Th 2';
      case DateTime.tuesday:
        return 'Th 3';
      case DateTime.wednesday:
        return 'Th 4';
      case DateTime.thursday:
        return 'Th 5';
      case DateTime.friday:
        return 'Th 6';
      case DateTime.saturday:
        return 'Th 7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  String getViDateDay(DateTime d) {
    return '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: dailyData.length,
        itemBuilder: (_, idx) {
          final f = dailyData[idx];
          final dayText = getViDayName(f.dateTime);
          final dateText = getViDateDay(f.dateTime);
          final isToday = dayText == 'Hôm nay';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayText,
                        style: TextStyle(
                          color: isToday
                              ? (darkMode ? Colors.amber : Colors.blueAccent)
                              : (darkMode ? Colors.white : Colors.black),
                          fontSize: 17,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: darkMode ? Colors.white54 : Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildWeatherIcon(f),
                SizedBox(width: 7),
                Text(
                  '${f.minTemp.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: darkMode ? Colors.white54 : Colors.black54,
                    fontSize: 17,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 8,
                    child: CustomPaint(
                      painter: TempBarPainter(
                        min: f.minTemp,
                        max: f.maxTemp,
                        barColor: darkMode
                            ? Colors.amber[100]!
                            : Colors.yellowAccent,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${f.maxTemp.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: darkMode ? Colors.amber[100] : Colors.yellowAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (f.rainChance > 0)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Icon(Icons.grain, color: Colors.blue, size: 15),
                        Text(
                          '${f.rainChance}%',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherIcon(Forecast f) {
    final desc = (f as dynamic).description?.toLowerCase() ?? '';
    if (desc.contains('rain')) {
      return Icon(Icons.umbrella, color: Colors.blueAccent);
    }
    if (desc.contains('cloud')) {
      return Icon(Icons.cloud, color: Colors.blueGrey[100]);
    }
    if (desc.contains('sun') || desc.contains('clear')) {
      return Icon(Icons.wb_sunny, color: Colors.amber);
    }
    return Icon(Icons.cloud, color: Colors.blueGrey);
  }
}

class TempBarPainter extends CustomPainter {
  final double min, max;
  final Color barColor;
  TempBarPainter({
    required this.min,
    required this.max,
    required this.barColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    final left = size.width * 0.15;
    final right = size.width * 0.85;
    canvas.drawLine(
      Offset(left, size.height / 2),
      Offset(right, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
