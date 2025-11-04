import '../../domain/entities/forecast.dart';

class ForecastModel extends Forecast {
  ForecastModel.fromJson(Map<String, dynamic> json)
    : super(
        dateTime: DateTime.fromMillisecondsSinceEpoch(
          json['dt'] * 1000,
          isUtc: true,
        ).toLocal(),
        temperature: (json['main']['temp'] as num).toDouble(),
        minTemp: (json['main']['temp_min'] as num).toDouble(),
        maxTemp: (json['main']['temp_max'] as num).toDouble(),
        humidity: json['main']['humidity'] ?? 0,
        pressure: json['main']['pressure'] ?? 0,
        windSpeed: (json['wind']['speed'] as num).toDouble(),
        rainChance: ((json['pop'] ?? 0) * 100).toInt(),
        description: json['weather'] != null && json['weather'].isNotEmpty
            ? (json['weather'][0]['description'] ?? '')
            : '',
        aqi: json['aqi'],
        uvIndex: json['uv_index'],
        dayName: null,
      );
}
