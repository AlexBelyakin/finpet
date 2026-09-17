import 'package:flutter/material.dart';

import 'package:finpet/domain/models.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFFFF6EA);
  static const mint = Color(0xFF7BC6A6);
  static const peach = Color(0xFFFFB38A);
  static const sky = Color(0xFF8EC5E8);
  static const wave = Color(0xFFE7C9B8);
  static const ink = Color(0xFF3A2F2A);
  static const card = Color(0xFFFFFCF7);

  static Color petTint(PetColor color) => switch (color) {
        PetColor.peach => peach,
        PetColor.mint => mint,
        PetColor.sky => sky,
        PetColor.wave => wave,
      };

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
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
