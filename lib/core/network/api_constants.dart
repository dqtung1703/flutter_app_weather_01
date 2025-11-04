import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => 'https://api.openweathermap.org/data/2.5/';
  static String get apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const int timeout = 15000;
}
