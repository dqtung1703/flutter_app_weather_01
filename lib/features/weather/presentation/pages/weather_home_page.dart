import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_locator.dart'; // Tùy cấu trúc project
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/city_suggestion.dart';
import '../../domain/usecases/get_weather.dart';
import '../../domain/usecases/get_daily_forecast.dart';
import '../../domain/usecases/get_hourly_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_city_suggestions.dart';
import '../../presentation/pages/weather_map_page.dart';

import '../widgets/current_weather_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';

// Hàm lấy vị trí qua GPS (dùng cho refresh location)
Future<String?> getCurrentCity() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(const Duration(seconds: 10));
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ??
          placemarks.first.subAdministrativeArea ??
          "Unknown";
    }
  } catch (_) {}
  return null;
}

class WeatherHomePage extends StatefulWidget {
  final String city;
  const WeatherHomePage({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  Weather? weather;
  List<Forecast> hourlyForecast = [];
  List<Forecast> dailyForecast = [];
  bool loading = true;
  String? error;
  bool isDarkMode = false;
  late String city;
  CitySuggestion? selectedCity;
  final TextEditingController searchController = TextEditingController();
  late final GetCitySuggestions _getCitySuggestions;

  @override
  void initState() {
    super.initState();
    city = widget.city;
    searchController.text = city;
    _getCitySuggestions = sl<GetCitySuggestions>();
    _loadByCityName(city);
  }

  Future<void> _loadByCitySuggestion(CitySuggestion citySuggest) async {
    setState(() {
      loading = true;
      error = null;
      selectedCity = citySuggest;
      city = citySuggest.display;
      searchController.text = citySuggest.display;
    });
    try {
      final repo = sl<WeatherRepository>();
      weather = await GetWeather(
        repo,
      ).callByLatLon(citySuggest.lat, citySuggest.lon);
      dailyForecast = await GetDailyForecast(
        repo,
      ).callByLatLon(citySuggest.lat, citySuggest.lon);
      hourlyForecast = await GetHourlyForecast(
        repo,
      ).callByLatLon(citySuggest.lat, citySuggest.lon, DateTime.now());
    } catch (e) {
      error = '$e';
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _loadByCityName(String inputCity) async {
    setState(() {
      loading = true;
      error = null;
      city = inputCity;
      searchController.text = inputCity;
      selectedCity = null;
    });
    try {
      final repo = sl<WeatherRepository>();
      weather = await GetWeather(repo).call(inputCity);
      dailyForecast = await GetDailyForecast(repo).call(inputCity);
      hourlyForecast = await GetHourlyForecast(
        repo,
      ).call(inputCity, DateTime.now());
    } catch (e) {
      error = '$e';
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _refreshLocation() async {
    setState(() => loading = true);
    String? gpsCity;
    try {
      gpsCity = await getCurrentCity().timeout(Duration(seconds: 10));
    } catch (_) {}
    if (gpsCity == null || gpsCity.isEmpty) {
      gpsCity = widget.city;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không lấy được vị trí GPS, dùng thành phố mặc định!"),
        ),
      );
    }
    _loadByCityName(gpsCity);
  }

  void _showDetail(String title, String detail) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14),
            Text(detail, style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Widget _smallWeatherBox({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(6),
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.17),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 27),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> _lightGradient = [Color(0xFF75c2ff), Color(0xFF5795ed)];
    final List<Color> _darkGradient = [Color(0xFF11141c), Color(0xFF23294a)];
    Color textColorMain = Colors.white;
    Color bgBlock = Colors.white.withOpacity(0.18);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode ? _darkGradient : _lightGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Thanh Search + các nút chức năng
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TypeAheadField<CitySuggestion>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên thành phố...',
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black87),
                                ),
                                suggestionsCallback: (pattern) =>
                                    _getCitySuggestions(pattern),
                                itemBuilder: (context, suggestion) =>
                                    ListTile(title: Text(suggestion.display)),
                                onSuggestionSelected: (suggestion) {
                                  searchController.text = suggestion.display;
                                  selectedCity = suggestion;
                                  _loadByCitySuggestion(suggestion);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    // Nút Thêm thành phố yêu thích
                    IconButton(
                      icon: Icon(
                        Icons.add_location_alt,
                        color: Colors.amberAccent,
                      ),
                      tooltip: 'Thêm thành phố yêu thích',
                      onPressed: () {
                        context.go('/favorites');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.location_searching, color: Colors.white),
                      tooltip: "Về vị trí hiện tại",
                      onPressed: _refreshLocation,
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.brightness_7 : Icons.nights_stay,
                        color: Colors.white,
                      ),
                      tooltip: isDarkMode ? 'Chuyển sáng' : 'Chuyển tối',
                      onPressed: () => setState(() => isDarkMode = !isDarkMode),
                    ),
                    IconButton(
                      icon: Icon(Icons.map, color: Colors.white),
                      tooltip: "Xem bản đồ thời tiết",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WeatherMapPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (loading)
                Expanded(child: Center(child: CircularProgressIndicator()))
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Text(error!, style: TextStyle(color: Colors.red)),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 10),
                          child: CurrentWeatherWidget(
                            weather: weather!,
                            darkMode: isDarkMode,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 5,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgBlock,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dự báo theo giờ',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: textColorMain,
                                  ),
                                ),
                                SizedBox(height: 7),
                                HourlyForecastWidget(
                                  hourlyData: hourlyForecast,
                                  darkMode: isDarkMode,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 4,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgBlock,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dự báo 5 ngày tới',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: textColorMain,
                                  ),
                                ),
                                DailyForecastWidget(
                                  dailyData: dailyForecast.take(5).toList(),
                                  darkMode: isDarkMode,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (weather != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                _smallWeatherBox(
                                  title: 'ĐỘ ẨM',
                                  value: '${weather!.humidity}%',
                                  icon: Icons.water_drop,
                                  onTap: () => _showDetail(
                                    'Độ Ẩm',
                                    'Độ ẩm không khí hiện tại là ${weather!.humidity}%',
                                  ),
                                ),
                                _smallWeatherBox(
                                  title: 'CẢM GIÁC',
                                  value:
                                      '${weather!.feelsLike.toStringAsFixed(0)}°C',
                                  icon: Icons.thermostat,
                                  onTap: () => _showDetail(
                                    'Cảm Giác Thực Tế',
                                    'Nhiệt độ cảm nhận thực tế: ${weather!.feelsLike}°C',
                                  ),
                                ),
                                _smallWeatherBox(
                                  title: 'ÁP SUẤT',
                                  value: '${weather!.pressure} hPa',
                                  icon: Icons.speed,
                                  onTap: () => _showDetail(
                                    'Áp Suất Khí Quyển',
                                    'Áp suất không khí hiện tại là ${weather!.pressure} hPa',
                                  ),
                                ),
                                _smallWeatherBox(
                                  title: 'TÌNH TRẠNG',
                                  value: weather!.description.toUpperCase(),
                                  icon: Icons.cloud,
                                  onTap: () => _showDetail(
                                    'Tình Trạng Thời Tiết',
                                    'Trạng thái hiện tại: ${weather!.description}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
