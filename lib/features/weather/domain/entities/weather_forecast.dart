class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final String description;
  final String iconCode;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.description,
    required this.iconCode,
  });
}

// Nếu muốn định nghĩa cho list các khung giờ/ngày (tổng thể 1 dự báo)
class WeatherForecastGroup {
  final String cityName;
  final List<WeatherForecast> forecasts;

  WeatherForecastGroup({
    required this.cityName,
    required this.forecasts,
  });
}
