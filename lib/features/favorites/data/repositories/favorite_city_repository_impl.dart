import '../../domain/entities/favorite_city.dart';
import '../../domain/repositories/favorite_city_repository.dart';
import '../datasources/favorite_city_datasource.dart';
import '../models/favorite_city_model.dart';

class FavoriteCityRepositoryImpl implements FavoriteCityRepository {
  final FavoriteCityDatasource datasource;

  FavoriteCityRepositoryImpl(this.datasource);

  @override
  Future<void> addFavoriteCity(FavoriteCity city) async {
    await datasource.addFavoriteCity(
      city is FavoriteCityModel
          ? city
          // Sửa lại truyền đủ tham số name, lat, lon
          : FavoriteCityModel(city.name, city.lat, city.lon),
    );
  }

  @override
  Future<void> removeFavoriteCity(String cityName) async {
    await datasource.removeFavoriteCity(cityName);
  }

  @override
  Stream<List<FavoriteCity>> getFavoriteCities() {
    return datasource.streamFavoriteCities();
  }
}
