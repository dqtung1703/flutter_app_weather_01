import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/presentation/widget/customer_bottom_nav.dart';
import 'package:my_app/core/routing/app_routes.dart';
import 'package:my_app/features/profile/presentation/pages/profile_page.dart';
import 'package:my_app/features/weather/presentation/pages/weather_home_page.dart';
import 'package:my_app/features/weather/presentation/pages/favorite_location_page.dart';
import '/features/auth/presentation/pages/login_page.dart';
import '/features/auth/presentation/pages/signup_page.dart';
import 'go_router_refresh_change.dart';
// Thêm import cho trang map
import 'package:my_app/features/weather/presentation/pages/rain_map_page.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
            body: child,
            bottomNavigationBar: CustomerBottomNav(initialIndex: currentIndex),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.weatherHome,
            builder: (context, state) => const WeatherHomePage(),
          ),
          GoRoute(
            path: AppRoutes.favorite,
            builder: (context, state) => const FavoriteLocationPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          // Thêm route cho trang bản đồ
          GoRoute(
            path: AppRoutes.rainMap,
            builder: (context, state) => RainMapPage(),
          ),
        ],
      ),
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.weatherHome),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.weatherHome;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );

  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.weatherHome)) return 0;
    if (path.startsWith(AppRoutes.favorite)) return 1;
    if (path.startsWith(AppRoutes.profile)) return 2;
    if (path.startsWith(AppRoutes.rainMap)) return 3; // Nếu muốn có tab riêng
    return 0;
  }
}
