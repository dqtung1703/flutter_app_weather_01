import '../entities/favorite_city.dart';

abstract class FavoriteCityRepository {
  Future<void> addFavoriteCity(FavoriteCity city);
  Future<void> removeFavoriteCity(String cityName);
  Stream<List<FavoriteCity>> getFavoriteCities();
}
