import '../repositories/favorite_city_repository.dart';
import '../entities/favorite_city.dart';

class AddFavoriteCity {
  final FavoriteCityRepository repo;
  AddFavoriteCity(this.repo);

  Future<void> call(FavoriteCity city) => repo.addFavoriteCity(city);
}
