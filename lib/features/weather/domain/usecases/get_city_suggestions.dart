import '../repositories/city_suggestion_repository.dart';
import '../entities/city_suggestion.dart';

class GetCitySuggestions {
  final CitySuggestionRepository repository;
  GetCitySuggestions(this.repository);

  Future<List<CitySuggestion>> call(String keyword) =>
      repository.fetchSuggestions(keyword);
}
