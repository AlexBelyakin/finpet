import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFFFF6EA);
  static const mint = Color(0xFF7BC6A6);
  static const peach = Color(0xFFFFB38A);
  static const sky = Color(0xFF8EC5E8);
  static const ink = Color(0xFF3A2F2A);
  static const card = Color(0xFFFFFCF7);

  static ThemeData data() {
    final scheme = ColorScheme.fromSeed(
      seedColor: mint,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme.copyWith(
        primary: const Color(0xFF2F7A5D),
        secondary: peach,
        surface: cream,
      ),
      scaffoldBackgroundColor: cream,
      useMaterial3: true,
      textTheme: Typography.blackMountainView
          .apply(bodyColor: ink, displayColor: ink)
          .copyWith(
            bodyLarge: const TextStyle(fontSize: 16, height: 1.3),
            bodyMedium: const TextStyle(fontSize: 16, height: 1.3),
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
