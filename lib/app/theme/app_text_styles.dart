import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 44,
    height: 1.06,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.25,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
  );
  static const TextStyle headingLarge = TextStyle(
    fontSize: 30,
    height: 1.16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const TextStyle headingMedium = TextStyle(
    fontSize: 25,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const TextStyle headingSmall = TextStyle(
    fontSize: 21,
    height: 1.26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.15,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle button = TextStyle(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle metric = TextStyle(
    fontSize: 38,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
