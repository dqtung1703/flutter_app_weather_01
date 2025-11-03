class Weather {
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

  Weather({
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
}
