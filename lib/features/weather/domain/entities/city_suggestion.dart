class CitySuggestion {
  final String name;
  final String country;
  final double lat;
  final double lon;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) => CitySuggestion(
    name: json['name'],
    country: json['country'],
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
  );

  String get display => '$name ($country)';
}
