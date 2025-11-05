import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_api_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiDatasource datasource;
  WeatherRepositoryImpl(this.datasource);

  @override
  Future<Weather> getWeatherByCity(String city) =>
      datasource.fetchWeather(city);

  @override
  Future<Weather> getWeatherByLatLon(double lat, double lon) =>
      datasource.fetchWeatherByLatLon(lat, lon);

  @override
  Future<List<Forecast>> getDailyForecast(String city) =>
      datasource.fetchDailyForecast(city);

  @override
  Future<List<Forecast>> getHourlyForecast(String city, DateTime day) =>
      datasource.fetchHourlyForecast(city, day);

  @override
  Future<List<Forecast>> getDailyForecastByLatLon(double lat, double lon) =>
      datasource.fetchDailyForecastByLatLon(lat, lon);
  @override
  Future<List<Forecast>> getHourlyForecastByLatLon(
    double lat,
    double lon,
    DateTime date,
  ) => datasource.fetchHourlyForecastByLatLon(lat, lon, date);
}
