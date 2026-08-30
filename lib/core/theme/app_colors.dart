import 'package:flutter/material.dart';

/// Central color palette for the entire app.
/// Import this file instead of shared/styles/colors.dart.
abstract class AppColors {
  // ── Brand ─────────────────────────────────────
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1757);

  // ── Accent ────────────────────────────────────
  static const Color accent = Color(0xFFFBD784);

  // ── Status ────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ── Neutral ───────────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);

  // ── Background ────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFF8F9FA);

  // ── Helpers ───────────────────────────────────
  /// Builds a [MaterialColor] swatch from any [Color].
  static MaterialColor buildMaterialColor(Color color) {
    final List<double> strengths = [.05];
    final Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round().clamp(0, 255);
    final int g = (color.g * 255.0).round().clamp(0, 255);
    final int b = (color.b * 255.0).round().clamp(0, 255);
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
