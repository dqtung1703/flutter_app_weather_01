import '../repositories/weather_repository.dart';
import '../entities/forecast.dart';

class GetDailyForecast {
  final WeatherRepository repo;
  GetDailyForecast(this.repo);

  Future<List<Forecast>> call(String city) => repo.getDailyForecast(city);

  Future<List<Forecast>> callByLatLon(double lat, double lon) =>
      repo.getDailyForecastByLatLon(lat, lon);
}
