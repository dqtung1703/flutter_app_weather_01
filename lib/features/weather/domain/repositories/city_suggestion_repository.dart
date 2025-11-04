import '../entities/city_suggestion.dart';

abstract class CitySuggestionRepository {
  Future<List<CitySuggestion>> fetchSuggestions(String keyword);
}
