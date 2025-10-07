import 'package:flutter/material.dart';

/// AppColors provides app-wide color schemes for light and dark mode.
/// For now the design uses black and white as the main colors. More
/// brand colors can be added later.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Color swatches (levels 50..900) to provide tonal variations for design.
  // These are additive and won't affect existing single-token constants.
  // Use these where a MaterialColor or shade lookup is helpful.
  // ---------------------------------------------------------------------------

  // Neutral / black swatch (from very light grey to pure black)
  static const Map<int, Color> _blackSwatch = {
    50: Color(0xFFF5F5F5),
    100: Color(0xFFEEEEEE),
    200: Color(0xFFE0E0E0),
    300: Color(0xFFBDBDBD),
    400: Color(0xFF9E9E9E),
    500: Color(0xFF757575),
    600: Color(0xFF616161),
    700: Color(0xFF424242),
    800: Color(0xFF212121),
    900: Color(0xFF000000),
  };

  // Red / error swatch
  static const Map<int, Color> _redSwatch = {
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFF44336),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB00020),
  };

  // Neutral grey swatch for surfaces and outlines
  static const Map<int, Color> _greySwatch = {
    50: Color(0xFFF9FAFB),
    100: Color(0xFFF2F4F6),
    200: Color(0xFFE6E9EE),
    300: Color(0xFFCDD6DE),
    400: Color(0xFFB7C4CF),
    500: Color(0xFF98A5B2),
    600: Color(0xFF6F7E8A),
    700: Color(0xFF4B5563),
    800: Color(0xFF374151),
    900: Color(0xFF111827),
  };

  // Public MaterialColor swatches
  static const MaterialColor blackSwatch = MaterialColor(0xFF000000, _blackSwatch);
  static const MaterialColor errorSwatch = MaterialColor(0xFFB00020, _redSwatch);
  static const MaterialColor greySwatch = MaterialColor(0xFF98A5B2, _greySwatch);

  // Light theme colors (black on white)
  static const Color lightPrimary = Colors.black;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black87;

  // Light theme additional tokens
  static const Color lightPrimaryContainer = Color(0xFFE0E0E0);
  static const Color lightOnPrimaryContainer = Colors.black;
  static const Color lightSecondary = Colors.black;
  static const Color lightOnSecondary = Colors.white;
  static const Color lightSecondaryContainer = Color(0xFFF5F5F5);
  static const Color lightOnSecondaryContainer = Colors.black;
  static const Color lightTertiary = Color(0xFFB00020);
  static const Color lightOnTertiary = Colors.white;
  static const Color lightTertiaryContainer = Color(0xFFEF9A9A);
  static const Color lightOnTertiaryContainer = Colors.black;
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410001);
  static const Color lightSurfaceVariant = Color(0xFFF2F2F4);
  static const Color lightOnSurfaceVariant = Colors.black87;
  static const Color lightOutline = Color(0xFFBDBDBD);
  static const Color lightShadow = Color(0xFF000000);
  static const Color lightInverseSurface = Color(0xFF121212);
  static const Color lightOnInverseSurface = Colors.white;
  static const Color lightInversePrimary = Colors.white;
  static const Color lightSurfaceTint = lightPrimary;

  // Dark theme colors (white on black)
  static const Color darkPrimary = Colors.white;
  static const Color darkOnPrimary = Colors.black;
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white70;

  // Dark theme additional tokens
  static const Color darkPrimaryContainer = Color(0xFF2A2A2A);
  static const Color darkOnPrimaryContainer = Colors.white;
  static const Color darkSecondary = Colors.white;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkSecondaryContainer = Color(0xFF1E1E1E);
  static const Color darkOnSecondaryContainer = Colors.white;
  static const Color darkTertiary = Color(0xFFCF6679);
  static const Color darkOnTertiary = Colors.black;
  static const Color darkTertiaryContainer = Color(0xFF5A2830);
  static const Color darkOnTertiaryContainer = Colors.white;
  static const Color darkErrorContainer = Color(0xFF8B1D1D);
  static const Color darkOnErrorContainer = Colors.white;
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkOnSurfaceVariant = Colors.white70;
  static const Color darkOutline = Color(0xFF3F3F3F);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkInverseSurface = Colors.white;
  static const Color darkOnInverseSurface = Colors.black;
  static const Color darkInversePrimary = Colors.black;
  static const Color darkSurfaceTint = darkPrimary;

  // Additional neutral colors
  static const Color greyBorder = Color(0xFFBDBDBD); // neutral grey for borders

  // Convenience ColorSchemes
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    error: lightError,
    onError: Colors.white,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    background: lightBackground,
    onBackground: lightOnBackground,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceVariant: lightSurfaceVariant,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    shadow: lightShadow,
    inverseSurface: lightInverseSurface,
    onInverseSurface: lightOnInverseSurface,
    inversePrimary: lightInversePrimary,
    surfaceTint: lightSurfaceTint,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
  error: darkError,
  onError: Colors.black,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceVariant: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    shadow: darkShadow,
    inverseSurface: darkInverseSurface,
    onInverseSurface: darkOnInverseSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
  );
}
