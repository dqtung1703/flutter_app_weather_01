import '../datasources/weather_forecast_remote_datasource.dart';
import '../models/weather_forecast_model.dart';

abstract class WeatherForecastRepository {
  Future<List<WeatherForecastModel>> getForecastByCity(String city);
}

class WeatherForecastRepositoryImpl implements WeatherForecastRepository {
  final WeatherForecastRemoteDataSource remoteDataSource;

  WeatherForecastRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<WeatherForecastModel>> getForecastByCity(String city) async {
    return await remoteDataSource.fetchForecastByCity(city);
  }
}
