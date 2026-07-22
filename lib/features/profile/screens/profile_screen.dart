import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../models/resident_profile.dart';
import '../providers/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileStateProvider);
    return AdaptivePageScaffold(
      title: 'Account',
      subtitle:
          'Your verified identity, activity shortcuts, privacy, and support in one secure place.',
      body: _body(state),
    );
  }

  Widget _body(ProfileState state) {
    if (state.profile == null && state.phase == ProfilePhase.loading) {
      return const AppLoadingView(message: 'Loading your profile…');
    }
    if (state.profile == null) {
      return AppErrorView(
        title: 'Profile unavailable',
        message:
            state.message ?? 'Your profile information could not be loaded.',
        retryLabel: 'Try again',
        onRetry: () => ref.read(profileControllerProvider).load(refresh: true),
      );
    }
    final profile = state.profile!;
    return RefreshIndicator(
      onRefresh: () => ref.read(profileControllerProvider).load(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ProfileHeader(profile: profile),
          if (state.stale || state.message != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            MaterialBanner(
              content: Text(
                state.message ?? 'Showing saved profile information.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      ref.read(profileControllerProvider).load(refresh: true),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Account',
            children: [
              _tile(
                Icons.person_outline,
                'Personal information',
                'View verified resident details',
                AppRoutes.personalInformationPath,
              ),
              _tile(
                Icons.edit_outlined,
                'Edit profile',
                'Update your phone number or profile photo',
                AppRoutes.editProfilePath,
              ),
              _tile(
                Icons.password_rounded,
                'Change password',
                'Update your account password securely',
                AppRoutes.changePasswordPath,
              ),
              _tile(
                Icons.badge_outlined,
                'Digital Resident ID',
                'View your verified resident ID',
                AppRoutes.residentIdPath,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'Activity and preferences',
            children: [
              _tile(
                Icons.notifications_outlined,
                'Notification Center',
                'View announcements and resident updates',
                AppRoutes.notificationsPath,
              ),
              _tile(
                Icons.leaderboard_outlined,
                'Leaderboard',
                'View resident and barangay rankings',
                AppRoutes.leaderboardPath,
              ),
              _tile(
                Icons.military_tech_outlined,
                'Achievements',
                'View verified badges and progress',
                AppRoutes.achievementsPath,
              ),
              _tile(
                Icons.receipt_long_outlined,
                'Redemption requests',
                'Track reward request status',
                AppRoutes.redemptionHistoryPath,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'Information',
            children: [
              _tile(
                Icons.help_outline,
                'Help Center',
                'View available support information',
                AppRoutes.helpCenterPath,
              ),
              _tile(
                Icons.gavel_outlined,
                'Legal information',
                'View available legal documents',
                AppRoutes.legalInformationPath,
              ),
              _tile(
                Icons.info_outline,
                'About E-KOLEK',
                'App information and version',
                AppRoutes.aboutPath,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: ref.watch(authControllerProvider).isLoggingOut
                ? null
                : _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, String path) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.mediumBorderRadius,
        ),
        child: Icon(icon, size: 21),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(path),
    );
  }

  Future<void> _logout() async {
    final confirmed = await ErrorFeedback.showConfirmation(
      context,
      title: 'Sign out?',
      message:
          'You will need to enter your login details to access E-KOLEK again.',
      confirmLabel: 'Sign Out',
    );
    if (confirmed) await ref.read(authControllerProvider).logout();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final ResidentProfile profile;

  @override
  Widget build(BuildContext context) {
    final image = profile.photoUrl;
    return AppCard(
      elevated: true,
      backgroundColor: AppColors.primaryDark,
      borderColor: AppColors.primaryDark,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onBrandMuted, width: 2),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.white.withValues(alpha: 0.14),
              foregroundColor: AppColors.white,
              backgroundImage: image == null || image.isEmpty
                  ? null
                  : CachedNetworkImageProvider(image),
              child: image == null || image.isEmpty
                  ? const Icon(Icons.person_rounded, size: 38)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onBrandMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smMd,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: AppRadius.circularBorderRadius,
                  ),
                  child: Text(
                    '${_statusLabel(profile.approvalStatus.value)} resident',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: AppColors.onBrandMuted,
            size: 28,
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String value) {
    final normalized = value.toLowerCase();
    return normalized.isEmpty
        ? 'Unknown'
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: .8,
            ),
          ),
        ),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1)
            const Divider(indent: 64, endIndent: AppSpacing.md),
        ],
      ],
    ),
  );
}
