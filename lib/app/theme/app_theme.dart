import 'package:flutter/material.dart';

import 'package:finpet/domain/models.dart';

abstract final class AppFonts {
  static const display = 'PT Root UI';
  static const body = 'Golos UI';
}

abstract final class AppTheme {
  static const cream = Color(0xFFFFF3DC);
  static const mint = Color(0xFF6FCBAB);
  static const peach = Color(0xFFFFA978);
  static const sky = Color(0xFF7EC4F0);
  static const wave = Color(0xFFE8B9A4);
  static const lilac = Color(0xFFD7C4F5);
  static const gold = Color(0xFFE8B84A);
  static const ink = Color(0xFF3A2F2A);
  static const card = Color(0xFFFFFDF8);
  static const playGreen = Color(0xFF2BB673);

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
    final text = Typography.blackMountainView
        .apply(
          fontFamily: AppFonts.body,
          bodyColor: ink,
          displayColor: ink,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          headlineMedium: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleLarge: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleMedium: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          bodyLarge: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 16,
            height: 1.35,
            color: ink,
          ),
          bodyMedium: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 16,
            height: 1.35,
            color: ink,
          ),
          labelLarge: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        );
    return ThemeData(
      colorScheme: scheme.copyWith(
        primary: const Color(0xFF2F7A5D),
        secondary: peach,
        surface: cream,
      ),
      scaffoldBackgroundColor: cream,
      useMaterial3: true,
      fontFamily: AppFonts.body,
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: text.titleLarge,
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
          textStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(fontFamily: AppFonts.body),
        hintStyle: TextStyle(fontFamily: AppFonts.body),
      ),
    );
  }
}
