import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_empty_state.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Semantics(
            label: 'Page not found',
            child: AppEmptyState(
              icon: Icons.explore_off_rounded,
              title: 'Page not found',
              message: 'The page you requested is unavailable.',
              actionLabel: 'Return to Home',
              onAction: () => context.goNamed(AppRoutes.home),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}
