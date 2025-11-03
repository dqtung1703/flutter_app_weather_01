import '../datasources/weather_remote_datasource.dart';
import '../models/weather_model.dart';

abstract class WeatherRepository {
  Future<WeatherModel> getWeatherByCity(String cityName);
  Future<WeatherModel> getWeatherByLatLon(double lat, double lon); // THÊM
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    return await remoteDataSource.fetchWeatherByCity(cityName);
  }

  @override
  Future<WeatherModel> getWeatherByLatLon(double lat, double lon) async {
    return await remoteDataSource.fetchWeatherByLatLon(lat, lon);  // THÊM
  }
}
