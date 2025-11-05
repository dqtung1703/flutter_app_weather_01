import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class HomeLocationRedirector extends StatefulWidget {
  const HomeLocationRedirector({super.key});
  @override
  State<HomeLocationRedirector> createState() => _HomeLocationRedirectorState();
}

class _HomeLocationRedirectorState extends State<HomeLocationRedirector> {
  bool _isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    _gotoWeatherHome();
  }

  Future<void> _gotoWeatherHome() async {
    String? gpsCity;
    String? errorMsg;
    try {
      gpsCity = await _getCurrentCity();
    } catch (e) {
      errorMsg = e.toString();
      print('Error getting location: $e');
    }
    if (!mounted) return;

    if (gpsCity == null || gpsCity.isEmpty || gpsCity == "Unknown") {
      if (!_isShowingDialog) {
        _isShowingDialog = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text('Lỗi định vị'),
            content: Text(
              errorMsg != null
                  ? 'Không lấy được vị trí hiện tại (Chi tiết: $errorMsg).\nHãy bật GPS/location trên máy, chạy app bằng localhost hoặc HTTPS, và kiểm tra trình duyệt đã cho phép truy cập vị trí.\nBạn cũng có thể chọn/thêm thành phố thủ công.'
                  : 'Không lấy được vị trí hiện tại. Hãy kiểm tra GPS/Internet hoặc thử lại sau.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isShowingDialog = false;
                },
                child: Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isShowingDialog = false;
                  _gotoWeatherHome();
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Điều hướng bằng GoRouter, truyền tên city qua extra
  GoRouter.of(context).go(AppRoutes.home, extra: gpsCity);
    // Nếu context.go không có extension, always dùng GoRouter.of(context).go()
  }

  Future<String?> getCityFromLatLonWeb(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final address = json['address'];
      if (address != null && address['city'] != null) return address['city'];
      return address['state'] ?? address['county'] ?? null;
    }
    return null;
  }

  Future<String?> _getCurrentCity() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw "GPS/location services đang bị tắt";
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw "Từ chối quyền vị trí";
      }
      if (permission == LocationPermission.deniedForever) {
        throw "Đã từ chối quyền vị trí vĩnh viễn.";
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Your position: $pos');

      if (kIsWeb) {
        // Lấy tên thành phố từ lat/lon qua Nominatim trên web
        String? city = await getCityFromLatLonWeb(pos.latitude, pos.longitude);
        if (city != null && city.isNotEmpty) return city;
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
