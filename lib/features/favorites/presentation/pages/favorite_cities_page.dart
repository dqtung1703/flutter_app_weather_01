import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/app_locator.dart';
import '../../domain/entities/favorite_city.dart';
import '../../domain/usecases/add_favorite_city.dart';
import '../../domain/usecases/remove_favorite_city.dart';
import '../../domain/repositories/favorite_city_repository.dart';
import '../../../weather/domain/entities/city_suggestion.dart';
import '../../../weather/domain/usecases/get_city_suggestions.dart';
// Định nghĩa object để truyền extra cho go_router
class WeatherDetailPageParams {
  final String city;
  final double lat;
  final double lon;
  final DateTime day;
  WeatherDetailPageParams({
    required this.city,
    required this.lat,
    required this.lon,
    required this.day,
  });
}

class FavoriteCitiesPage extends StatefulWidget {
  const FavoriteCitiesPage({Key? key}) : super(key: key);

  @override
  State<FavoriteCitiesPage> createState() => _FavoriteCitiesPageState();
}

class _FavoriteCitiesPageState extends State<FavoriteCitiesPage> {
  late final GetCitySuggestions _getCitySuggestions;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCitySuggestions = sl<GetCitySuggestions>();
  }

  @override
  Widget build(BuildContext context) {
    final addFavorite = sl<AddFavoriteCity>();
    final removeFavorite = sl<RemoveFavoriteCity>();
    final repo = sl<FavoriteCityRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thành phố yêu thích'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Quay về trang chính",
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TypeAheadField<CitySuggestion>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Tìm và thêm thành phố',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) => _getCitySuggestions(pattern),
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion.display));
              },
              onSuggestionSelected: (suggestion) async {
                await addFavorite(FavoriteCity(
                  suggestion.display,
                  suggestion.lat,
                  suggestion.lon,
                ));
                _cityController.clear();
              },
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Không tìm thấy thành phố phù hợp!'),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<FavoriteCity>>(
              stream: repo.getFavoriteCities(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cities = snapshot.data!;
                if (cities.isEmpty) {
                  return const Center(
                    child: Text('Chưa có thành phố yêu thích nào!'),
                  );
                }
                return ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    return ListTile(
                      title: Text(city.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFavorite(city.name),
                      ),
                      // Truyền đủ tham số qua go_router để sang trang detail đúng lat/lon
                      onTap: () => context.go(
        '/weather_detail',
        extra: WeatherDetailPageParams(
          city: city.name,
          lat: city.lat,
          lon: city.lon,
          day: DateTime.now(),
        ),
      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
