import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double tiny = 6;
  static const double small = 10;
  static const double medium = 16;
  static const double large = 22;
  static const double extraLarge = 28;
  static const double hero = 30;
  static const double circular = 999;

  static final BorderRadius tinyBorderRadius = BorderRadius.circular(tiny);
  static final BorderRadius smallBorderRadius = BorderRadius.circular(small);
  static final BorderRadius mediumBorderRadius = BorderRadius.circular(medium);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(large);
  static final BorderRadius extraLargeBorderRadius = BorderRadius.circular(
    extraLarge,
  );
  static final BorderRadius heroBorderRadius = BorderRadius.circular(hero);
  static final BorderRadius circularBorderRadius = BorderRadius.circular(
    circular,
  );
}
