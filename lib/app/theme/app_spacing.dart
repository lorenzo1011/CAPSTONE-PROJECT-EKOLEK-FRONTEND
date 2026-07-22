import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double smMd = 12;
  static const double md = 16;
  static const double mdLg = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 40;
  static const double xxl = 48;
  static const double section = 28;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: mdLg,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: lg);
}
