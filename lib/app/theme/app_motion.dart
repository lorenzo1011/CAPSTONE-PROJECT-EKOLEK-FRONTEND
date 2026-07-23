import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration micro = Duration(milliseconds: 110);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration emphasized = Duration(milliseconds: 360);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration skeleton = Duration(milliseconds: 1200);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;
  static const Curve entranceCurve = Curves.easeOutQuart;
  static const Curve pressCurve = Curves.easeOutCubic;

  static Duration accessible(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
