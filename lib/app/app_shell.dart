import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/connectivity_service.dart';
import '../shared/providers/core_providers.dart';
import 'theme/app_colors.dart';
import 'theme/app_layout.dart';
import 'theme/app_motion.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double tabletBreakpoint = AppLayout.tabletBreakpoint;

  static const _destinations = [
    _AppDestination('Home', Icons.home_rounded),
    _AppDestination('Learn', Icons.menu_book_rounded),
    _AppDestination('Games', Icons.sports_esports_rounded),
    _AppDestination('Rewards', Icons.card_giftcard_rounded),
    _AppDestination('Profile', Icons.person_rounded),
  ];

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref
        .watch(connectivityStatusProvider)
        .when(
          data: (status) => status == ConnectivityStatus.offline,
          error: (error, stackTrace) => false,
          loading: () => false,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return _TabletShell(
            navigationShell: navigationShell,
            onDestinationSelected: _selectDestination,
            isOffline: isOffline,
          );
        }

        return Scaffold(
          body: Column(
            children: [
              _OfflineBanner(visible: isOffline),
              Expanded(child: navigationShell),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _selectDestination,
              destinations: _destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                      tooltip: destination.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.navigationShell,
    required this.onDestinationSelected,
    required this.isOffline,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onDestinationSelected;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              extended: true,
              minExtendedWidth: AppLayout.navigationRailWidth,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: onDestinationSelected,
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.recycling_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'E-KOLEK',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: AppShell._destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  _OfflineBanner(visible: isOffline, includeTopSafeArea: false),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.visible, this.includeTopSafeArea = true});

  final bool visible;
  final bool includeTopSafeArea;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      top: includeTopSafeArea,
      bottom: false,
      child: AnimatedSize(
        duration: reduceMotion ? Duration.zero : AppMotion.standard,
        curve: AppMotion.standardCurve,
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : AppMotion.fast,
          child: visible
              ? Semantics(
                  key: const ValueKey('offline-banner'),
                  container: true,
                  liveRegion: true,
                  label:
                      'You appear to be offline. Some features may be unavailable.',
                  child: Container(
                    width: double.infinity,
                    color: AppColors.warning,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            'You appear to be offline. Some features may be unavailable.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('online-banner')),
        ),
      ),
    );
  }
}

class _AppDestination {
  const _AppDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
