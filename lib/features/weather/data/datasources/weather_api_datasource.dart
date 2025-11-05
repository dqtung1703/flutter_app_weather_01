import '../../../../core/network/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';

class WeatherApiDatasource {
  final http.Client client;
  WeatherApiDatasource(this.client);

  String get apiKey => ApiConstants.apiKey;

  Future<WeatherModel> fetchWeather(String city) async {
    final url =
        '${ApiConstants.baseUrl}weather?q=$city&appid=$apiKey&units=metric&lang=vi'; // SỬA
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${res.body}");
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
    return WeatherModel.fromJson(json.decode(res.body));
  }

  Future<Weather> fetchWeatherByLatLon(double lat, double lon) async {
    final apiKey = dotenv.env['WEATHER_API_KEY']!;
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${resp.body}");
      throw Exception('API error: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    return WeatherModel.fromJson(data);
  }

  /// Hourly: lấy danh sách dự báo theo giờ 3h/lần cho city
  Future<List<ForecastModel>> fetchHourlyForecast(
    String city,
    DateTime day,
  ) async {
    final url =
        '${ApiConstants.baseUrl}forecast?q=$city&appid=$apiKey&units=metric&lang=vi'; // SỬA
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${res.body}");
      throw Exception('API error hourly ${res.statusCode}: ${res.body}');
    }
    final list = json.decode(res.body)['list'] as List;
    print('Hourly raw list length: ${list.length}');
    return list.map((item) => ForecastModel.fromJson(item)).toList();
  }

  /// HOURLY by LatLon: vẫn lấy full list 3h/lần (free-tier OWM)
  Future<List<Forecast>> fetchHourlyForecastByLatLon(
    double lat,
    double lon,
    DateTime date,
  ) async {
    final apiKey = dotenv.env['WEATHER_API_KEY']!;
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${resp.body}");
      throw Exception('API error: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    return (data['list'] as List)
        .map((item) => ForecastModel.fromJson(item))
        .toList();
  }

  /// DAILY forecast by LAT/LON (NO /forecast/daily, chỉ dùng /forecast)
  Future<List<Forecast>> fetchDailyForecastByLatLon(
    double lat,
    double lon,
  ) async {
    final apiKey = dotenv.env['WEATHER_API_KEY']!;
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${resp.body}");
      throw Exception('API error: ${resp.body}');
    }
    final data = jsonDecode(resp.body);

    final List list = data['list'];
    Map<String, ForecastModel> daily = {};
    for (final item in list) {
      final f = ForecastModel.fromJson(item);
      final dateKey =
          "${f.dateTime.year}-${f.dateTime.month.toString().padLeft(2, '0')}-${f.dateTime.day.toString().padLeft(2, '0')}";
      // Ưu tiên bản ghi 12h hoặc bản ghi đầu của ngày
      if (!daily.containsKey(dateKey) || f.dateTime.hour == 12) {
        daily[dateKey] = f;
      }
    }
    return daily.values.toList();
  }

  /// Daily forecast by city: group theo ngày từ /forecast như trên
  Future<List<ForecastModel>> fetchDailyForecast(String city) async {
    final url =
        '${ApiConstants.baseUrl}forecast?q=$city&appid=$apiKey&units=metric&lang=vi'; // SỬA
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("Weather error URL: $url");
      print("Weather error body: ${res.body}");
      throw Exception('API error daily ${res.statusCode}: ${res.body}');
    }
    final list = json.decode(res.body)['list'] as List;
    Map<String, ForecastModel> daily = {};
    for (final item in list) {
      final f = ForecastModel.fromJson(item);
      final dateKey =
          "${f.dateTime.year}-${f.dateTime.month.toString().padLeft(2, '0')}-${f.dateTime.day.toString().padLeft(2, '0')}";
      if (!daily.containsKey(dateKey) || f.dateTime.hour == 12) {
        daily[dateKey] = f;
      }
    }
    return daily.values.toList();
  }
}
