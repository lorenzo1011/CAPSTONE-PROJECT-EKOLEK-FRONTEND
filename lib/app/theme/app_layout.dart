class AppLayout {
  AppLayout._();

  static const double compactBreakpoint = 360;
  static const double tabletBreakpoint = 720;
  static const double dashboardBreakpoint = 900;
  static const double wideBreakpoint = 1180;

  static const double maxContentWidth = 1180;
  static const double maxReadingWidth = 760;
  static const double maxFormWidth = 600;

  static const double minimumTouchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double navigationBarHeight = 72;
  static const double navigationRailWidth = 232;
  static const double compactNavigationRailWidth = 88;

  static const double iconSmall = 18;
  static const double iconMedium = 22;
  static const double iconLarge = 28;
  static const double iconHero = 44;

  static const double dashboardColumnGap = 24;
  static const double dashboardCardMinHeight = 128;

  static double horizontalPagePadding(double width) {
    if (width >= wideBreakpoint) return 40;
    if (width >= tabletBreakpoint) return 32;
    return 16;
  }
}
