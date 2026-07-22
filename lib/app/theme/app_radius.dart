import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 24;
  static const double circular = 999;

  static final BorderRadius smallBorderRadius = BorderRadius.circular(small);
  static final BorderRadius mediumBorderRadius = BorderRadius.circular(medium);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(large);
  static final BorderRadius extraLargeBorderRadius = BorderRadius.circular(
    extraLarge,
  );
  static final BorderRadius circularBorderRadius = BorderRadius.circular(
    circular,
  );
}
