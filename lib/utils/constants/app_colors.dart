import 'package:flutter/material.dart';

/// AppColors provides app-wide color schemes for light and dark mode.
/// For now the design uses black and white as the main colors. More
/// brand colors can be added later.
class AppColors {
  AppColors._();

  // Light theme colors (black on white)
  static const Color lightPrimary = Colors.black;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black87;

  // Dark theme colors (white on black)
  static const Color darkPrimary = Colors.white;
  static const Color darkOnPrimary = Colors.black;
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white70;

  // Additional neutral colors
  static const Color greyBorder = Color(0xFFBDBDBD); // neutral grey for borders

  // Convenience ColorSchemes
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    secondary: lightPrimary,
    onSecondary: lightOnPrimary,
    error: lightError,
    onError: Colors.white,
    background: lightBackground,
    onBackground: lightOnBackground,
    surface: lightSurface,
    onSurface: lightOnSurface,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    secondary: darkPrimary,
    onSecondary: darkOnPrimary,
    error: darkError,
    onError: Colors.black,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
  );
}
