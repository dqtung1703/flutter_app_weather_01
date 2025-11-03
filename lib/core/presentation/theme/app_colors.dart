import 'package:flutter/material.dart';

class AppColors {
  // Brand Color - iOS Blue
  static const Color primary = Color(0xFF007AFF);

  // Light theme colors
  static const Color background = Color(0xFFF2F2F7); // iOS grouped background
  static const Color surface = Color(0xFFF7F7FA);    // Input/card subtle
  static const Color card = Colors.white;
  static const Color onBackground = Color(0xFF1C1C1E); // Primary text
  static const Color divider = Color(0x1F000000);      // ~12% black

  // Bottom navigation (light)
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0x993C3C43); // iOS secondary label

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF000000);   // iOS dark background
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color onBackgroundDark = Colors.white;

  // Bottom navigation (dark)
  static const Color bottomNavBackgroundDark = Color(0xFF121212);
  static const Color bottomNavUnselectedDark = Color(0x99EBEBF5); // iOS secondary on dark
}
