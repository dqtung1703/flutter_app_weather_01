import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/weather/presentation/pages/weather_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/favorites/presentation/pages/favorite_cities_page.dart';
import 'app_routes.dart';
import 'go_router_refresh_change.dart';
import '../../features/weather/presentation/pages/home_location_redirector.dart';
import '../../features/weather/presentation/pages/weather_home_page.dart';

// Hàm sử dụng đặt object city

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(body: child);
        },
        routes: [
          // ROUTE HOME - nhận city qua extra
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) {
              // Nếu chưa có city (lúc đầu), show HomeLocationRedirector
              final city = state.extra as String?;
              if (city == null) {
                return const HomeLocationRedirector();
              }
              // Nếu đã có city (sau redirect), show WeatherHomePage
              return WeatherHomePage(city: city);
            },
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoriteCitiesPage(),
          ),
          GoRoute(
            path: '/weather_detail',
            builder: (context, state) {
              final arg = state.extra as WeatherDetailPageParams;
              return WeatherDetailPage(
                city: arg.city,
                lat: arg.lat,
                lon: arg.lon,
                day: arg.day,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}
