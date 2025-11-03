import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RainMapPage extends StatefulWidget {
  const RainMapPage({Key? key}) : super(key: key);

  @override
  State<RainMapPage> createState() => _RainMapPageState();
}

class _RainMapPageState extends State<RainMapPage> {
  final mapController = MapController();
  LatLng? currentLocation;
  List<LatLng> favoriteMarkers = [];

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

  // Đọc dữ liệu địa điểm yêu thích từ SharedPreferences
  Future<void> _loadFavoriteMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> locationJsonList = prefs.getStringList('favoriteLocationsWithLatLng') ?? [];
    setState(() {
      favoriteMarkers = locationJsonList.map((jsonStr) {
        final data = jsonDecode(jsonStr);
        return LatLng(
          double.tryParse(data['lat'].toString()) ?? 0.0,
          double.tryParse(data['lon'].toString()) ?? 0.0,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bản đồ lượng mưa')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(21.0285, 105.8542),
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
              ...favoriteMarkers.map((loc) => Marker(
                point: loc,
                width: 42,
                height: 42,
                child: Icon(Icons.star, color: Colors.amber, size: 32),
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
