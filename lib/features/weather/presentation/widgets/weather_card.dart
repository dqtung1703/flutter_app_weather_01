import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final DateTime dateTime;
  final double temperature;
  final String iconCode;
  final String description;
  final double? minTemperature;
  final double? maxTemperature;

  const WeatherCard({
    Key? key,
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
    required this.description,
    this.minTemperature,
    this.maxTemperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SizedBox(
        width: 105,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${dateTime.hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text('${dateTime.day}/${dateTime.month}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 36, height: 36,
              ),
              Text(
                '${temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (minTemperature != null && maxTemperature != null)
                Text(
                    'Min ${minTemperature!.toStringAsFixed(1)}°C\nMax ${maxTemperature!.toStringAsFixed(1)}°C',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(
                description,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
