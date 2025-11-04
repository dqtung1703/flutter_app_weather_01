import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  WeatherModel.fromJson(Map<String, dynamic> json)
    : super(
        city: json['name'] ?? '',
        temperature: (json['main']?['temp'] ?? 0).toDouble(),
        feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
        minTemp: (json['main']?['temp_min'] ?? 0).toDouble(),
        maxTemp: (json['main']?['temp_max'] ?? 0).toDouble(),
        humidity: (json['main']?['humidity'] ?? 0) as int,
        pressure: (json['main']?['pressure'] ?? 0) as int,
        windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
        description: (json['weather'] != null && json['weather'].isNotEmpty)
            ? (json['weather'][0]?['description'] ?? '')
            : '',
        brief: json['brief'],
        aqi: json['aqi'],
        uvIndex: json['uv_index'],
      );
}
