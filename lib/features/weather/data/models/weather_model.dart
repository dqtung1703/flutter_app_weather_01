class WeatherModel {
  final String cityName;
  final String country;
  final String description;
  final String iconCode;
  final double temperature;
  final double feelsLike;
  final double minTemperature;
  final double maxTemperature;
  final int pressure;
  final int humidity;
  final double lat;
  final double lon;
  final DateTime dateTime;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.description,
    required this.iconCode,
    required this.temperature,
    required this.feelsLike,
    required this.minTemperature,
    required this.maxTemperature,
    required this.pressure,
    required this.humidity,
    required this.lat,
    required this.lon,
    required this.dateTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Parse giờ local từ UTC + timezone offset (giây)
    final utcTime = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000, isUtc: true);
    final timezoneOffset = (json['timezone'] as int?) ?? 0;
    final dateTimeLocal = utcTime.add(Duration(seconds: timezoneOffset));

    return WeatherModel(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      minTemperature: (json['main']['temp_min'] as num).toDouble(),
      maxTemperature: (json['main']['temp_max'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      humidity: json['main']['humidity'] ?? 0,
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
      dateTime: dateTimeLocal,          // <-- GIỜ ĐỊA PHƯƠNG CHUẨN
    );
  }
}
