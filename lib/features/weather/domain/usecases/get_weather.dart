import '../repositories/weather_repository.dart';
import '../entities/weather.dart';

class GetWeather {
  final WeatherRepository repo;
  GetWeather(this.repo);

  Future<Weather> call(String city) => repo.getWeatherByCity(city);
  Future<Weather> callByLatLon(double lat, double lon) =>
      repo.getWeatherByLatLon(lat, lon);
}
