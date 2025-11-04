import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/app_locator.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/city_suggestion.dart'; // import entity mới
import '../../domain/usecases/get_weather.dart';
import '../../domain/usecases/get_daily_forecast.dart';
import '../../domain/usecases/get_hourly_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_city_suggestions.dart';
import '../../presentation/pages/weather_map_page.dart';

import '../widgets/current_weather_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';
import 'five_days_forecast_page.dart';

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
  final String city; // chỉ dùng mặc định, ban đầu là String city
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
    _loadByCityName(city); // load mặc định ban đầu theo tên nếu muốn
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
      // Đảm bảo có các hàm callByLatLon trong usecase/data
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

  // Nếu khởi động app vẫn muốn cho phép người dùng nhập city tên, fallback dùng tên bình thường
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
    if (gpsCity == null) gpsCity = "Hanoi";
    _loadByCityName(gpsCity);
  }

  @override
  Widget build(BuildContext context) {
    Color textColorMain = isDarkMode ? Colors.white : Colors.black;
    Color bgMain = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    Color bgBlock = isDarkMode ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        title: Text(
          weather?.city ?? city,
          style: TextStyle(
            color: textColorMain,
            fontWeight: FontWeight.bold,
            fontSize: 21,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blueAccent,
        elevation: 0,
        foregroundColor: textColorMain,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "Quản lý TP yêu thích",
            onPressed: () {
              // Sử dụng GoRouter để điều hướng đến trang favorites
              context.go('/favorites'); // hoặc context.go(AppRoutes.favorites)
            },
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_7 : Icons.nights_stay,
              color: isDarkMode ? Colors.amber : Colors.grey[900],
            ),
            tooltip: isDarkMode ? "Chuyển sáng" : "Chuyển tối",
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.map, color: Colors.blueAccent),
            tooltip: "Xem bản đồ thời tiết",
            onPressed: () {
            Navigator.push(
            context, MaterialPageRoute(builder: (_) => WeatherMapPage()));
    },
  ),
          IconButton(
            icon: Icon(
              Icons.location_searching,
              color: isDarkMode ? Colors.amber : Colors.blue,
            ),
            tooltip: "Về vị trí hiện tại",
            onPressed: _refreshLocation,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: TextStyle(color: Colors.red)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BOX với gợi ý toàn cầu
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TypeAheadField<CitySuggestion>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thành phố...',
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      suggestionsCallback: (pattern) =>
                          _getCitySuggestions(pattern),
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(
                            suggestion.display,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        searchController.text = suggestion.display;
                        selectedCity = suggestion;
                        _loadByCitySuggestion(suggestion);
                      },
                    ),
                  ),
                  if (weather != null)
                    CurrentWeatherWidget(
                      weather: weather!,
                      darkMode: isDarkMode,
                    ),
                  const SizedBox(height: 17),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgBlock,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 11),
                    margin: EdgeInsets.only(bottom: 14),
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
                        SizedBox(height: 6),
                        HourlyForecastWidget(
                          hourlyData: hourlyForecast,
                          darkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isDarkMode
                            ? Colors.blueGrey
                            : Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 1,
                      ),
                      child: Text(
                        'Dự báo chi tiết 5 ngày',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FiveDaysForecastPage(
                              dailyForecast: dailyForecast.take(5).toList(),
                              darkMode: isDarkMode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Dự báo 7 ngày tới',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColorMain,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: DailyForecastWidget(
                      dailyData: dailyForecast.take(7).toList(),
                      darkMode: isDarkMode,
                    ),
                  ),
                  SizedBox(height: 22),
                ],
              ),
            ),
    );
  }
}
