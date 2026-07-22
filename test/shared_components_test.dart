import 'dart:async';

import 'package:ekolek_app/app/theme/app_layout.dart';
import 'package:ekolek_app/app/theme/app_theme.dart';
import 'package:ekolek_app/core/widgets/adaptive_page_scaffold.dart';
import 'package:ekolek_app/core/widgets/app_async_button.dart';
import 'package:ekolek_app/core/widgets/app_content_width.dart';
import 'package:ekolek_app/core/widgets/app_empty_state.dart';
import 'package:ekolek_app/core/widgets/app_error_view.dart';
import 'package:ekolek_app/core/widgets/app_network_image.dart';
import 'package:ekolek_app/core/widgets/app_offline_view.dart';
import 'package:ekolek_app/core/widgets/app_section_header.dart';
import 'package:ekolek_app/core/widgets/app_skeleton.dart';
import 'package:ekolek_app/core/widgets/app_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(
    Widget child, {
    Size size = const Size(400, 800),
    bool reduceMotion = false,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('empty state renders copy and optional actions', (tester) async {
    await tester.pumpWidget(
      host(
        AppEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          message: 'Verified records will appear here.',
          actionLabel: 'Retry',
          onAction: () {},
          secondaryActionLabel: 'Back',
          onSecondaryAction: () {},
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Verified records will appear here.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('error and offline states expose safe recovery copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppErrorView(
          title: 'Unable to load',
          message: 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () {},
        ),
      ),
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.pumpWidget(
      host(
        AppOfflineView(
          hasStaleData: true,
          lastUpdated: DateTime(2026, 7, 22),
          onRetry: () {},
        ),
      ),
    );
    expect(find.textContaining('previously loaded'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
  });

  testWidgets('skeleton stops animating when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const AppSkeleton(height: 24), reduceMotion: true),
    );
    final transition = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(AppSkeleton),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(transition.opacity.value, 0.9);
  });

  testWidgets('unknown status uses neutral text and semantics', (tester) async {
    await tester.pumpWidget(host(const AppStatusChip(label: 'Unknown')));
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.bySemanticsLabel('Status: Unknown'), findsOneWidget);
  });

  testWidgets('async button prevents duplicate taps', (tester) async {
    final pending = Completer<void>();
    var taps = 0;
    await tester.pumpWidget(
      host(
        AppAsyncButton(
          label: 'Save',
          onPressed: () {
            taps++;
            return pending.future;
          },
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.tap(find.text('Please wait…'));
    expect(taps, 1);
    pending.complete();
    await tester.pump();
  });

  testWidgets('network image provides a safe fallback without a URL', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const AppNetworkImage(
          url: null,
          semanticLabel: 'Reward image',
          width: 120,
          height: 80,
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('Reward image')), findsWidgets);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('content width constrains tablet layouts', (tester) async {
    await tester.pumpWidget(
      host(
        const AppContentWidth(child: SizedBox.expand()),
        size: const Size(1400, 900),
      ),
    );
    final constrained = tester.widgetList<ConstrainedBox>(
      find.byType(ConstrainedBox),
    );
    expect(
      constrained.any(
        (widget) => widget.constraints.maxWidth == AppLayout.maxContentWidth,
      ),
      isTrue,
    );
  });

  testWidgets('section header supports a long title and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppSectionHeader(
          title: 'A long resident-facing section title that wraps safely',
          subtitle: 'Supporting information remains readable.',
          actionLabel: 'View all',
          onAction: () {},
        ),
        size: const Size(280, 600),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('View all'), findsOneWidget);
  });

  testWidgets('shared page header remains usable with large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2),
          ),
          child: const AdaptivePageScaffold(
            title: 'Resident information and application settings',
            subtitle: 'Manage verified information safely.',
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
