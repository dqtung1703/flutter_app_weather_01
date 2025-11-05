import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../presentation/pages/weather_detail_page.dart';

class FavoriteCityMarker {
  final String name;
  final double lat;
  final double lon;

  FavoriteCityMarker({required this.name, required this.lat, required this.lon});

  factory FavoriteCityMarker.fromJson(Map<String, dynamic> json) {
    return FavoriteCityMarker(
      name: json['name'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
    );
  }
}

class WeatherMapPage extends StatefulWidget {
  const WeatherMapPage({Key? key}) : super(key: key);

  @override
  State<WeatherMapPage> createState() => _WeatherMapPageState();
}

class _WeatherMapPageState extends State<WeatherMapPage> {
  final mapController = MapController();
  LatLng? currentLocation;
  List<FavoriteCityMarker> favoriteMarkers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadFavoriteMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _loadFavoriteMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> locationJsonList = prefs.getStringList('favoriteLocationsWithLatLng') ?? [];
    setState(() {
      favoriteMarkers = locationJsonList.map((jsonStr) {
        final data = jsonDecode(jsonStr);
        return FavoriteCityMarker.fromJson(data);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bản đồ thời tiết')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation ?? LatLng(21.0285, 105.8542),
          initialZoom: 6,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          TileLayer(
            urlTemplate: 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=b0ee8bb4ad5a2fc82fcf925a0ac3d3fb',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 42,
                  height: 42,
                  child: Icon(Icons.my_location, color: Colors.blue, size: 36),
                ),
              ...favoriteMarkers.map((city) => Marker(
                point: LatLng(city.lat, city.lon),
                width: 70,
                height: 54,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeatherDetailPage(
                          city: city.name,
                          lat: city.lat,
                          lon: city.lon,
                          day: DateTime.now(),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_city, color: Colors.amber, size: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: Colors.white.withOpacity(0.8),
                        child: Text(
                          city.name,
                          style: const TextStyle(fontSize: 12, color: Colors.black, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
      floatingActionButton: currentLocation == null
          ? null
          : FloatingActionButton(
              tooltip: 'Về vị trí của tôi',
              child: Icon(Icons.my_location),
              onPressed: () {
                mapController.move(currentLocation!, 13);
              },
            ),
    );
  }
}