import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? AppColors.primaryLight : AppColors.primary,
      onPrimary: dark ? AppColors.onPrimaryContainer : AppColors.white,
      primaryContainer: dark
          ? const Color(0xFF164B39)
          : AppColors.primaryContainer,
      onPrimaryContainer: dark
          ? const Color(0xFFD9F5E7)
          : AppColors.onPrimaryContainer,
      secondary: dark ? const Color(0xFF8ACBD0) : AppColors.secondary,
      onSecondary: dark ? const Color(0xFF073D43) : AppColors.white,
      secondaryContainer: dark
          ? const Color(0xFF174A50)
          : AppColors.secondaryContainer,
      onSecondaryContainer: dark
          ? const Color(0xFFD5F3F4)
          : AppColors.onSecondaryContainer,
      tertiary: dark ? const Color(0xFFF0C66C) : AppColors.accent,
      onTertiary: dark ? const Color(0xFF4C3600) : AppColors.textPrimary,
      error: dark ? const Color(0xFFFFB4AB) : AppColors.error,
      onError: dark ? const Color(0xFF690005) : AppColors.white,
      errorContainer: dark ? const Color(0xFF7E2F2F) : AppColors.errorContainer,
      onErrorContainer: dark
          ? const Color(0xFFFFDAD6)
          : const Color(0xFF5E1515),
      surface: dark ? AppColors.darkSurface : AppColors.surface,
      onSurface: dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      surfaceContainerHighest: dark
          ? AppColors.darkSurfaceVariant
          : AppColors.surfaceVariant,
      onSurfaceVariant: dark
          ? AppColors.darkTextSecondary
          : AppColors.textSecondary,
      outline: dark ? AppColors.darkBorder : AppColors.border,
      outlineVariant: dark ? const Color(0xFF29372F) : AppColors.divider,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: dark ? AppColors.surface : AppColors.textPrimary,
      onInverseSurface: dark
          ? AppColors.textPrimary
          : AppColors.darkTextPrimary,
      inversePrimary: dark ? AppColors.primary : AppColors.primaryLight,
    );
    final textTheme = const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headingLarge,
      headlineMedium: AppTextStyles.headingMedium,
      headlineSmall: AppTextStyles.headingSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.caption,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.mediumBorderRadius,
      borderSide: BorderSide(color: scheme.outline),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: AppRadius.largeBorderRadius,
      side: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? AppColors.darkBackground
          : AppColors.background,
      canvasColor: dark ? AppColors.darkBackground : AppColors.background,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: AppColors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        titleSpacing: AppSpacing.md,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppLayout.minimumTouchTarget,
            AppLayout.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
          ),
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppLayout.minimumTouchTarget,
            AppLayout.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppLayout.minimumTouchTarget,
            AppLayout.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppLayout.minimumTouchTarget,
            AppLayout.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          foregroundColor: scheme.primary,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppLayout.minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkSurface : AppColors.surface,
        constraints: const BoxConstraints(minHeight: AppLayout.inputHeight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumBorderRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumBorderRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumBorderRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minTileHeight: 60,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: AppTextStyles.titleSmall.copyWith(
          color: scheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorderRadius,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppLayout.navigationBarHeight,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: AppColors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppLayout.iconMedium,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: scheme.primary,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularBorderRadius,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 8,
        shadowColor: AppColors.cardShadow,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.extraLargeBorderRadius,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark
            ? AppColors.darkSurfaceVariant
            : AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        actionTextColor: dark ? AppColors.primaryLight : AppColors.onBrandMuted,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorderRadius,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 7,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTextStyles.labelMedium),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.mediumBorderRadius),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: scheme.outlineVariant,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeBorderRadius,
        ),
      ),
    );
  }
}
