import 'package:flutter/material.dart';

class WeatherBriefWidget extends StatelessWidget {
  final String text;
  final Color? textColor;
  final bool darkMode;
  const WeatherBriefWidget({
    super.key,
    required this.text,
    this.textColor,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: darkMode
              ? Colors.grey[700]!.withOpacity(0.13)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? (darkMode ? Colors.white70 : Colors.black87),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
