import '../repositories/favorite_city_repository.dart';

class RemoveFavoriteCity {
  final FavoriteCityRepository repo;
  RemoveFavoriteCity(this.repo);

  Future<void> call(String cityName) => repo.removeFavoriteCity(cityName);
}
