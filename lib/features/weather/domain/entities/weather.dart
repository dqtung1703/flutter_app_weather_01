class Weather {
  final String city;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String? brief;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int? aqi;
  final int? uvIndex;

  Weather({
    required this.city,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    this.brief,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    this.aqi,
    this.uvIndex,
  });
}
