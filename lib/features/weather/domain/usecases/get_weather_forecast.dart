import '../entities/weather_forecast.dart';
import '../repositories/weather_forecast_repository.dart';

class GetWeatherForecast {
  final WeatherForecastRepository repository;

  GetWeatherForecast(this.repository);

  /// Trả về danh sách dự báo từng khung giờ/ngày cho city
  Future<List<WeatherForecast>> call(String cityName) {
    return repository.getForecastByCity(cityName);
  }
}
