import '../../domain/entities/city_suggestion.dart';
import '../../domain/repositories/city_suggestion_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CitySuggestionRepositoryImpl implements CitySuggestionRepository {
  final String apiKey;
  CitySuggestionRepositoryImpl(this.apiKey);

  @override
  Future<List<CitySuggestion>> fetchSuggestions(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$keyword&limit=5&appid=$apiKey';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return [];
    final List data = jsonDecode(resp.body);
    return data
        .map<CitySuggestion>((item) => CitySuggestion.fromJson(item))
        .toList();
  }
}
