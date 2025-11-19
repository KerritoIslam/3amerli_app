import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  // Larger, bolder button style used as default for primary buttons
  static const TextStyle buttonLargeBold = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
  );

  // Small helper styles
  static const TextStyle small = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
  );
}
