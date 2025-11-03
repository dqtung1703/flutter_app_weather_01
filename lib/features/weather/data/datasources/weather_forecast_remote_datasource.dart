import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';

class WeatherForecastRemoteDataSource {
  final http.Client client;
  final String apiKey;

  WeatherForecastRemoteDataSource(this.client, this.apiKey);

  Future<List<WeatherForecastModel>> fetchForecastByCity(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=vi';
    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather forecast');
    }
    final Map<String, dynamic> json = jsonDecode(response.body);

    // Lấy offset timezone của city (giây)
    final int timezoneOffset = json['city']['timezone'] ?? 0;

    final List<dynamic> forecastList = json['list'];
    return forecastList
        .map((item) => WeatherForecastModel.fromJson(item, timezoneOffset))
        .toList();
  }
}
