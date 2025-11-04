class FavoriteCity {
  final String name;
  final double lat;
  final double lon;
  const FavoriteCity(this.name, this.lat, this.lon);

  Map<String, dynamic> toJson() => {'name': name, 'lat': lat, 'lon': lon};

  factory FavoriteCity.fromJson(Map<String, dynamic> json) =>
      FavoriteCity(
        json['name'] as String,
        (json['lat'] as num).toDouble(),
        (json['lon'] as num).toDouble(),
      );
}
