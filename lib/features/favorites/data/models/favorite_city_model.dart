import '../../domain/entities/favorite_city.dart';

class FavoriteCityModel extends FavoriteCity {
  const FavoriteCityModel(String name, double lat, double lon)
      : super(name, lat, lon);

  factory FavoriteCityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCityModel(
      json['name'] as String,
      (json['lat'] as num).toDouble(),
      (json['lon'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };
}
