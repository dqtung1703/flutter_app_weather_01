import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/weather_model.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';

class WeatherHomePage extends StatefulWidget {
  final String? city;
  const WeatherHomePage({Key? key, this.city}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCity = '';
  WeatherModel? weather;
  bool isLoading = true;
  String? errorMessage;
  late WeatherRepositoryImpl repo;

  bool isDarkMode = false;
  bool isCelsius = true;

  double? myLat, myLon;

  @override
  void initState() {
    super.initState();
    repo = WeatherRepositoryImpl(
      WeatherRemoteDataSourceImpl(http.Client(), 'b0ee8bb4ad5a2fc82fcf925a0ac3d3fb'),
    );
    _loadWeatherByMyLocation();
  }

  Future<void> _loadWeatherByMyLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Chưa bật dịch vụ vị trí trên thiết bị!');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Thiết bị chưa cấp quyền vị trí');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Thiết bị bị cấm quyền vị trí');

      final pos = await Geolocator.getCurrentPosition();
      myLat = pos.latitude;
      myLon = pos.longitude;
      // Lấy dự báo bằng lat/lon
      weather = await repo.getWeatherByLatLon(myLat!, myLon!);

      // Lấy tên thực tế địa chỉ để hiển thị trên search box
      final geocodeUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$myLat&lon=$myLon&format=json'
      );
      final geocodeResponse = await http.get(geocodeUrl, headers: {'User-Agent': 'weather-my-location'});
      if (geocodeResponse.statusCode == 200) {
        final data = jsonDecode(geocodeResponse.body);
        selectedCity = data['display_name'] ?? 'Vị trí của tôi';
      } else {
        selectedCity = 'Vị trí của tôi';
      }
      _searchController.text = selectedCity;
    } catch (e) {
      errorMessage = e.toString();
      weather = null;
      selectedCity = '';
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didUpdateWidget(WeatherHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != null && widget.city != oldWidget.city) {
      selectedCity = widget.city!;
      _searchController.text = selectedCity;
      _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      weather = await repo.getWeatherByCity(selectedCity);
    } catch (e) {
      errorMessage = 'Không thể tải dữ liệu thời tiết';
      weather = null;
    }
    setState(() { isLoading = false; });
  }

  List<Color> _getGradientColors() {
    if (weather == null) {
      return [const Color(0xFF4A90E2), const Color(0xFF50B7E8)];
    }

    final condition = weather!.description.toLowerCase();
    final hour = DateTime.now().hour;

    if (hour >= 19 || hour < 6) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }
    if (condition.contains('clear') || condition.contains('sun')) {
      return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    } else if (condition.contains('cloud')) {
      return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
    } else if (condition.contains('rain')) {
      return [const Color(0xFF5374A5), const Color(0xFF3B4F6F)];
    } else if (condition.contains('snow')) {
      return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)];
    }
    return [const Color(0xFF4A90E2), const Color(0xFF50B7E8)];
  }

  List<Color> _getMainGradientColors() {
    if (isDarkMode) return [const Color(0xFF232526), const Color(0xFF414345)];
    return _getGradientColors();
  }

  int _convertTemp(double tempC) {
    if (isCelsius) return tempC.round();
    return (tempC * 1.8 + 32).round();
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sun')) return Icons.wb_sunny;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain')) return Icons.water_drop;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('thunder')) return Icons.flash_on;
    return Icons.wb_cloudy;
  }

  String _getDayName(int weekday) {
    const days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return days[weekday - 1];
  }

  String _getLottieAssetByDesc(String? desc) {
    if (desc == null) return 'assets/lottie/Sunny.json';
    final d = desc.toLowerCase();
    if (d.contains('rain')) return 'assets/lottie/rainy.json';
    if (d.contains('cloud')) return 'assets/lottie/Clouds.json';
    if (d.contains('snow')) return 'assets/lottie/snow.json';
    if (d.contains('sun') || d.contains('clear')) return 'assets/lottie/Sunny.json';
    return 'assets/lottie/Sunny.json';
  }

  Future<List<String>> searchCityOpenStreetMap(String pattern) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$pattern&format=json&addressdetails=1&limit=5');
    final response = await http.get(url, headers: {'User-Agent': 'weather-app-example'});
    if (response.statusCode == 200) {
      final List items = List.from(jsonDecode(response.body) ?? []);
      return items.map((item) => item['display_name'].toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox(
          width: 230,
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên thành phố...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
            ),
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) return [];
              return await searchCityOpenStreetMap(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.location_city, color: Colors.blue),
                title: Text(suggestion, style: TextStyle(fontWeight: FontWeight.w500)),
              );
            },
            onSuggestionSelected: (suggestion) {
              setState(() {
                selectedCity = suggestion;
              });
              _searchController.text = suggestion;
              _loadWeather();
            },
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.nightlight : Icons.wb_sunny, color: Colors.white),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: Icon(isCelsius ? Icons.thermostat : Icons.thermostat_auto, color: Colors.white),
            tooltip: isCelsius ? 'Chuyển sang °F' : 'Chuyển sang °C',
            onPressed: () => setState(() => isCelsius = !isCelsius),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () async {
              // refresh lại đúng GPS khi nhấn vào menu.
              await _loadWeatherByMyLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: weather != null
              ? Lottie.asset(
                  _getLottieAssetByDesc(weather!.description),
                  fit: BoxFit.cover,
                  repeat: true,
                  animate: true,
                )
              : const SizedBox.shrink()
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getMainGradientColors(),
              ),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : errorMessage != null
                    ? _buildErrorView()
                    : _buildWeatherContent(),
          )
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          Text(
            errorMessage ?? 'Có lỗi xảy ra',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: _loadWeatherByMyLocation,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                weather!.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_convertTemp(weather!.temperature)}°${isCelsius ? 'C' : 'F'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 102,
                  fontWeight: FontWeight.w200,
                  height: 1,
                ),
              ),
              Text(
                weather!.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'H:${_convertTemp(weather!.maxTemperature)}°${isCelsius ? "C" : "F"} '
                'L:${_convertTemp(weather!.minTemperature)}°${isCelsius ? "C" : "F"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              _buildHourlyForecastCard(),
              const SizedBox(height: 20),
              _buildDailyForecastCard(),
              const SizedBox(height: 20),
              _buildWeatherDetailsGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyForecastCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'DỰ BÁO THEO GIỜ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, i) {
                final hour = (DateTime.now().hour + i) % 24;
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        i == 0 ? 'Bây giờ' : '${hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        _getWeatherIcon(weather!.description),
                        color: i == 0 ? Colors.amber : Colors.white,
                        size: 28,
                      ),
                      Text(
                        '${_convertTemp(weather!.temperature - (i * 0.5))}°${isCelsius ? "C" : "F"}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'DỰ BÁO 10 NGÀY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 20),
          ...List.generate(7, (i) {
            final day = DateTime.now().add(Duration(days: i));
            final dayName = i == 0 ? 'Hôm nay' : _getDayName(day.weekday);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      dayName,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(_getWeatherIcon(weather!.description), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: SliderComponentShape.noThumb,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: 0.6,
                              onChanged: (v) {},
                              activeColor: Colors.amber,
                              inactiveColor: Colors.blue[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_convertTemp(weather!.minTemperature - i)}°${isCelsius ? "C" : "F"}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_convertTemp(weather!.maxTemperature - i)}°${isCelsius ? "C" : "F"}',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailCard('ĐỘ ẨM', '${weather!.humidity}%', Icons.water_drop)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailCard('CẢM GIÁC', '${_convertTemp(weather!.feelsLike)}°${isCelsius ? "C" : "F"}', Icons.thermostat)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDetailCard('ÁP SUẤT', '${weather!.pressure} hPa', Icons.compress)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailCard('TÌNH TRẠNG', weather!.description.toUpperCase(), Icons.cloud)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
