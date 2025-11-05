class Forecast {
  final DateTime dateTime;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int rainChance;
  final double? rainVolume;
  final int? clouds; // <-- Thêm dòng này!
  final String? description;
  final int? aqi;
  final int? uvIndex;
  final String? dayName;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.rainChance,
    this.rainVolume,
    this.clouds,
    this.description,
    this.aqi,
    this.uvIndex,
    this.dayName,
  });
}
