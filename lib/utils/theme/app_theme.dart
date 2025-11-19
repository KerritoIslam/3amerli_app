import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    splashColor: Colors.transparent,
    // Use the Geist font family for the whole app. Make sure the font files
    // are added to pubspec.yaml under the fonts section and placed in
    // assets/fonts/ (e.g. assets/fonts/Geist-Regular.ttf).
    fontFamily: 'Geist',
    colorScheme: AppColors.lightScheme,
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightScheme.surface,
      foregroundColor: AppColors.lightScheme.onSurface,
      elevation: 0,
      titleTextStyle:
          AppTextStyles.title.copyWith(color: AppColors.lightScheme.onSurface),
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
    extensions: const [BrandColors.light],
  );

  static final ThemeData dark = ThemeData(
    // Use the Geist font family for the whole app.
    splashColor: Colors.transparent,
    fontFamily: 'Geist',
    colorScheme: AppColors.darkScheme,
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkScheme.surface,
      foregroundColor: AppColors.darkScheme.onSurface,
      elevation: 0,
      titleTextStyle:
          AppTextStyles.title.copyWith(color: AppColors.darkScheme.onSurface),
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
    extensions: const [BrandColors.dark],
  );
}
