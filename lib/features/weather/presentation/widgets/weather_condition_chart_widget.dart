import 'package:flutter/material.dart';
import '../../domain/entities/forecast.dart';

class WeatherConditionChartWidget extends StatelessWidget {
  final List<Forecast> hourlyList;
  const WeatherConditionChartWidget({required this.hourlyList, super.key});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return Center(
        child: Text('Không có dữ liệu', style: TextStyle(fontSize: 17)),
      );
    }
    // Nếu bạn có clouds (int clouds) thì show chart, nếu không thì bỏ, chỉ còn bảng mô tả
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tình trạng thời tiết theo giờ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    '${f.description?.toUpperCase() ?? ''}',
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
