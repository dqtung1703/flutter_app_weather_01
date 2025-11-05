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
  bool isDarkMode = false; // Luôn không null

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

    final bgColor = isDarkMode ? Color(0xFF23294a) : Colors.white;
    final fgColor = isDarkMode ? Colors.white : Colors.black87;
    final inputBgColor = isDarkMode ? Color(0xFF32364a) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Thành phố yêu thích', style: TextStyle(color: fgColor)),
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fgColor),
          tooltip: "Quay về trang chính",
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_7 : Icons.nights_stay,
              color: fgColor,
            ),
            tooltip: isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
            onPressed: () => setState(
              () => isDarkMode = !(isDarkMode ?? false),
            ), // EP KIEU AN TOAN
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TypeAheadField<CitySuggestion>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _cityController,
                style: TextStyle(color: fgColor),
                decoration: InputDecoration(
                  fillColor: inputBgColor,
                  filled: true,
                  labelText: 'Tìm và thêm thành phố',
                  labelStyle: TextStyle(color: fgColor),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.cyanAccent : Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) => _getCitySuggestions(pattern),
              itemBuilder: (context, suggestion) {
                return ListTile(
                  tileColor: isDarkMode
                      ? Colors.black
                      : Colors
                            .white, // chỉ cần dòng này nếu suggestionsBoxDecoration không đủ
                  title: Text(
                    suggestion.display,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ), // màu chữ nổi bật!
                  ),
                );
              },
              onSuggestionSelected: (suggestion) async {
                await addFavorite(
                  FavoriteCity(
                    suggestion.display,
                    suggestion.lat,
                    suggestion.lon,
                  ),
                );
                _cityController.clear();
              },
              noItemsFoundBuilder: (context) => Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Không tìm thấy thành phố phù hợp!',
                  style: TextStyle(color: fgColor),
                ),
              ),
            ),
          ),
          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
          Expanded(
            child: StreamBuilder<List<FavoriteCity>>(
              stream: repo.getFavoriteCities(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  );
                }
                final cities = snapshot.data!;
                if (cities.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có thành phố yêu thích nào!',
                      style: TextStyle(color: fgColor),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    return ListTile(
                      title: Text(city.name, style: TextStyle(color: fgColor)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => removeFavorite(city.name),
                      ),
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
