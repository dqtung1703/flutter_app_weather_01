import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/weather_forecast_page.dart';

class FavoriteLocationPage extends StatefulWidget {
  const FavoriteLocationPage({Key? key}) : super(key: key);

  @override
  State<FavoriteLocationPage> createState() => _FavoriteLocationPageState();
}

class _FavoriteLocationPageState extends State<FavoriteLocationPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> favoriteLocations = [];
  bool isAdding = false;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> raw = prefs.getStringList('favoriteLocationsWithLatLng') ?? [];
    setState(() {
      favoriteLocations = raw.map((str) => Map<String, dynamic>.from(jsonDecode(str))).toList();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> raw = favoriteLocations.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('favoriteLocationsWithLatLng', raw);
  }

  void _addFavorite(Map<String, String> city) {
    final displayName = city['display_name'] ?? '';
    final lat = city['lat'] ?? '';
    final lon = city['lon'] ?? '';
    if (displayName.isNotEmpty &&
        !favoriteLocations.any((f) => f['display_name'] == displayName)) {
      setState(() {
        favoriteLocations.add({'display_name': displayName, 'lat': lat, 'lon': lon});
        isAdding = false;
        _controller.clear();
      });
      _saveFavorites();
    }
  }

  void _removeFavorite(Map<String, dynamic> city) {
    setState(() {
      favoriteLocations.removeWhere((f) => f['display_name'] == city['display_name']);
    });
    _saveFavorites();
  }

  Future<List<Map<String, String>>> searchCityOpenStreetMap(String pattern) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$pattern&format=json&addressdetails=1&limit=7');
    final response = await http.get(url, headers: {'User-Agent': 'weather-favorite-page'});
    if (response.statusCode == 200) {
      final List items = List.from(jsonDecode(response.body) ?? []);
      return items
          .map((item) => {
                'display_name': item['display_name'].toString(),
                'lat': item['lat'].toString(),
                'lon': item['lon'].toString(),
              })
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF24243e) : Colors.white;
    final bgColor = isDark ? const Color(0xFF202032) : const Color(0xFFF7F8FC);
    final iconColor = isDark ? Colors.lightBlue[200]! : Colors.blue;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Địa điểm yêu thích'),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
          color: textColor, fontWeight: FontWeight.bold, fontSize: 22,
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny, color: iconColor),
            tooltip: isDark ? "Chuyển sáng" : "Chuyển tối",
            onPressed: () => setState(() => isDark = !isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isAdding)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TypeAheadField<Map<String, String>>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên địa điểm (cụ thể)...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                        ),
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.isEmpty) return [];
                        return await searchCityOpenStreetMap(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.location_city, color: iconColor),
                          title: Text(
                            suggestion['display_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          subtitle: Text(
                            'Lat: ${suggestion['lat']}, Lon: ${suggestion['lon']}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _addFavorite(suggestion);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                    onPressed: () {
                      setState(() {
                        isAdding = false;
                        _controller.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: favoriteLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 80, color: iconColor.withOpacity(0.16)),
                        const SizedBox(height: 22),
                        Text(
                          'Chưa có địa điểm yêu thích',
                          style: TextStyle(fontSize: 21, color: isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhấn + để thêm',
                          style: TextStyle(fontSize: 15, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: favoriteLocations.length,
                    itemBuilder: (context, i) {
                      final city = favoriteLocations[i];
                      return _buildLocationCard(context, city, cardColor, iconColor, textColor, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => isAdding = true),
        backgroundColor: iconColor,
        child: const Icon(Icons.add, size: 29),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Map<String, dynamic> city, Color cardColor, Color iconColor, Color textColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.19 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.location_city, color: iconColor, size: 26),
        ),
        title: Text(
          city['display_name'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.7,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 26),
          onPressed: () => _showDeleteDialog(city, textColor),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WeatherForecastPage(city: city['display_name']),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> city, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF22223C) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Xóa địa điểm', style: TextStyle(color: textColor)),
        content: Text('Bạn có chắc muốn xóa "${city['display_name']}" khỏi danh sách yêu thích?',
          style: TextStyle(color: textColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              _removeFavorite(city);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
