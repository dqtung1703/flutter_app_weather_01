import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
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
import '../widgets/hourly_humidity_chart.dart';
import '../widgets/hourly_pressure_chart.dart';
import '../widgets/hourly_feels_like_chart.dart';
import '../widgets/hourly_rain_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Hàm lấy vị trí qua GPS (dùng cho refresh location)
Future<String?> _getCurrentCity() async {
  try {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw "GPS/location services đang bị tắt";
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw "Từ chối quyền vị trí";
    }
    if (permission == LocationPermission.deniedForever) {
      throw "Đã từ chối quyền vị trí vĩnh viễn.";
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print('Your position: $pos');

    if (kIsWeb) {
      // Dùng Nominatim reverse geocoding trên web
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        final address = jsonRes['address'];
        if (address != null && address['city'] != null) return address['city'];
        return address['state'] ?? address['county'] ?? null;
      }
      return "Unknown";
    }

    // Mobile: dùng placemarkFromCoordinates
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      print("Placemarks: $placemarks");
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = (place.locality?.isNotEmpty ?? false)
            ? place.locality
            : (place.subAdministrativeArea?.isNotEmpty ?? false)
            ? place.subAdministrativeArea
            : null;
        if (city != null && city.isNotEmpty) {
          return city;
        }
      }
    } catch (e) {
      print("Placemark geocoding error: $e");
    }
    return "Unknown";
  } catch (e) {
    print("Error _getCurrentCity: $e");
    rethrow;
  }
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
      gpsCity = await _getCurrentCity().timeout(Duration(seconds: 10));
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

  // Magnus approximation for dew point in Celsius
  double _dewPointC(double tC, int rhPercent) {
    final rh = rhPercent.clamp(0, 100) / 100.0;
    if (rh <= 0) return -50.0; // avoid log(0)
    const a = 17.27;
    const b = 237.7; // °C
    final gamma = (a * tC) / (b + tC) + math.log(rh);
    return (b * gamma) / (a - gamma);
  }

  String _fmtDateHour(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    return '$d/$m  ${h}h';
  }

  Widget _hourlyDetails({
    required List<Forecast> list,
    required String Function(Forecast h) valueBuilder,
  }) {
    if (list.isEmpty) return const SizedBox();
    final items = List<Forecast>.from(list)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final count = math.min(items.length, 24);
    return SizedBox(
      height: 160,
      child: ListView.separated(
        itemCount: count,
        separatorBuilder: (_, __) => const Divider(height: 10, color: Color(0x11000000)),
        itemBuilder: (context, i) {
          final h = items[i];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmtDateHour(h.dateTime), style: const TextStyle(color: Colors.black54, fontSize: 13)),
              Text(valueBuilder(h), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            ],
          );
        },
      ),
    );
  }

  void _showWidgetSheet({
    required String title,
    required Widget child,
    bool showSeeAll = false,
    Widget? header,
    Widget? footer,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (showSeeAll)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: điều hướng trang chi tiết nếu có
                        },
                        child: const Text('Xem tất cả'),
                      ),
                  ],
                ),
                if (header != null) ...[
                  const SizedBox(height: 6),
                  header,
                ],
                const SizedBox(height: 10),
                SizedBox(height: 220, child: child),
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  footer,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // removed: old _showDetail bottom sheet (replaced by chart bottom sheets)

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

    final Map<DateTime, List<Forecast>> hourlyDataByDay = {};
    for (final h in hourlyForecast) {
      final dayKey = DateTime(
        h.dateTime.year,
        h.dateTime.month,
        h.dateTime.day,
      );
      (hourlyDataByDay[dayKey] ??= []).add(h);
    }
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
                                  hourlyDataByDay:
                                      hourlyDataByDay, // bắt buộc truyền map này!
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
                                  onTap: () {
                                    final hum = weather!.humidity;
                                    final t = weather!.temperature;
                                    final dew = _dewPointC(t, hum).round();
                                    _showWidgetSheet(
                                      title: 'Độ ẩm theo giờ',
                                      header: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${hum}%',
                                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Điểm sương: ${dew}°',
                                            style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      child: HourlyHumidityChart(hourlyList: hourlyForecast),
                                      footer: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Chi tiết theo giờ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6),
                                          _hourlyDetails(
                                            list: hourlyForecast,
                                            valueBuilder: (h) => '${h.humidity}%',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                _smallWeatherBox(
                                  title: 'CẢM GIÁC',
                                  value:
                                      '${weather!.feelsLike.toStringAsFixed(0)}°C',
                                  icon: Icons.thermostat,
                                  onTap: () => _showWidgetSheet(
                                    title: 'Cảm giác theo giờ',
                                    child: HourlyFeelsLikeChart(hourlyList: hourlyForecast),
                                    footer: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Chi tiết theo giờ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        _hourlyDetails(
                                          list: hourlyForecast,
                                          valueBuilder: (h) => '${h.temperature.round()}°',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _smallWeatherBox(
                                  title: 'ÁP SUẤT',
                                  value: '${weather!.pressure} hPa',
                                  icon: Icons.speed,
                                  onTap: () => _showWidgetSheet(
                                    title: 'Áp suất theo giờ',
                                    child: HourlyPressureChart(hourlyList: hourlyForecast),
                                    footer: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Chi tiết theo giờ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        _hourlyDetails(
                                          list: hourlyForecast,
                                          valueBuilder: (h) => '${h.pressure} hPa',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _smallWeatherBox(
                                  title: 'TÌNH TRẠNG',
                                  value: weather!.description.toUpperCase(),
                                  icon: Icons.cloud,
                                  onTap: () => _showWidgetSheet(
                                    title: 'Khả năng mưa theo giờ',
                                    child: HourlyRainChanceChart(hourlyList: hourlyForecast),
                                    footer: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Chi tiết theo giờ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        _hourlyDetails(
                                          list: hourlyForecast,
                                          valueBuilder: (h) => '${h.rainChance}%',
                                        ),
                                      ],
                                    ),
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
