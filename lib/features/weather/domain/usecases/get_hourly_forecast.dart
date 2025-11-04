import '../repositories/weather_repository.dart';
import '../entities/forecast.dart';

class GetHourlyForecast {
  final WeatherRepository repo;
  GetHourlyForecast(this.repo);

  Future<List<Forecast>> call(String city, DateTime date) =>
      repo.getHourlyForecast(city, date);

  Future<List<Forecast>> callByLatLon(double lat, double lon, DateTime date) =>
      repo.getHourlyForecastByLatLon(lat, lon, date);
}
