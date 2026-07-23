import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/connectivity_service.dart';
import '../shared/providers/core_providers.dart';
import 'theme/app_colors.dart';
import 'theme/app_layout.dart';
import 'theme/app_radius.dart';
import 'theme/app_motion.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double tabletBreakpoint = AppLayout.tabletBreakpoint;

  static const _destinations = [
    _AppDestination('Home', Icons.home_outlined, Icons.home_rounded),
    _AppDestination(
      'Learn',
      Icons.auto_stories_outlined,
      Icons.auto_stories_rounded,
    ),
    _AppDestination('Games', Icons.extension_outlined, Icons.extension_rounded),
    _AppDestination('Rewards', Icons.redeem_outlined, Icons.redeem_rounded),
    _AppDestination(
      'Profile',
      Icons.person_outline_rounded,
      Icons.person_rounded,
    ),
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

        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          body: Column(
            children: [
              _OfflineBanner(visible: isOffline),
              Expanded(child: navigationShell),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.subtleShadow,
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _selectDestination,
                destinations: _destinations
                    .map(
                      (destination) => NavigationDestination(
                        icon: destination.label == 'Games'
                            ? const _GamesNavigationIcon(selected: false)
                            : Icon(destination.icon),
                        selectedIcon: destination.label == 'Games'
                            ? const _GamesNavigationIcon(selected: true)
                            : Icon(destination.selectedIcon),
                        label: destination.label,
                        tooltip: destination.label,
                      ),
                    )
                    .toList(),
              ),
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
    final scheme = Theme.of(context).colorScheme;
    final extended =
        MediaQuery.sizeOf(context).width >= AppLayout.wideBreakpoint;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(right: BorderSide(color: scheme.outlineVariant)),
              ),
              child: NavigationRail(
                extended: extended,
                minWidth: AppLayout.compactNavigationRailWidth,
                minExtendedWidth: AppLayout.navigationRailWidth,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: onDestinationSelected,
                groupAlignment: -0.7,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: AppRadius.mediumBorderRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Icon(
                            Icons.recycling_rounded,
                            color: scheme.onPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                      if (extended) ...[
                        const SizedBox(width: AppSpacing.smMd),
                        const Flexible(
                          child: Text(
                            'E-KOLEK',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: AppShell._destinations
                    .map(
                      (destination) => NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
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
  const _AppDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _GamesNavigationIcon extends StatelessWidget {
  const _GamesNavigationIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: const Offset(0, -11),
    child: AnimatedContainer(
      duration: AppMotion.fast,
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.white, width: 3),
      ),
      child: const Icon(
        Icons.sports_esports_rounded,
        color: AppColors.white,
        size: 25,
      ),
    ),
  );
}
