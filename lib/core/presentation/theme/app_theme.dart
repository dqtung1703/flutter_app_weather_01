import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,
    
    // App Bar theo style iOS
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.onBackground,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
    ),
    
    // // Card với shadow mềm mại như iOS
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //   color: Colors.white,
    //   shadowColor: Colors.black.withOpacity(0.1),
    // ),
    
    // Bottom Navigation Bar theo style iOS
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.bottomNavUnselected,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Text Theme theo San Francisco Font style
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.onBackground),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.onBackground),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onBackground),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.onBackground),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onBackground),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onBackground),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onBackground),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onBackground),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
    ),
    
    // Input Decoration theo style iOS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Elevated Button theo style iOS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 1,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.dark,
    
    // Dark mode colors
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //   color: AppColors.cardDark,
    //   shadowColor: Colors.black.withOpacity(0.3),
    // ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBackgroundDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.bottomNavUnselectedDark,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
    ),
  );
}
