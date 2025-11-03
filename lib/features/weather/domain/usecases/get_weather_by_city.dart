import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeatherByCity {
  final WeatherRepository repository;

  GetWeatherByCity(this.repository);

  /// Trả về dữ liệu thời tiết hiện tại cho một thành phố (cityName)
  Future<Weather> call(String cityName) {
    return repository.getWeatherByCity(cityName);
  }
}
