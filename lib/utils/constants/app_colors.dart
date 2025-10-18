import 'package:flutter/material.dart';

/// AppColors provides app-wide color schemes for light and dark mode.
/// For now the design uses black and white as the main colors. More
/// brand colors can be added later.
class AppColors {
  AppColors._();

  // Light theme colors (black on white)
  static const Color lightPrimary = Color(0xFFA3C335); // brand green
  static const Color lightOnPrimary = Colors.white;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black87;

  // Light theme additional tokens
  static const Color lightPrimaryContainer = Color(0xFFE0E0E0);
  
  static const Color lightOnPrimaryContainer = Colors.black;
  static const Color lightSecondary = Color(0xFFF8F9EB);
  static const Color lightOnSecondary = Colors.black; // maintain readable text on light secondary
  static const Color lightSecondaryContainer = Color(0xFFF5F5F5);
  static const Color lightOnSecondaryContainer = Colors.black;
  static const Color lightTertiary = Color(0xFFB00020);
  static const Color lightOnTertiary = Colors.white;
 static const Color lightTertiaryContainer = Color(0xFF04272D);
  static const Color lightOnTertiaryContainer = Colors.white;
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
  static const Color darkPrimary = Color(0xFFA3C335);
  static const Color darkOnPrimary = Colors.black;
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white70;

  // Dark theme additional tokens
  static const Color darkPrimaryContainer = Color(0xFF2A2A2A);
  static const Color darkOnPrimaryContainer = Colors.white;
  static const Color darkSecondary = Color(0xFFF8F9EB);
  static const Color darkOnSecondary = Colors.black; // readable on light secondary in dark mode
  static const Color darkSecondaryContainer = Color(0xFF1E1E1E);
  static const Color darkOnSecondaryContainer = Colors.white;
  static const Color darkTertiary = Color(0xFFCF6679);
  static const Color darkOnTertiary = Colors.black;
  static const Color darkTertiaryContainer = Color(0xFF04272D);
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
  // Brand / danger red requested: #C94949
  static const Color brandRed = Color(0xFFC94949);
  // Brand teal requested: #48A9A6
  static const Color brandTeal = Color(0xFF48A9A6);
  // Neutral light used for hints and subtle borders (#D3D3D3)
  static const Color neutralLight300 = Color(0xFFD3D3D3);
  // A convenient alias for UI hint color usage (match Theme.hintColor)
  static const Color hint = neutralLight300;

  // Disabled color (use neutral light grey)
  static const Color disabled = neutralLight300;

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

  // Theme extension to expose extra brand colors through Theme.of(context).extension<BrandColors>()
}

class BrandColors extends ThemeExtension<BrandColors> {
  final Color brandTeal;

  const BrandColors({required this.brandTeal});

  static const BrandColors light = BrandColors(brandTeal: AppColors.brandTeal);
  static const BrandColors dark = BrandColors(brandTeal: AppColors.brandTeal);

  @override
  BrandColors copyWith({Color? brandTeal}) {
    return BrandColors(brandTeal: brandTeal ?? this.brandTeal);
  }

  @override
  ThemeExtension<BrandColors> lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      brandTeal: Color.lerp(brandTeal, other.brandTeal, t) ?? brandTeal,
    );
  }
}
