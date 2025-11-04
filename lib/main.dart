import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'core/routing/app_go_router.dart';
import 'core/config/firebase_env.dart';
import 'core/di/app_locator.dart';

// Hàm lấy city định vị như bạn đã có
Future<String?> getCurrentCityWithTimeout({int timeoutSeconds = 8}) async {
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
    ).timeout(Duration(seconds: timeoutSeconds));
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseEnv.apiKey,
      appId: FirebaseEnv.appId,
      messagingSenderId: FirebaseEnv.messagingSenderId,
      projectId: FirebaseEnv.projectId,
      authDomain: FirebaseEnv.authDomain,
      storageBucket: FirebaseEnv.storageBucket,
      measurementId: FirebaseEnv.measurementId,
    ),
  );
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _city;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCityAndRedirect();
  }

  Future<void> _loadCityAndRedirect() async {
    String? city;
    try {
      city = await getCurrentCityWithTimeout(timeoutSeconds: 8);
    } catch (_) {}
    city ??= "Hanoi";
    setState(() {
      _city = city!;
      _loading = false;
    });
    // Sau khi định vị xong, điều hướng về /home truyền city cho GoRouter
    Future.microtask(() => AppGoRouter.router.go('/home', extra: city));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    // Khi đã redirect, MaterialApp.router dùng GoRouter cho toàn app
    return MaterialApp.router(routerConfig: AppGoRouter.router);
  }
}
