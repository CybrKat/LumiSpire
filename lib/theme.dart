/// LumiSpire - the visual theme.
///
/// A bright, friendly "explorer" look: an indigo/teal seed with sunny amber
/// accents, big rounded shapes and chunky, tappable controls that feel like a
/// game rather than a form. Shared across light and dark so only the derived
/// [ColorScheme] changes.

library;

import 'package:flutter/material.dart';

/// The indigo seed the palette grows from.
const Color lumiSeed = Color(0xFF4361EE);

const double _radius = 24.0;

ThemeData buildLumiTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: lumiSeed,
    brightness: brightness,
    secondary: const Color(0xFF2EC4B6),
    tertiary: const Color(0xFFF4A259),
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.comfortable,
    scaffoldBackgroundColor: scheme.surface,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
  );
}

ThemeData get lumiLightTheme => buildLumiTheme(Brightness.light);
ThemeData get lumiDarkTheme => buildLumiTheme(Brightness.dark);
