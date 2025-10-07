import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    colorScheme: AppColors.lightScheme,
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightScheme.background,
    primaryColor: AppColors.blackSwatch[900],
    primarySwatch: AppColors.blackSwatch,
    dividerColor: AppColors.greySwatch[300],
  hintColor: const Color(0xFFD3D3D3),
    // Remove ripple/splash effects (transparent) for a cleaner touch feel
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightScheme.surface,
      foregroundColor: AppColors.lightScheme.onSurface,
      elevation: 0,
      titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.lightScheme.onSurface),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1,
      headlineMedium: AppTextStyles.headline2,
      titleLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodyBold,
      bodySmall: AppTextStyles.caption,
      labelSmall: AppTextStyles.small,
    ),
    iconTheme: IconThemeData(color: AppColors.lightScheme.onSurface),
  );

  static final ThemeData dark = ThemeData(

    colorScheme: AppColors.darkScheme,
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkScheme.background,
    primaryColor: AppColors.blackSwatch[50],
    primarySwatch: AppColors.blackSwatch,
    dividerColor: AppColors.greySwatch[700],
  hintColor: const Color(0xFFD3D3D3),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkScheme.surface,
      foregroundColor: AppColors.darkScheme.onSurface,
      elevation: 0,
      titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.darkScheme.onSurface),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1,
      headlineMedium: AppTextStyles.headline2,
      titleLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodyBold,
      bodySmall: AppTextStyles.caption,
      labelSmall: AppTextStyles.small,
    ),
    iconTheme: IconThemeData(color: AppColors.darkScheme.onSurface),
  );
}
