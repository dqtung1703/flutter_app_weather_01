import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> fetchWeatherByCity(String cityName);
  Future<WeatherModel> fetchWeatherByLatLon(double lat, double lon); // THÊM
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  final String apiKey;

  WeatherRemoteDataSourceImpl(this.client, this.apiKey);

  @override
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final url =
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric&lang=vi';
    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to get weather: ${response.reasonPhrase}');
    }
    final Map<String, dynamic> json = jsonDecode(response.body);
    return WeatherModel.fromJson(json);
  }

  @override
  Future<WeatherModel> fetchWeatherByLatLon(double lat, double lon) async {
    final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to get weather by location: ${response.reasonPhrase}');
    }
    final Map<String, dynamic> json = jsonDecode(response.body);
    return WeatherModel.fromJson(json);
  }
}
