import '../entities/weather.dart';
import '../entities/forecast.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherByCity(String city);
  Future<List<Forecast>> getDailyForecast(String city);
  Future<List<Forecast>> getHourlyForecast(String city, DateTime day);
  Future<List<Forecast>> getHourlyForecastByLatLon(
    double lat,
    double lon,
    DateTime date,
  );

  Future<Weather> getWeatherByLatLon(double lat, double lon);
  Future<List<Forecast>> getDailyForecastByLatLon(double lat, double lon);
}
