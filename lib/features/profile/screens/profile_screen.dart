import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_reveal.dart';
import '../../../shared/providers/achievements_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/home_providers.dart';
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
      if (mounted) _loadProfileData();
    });
  }

  Future<void> _loadProfileData({bool refresh = false}) async {
    final futures = <Future<void>>[
      ref.read(profileControllerProvider).load(refresh: refresh),
      ref.read(achievementsControllerProvider).load(refresh: refresh),
    ];
    final user = ref.read(currentAuthUserProvider);
    if (user != null) {
      futures.add(
        ref
            .read(homeControllerProvider)
            .load(user, refresh: refresh)
            .then((_) {}),
      );
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileStateProvider);
    return AdaptivePageScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          tooltip: 'Profile settings',
          onPressed: () => context.push(AppRoutes.editProfilePath),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
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
        onRetry: () => _loadProfileData(refresh: true),
      );
    }

    final profile = state.profile!;
    final points = ref.watch(homeStateProvider).data?.wallet?.currentBalance;
    final badges = ref.watch(achievementsStateProvider).summary?.totalUnlocked;
    return RefreshIndicator(
      onRefresh: () => _loadProfileData(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          AppReveal(
            child: _ProfileOverview(
              profile: profile,
              points: points,
              badges: badges,
            ),
          ),
          if (state.stale || state.message != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            _ProfileNotice(
              message: state.message ?? 'Showing saved profile information.',
              onRetry: () => _loadProfileData(refresh: true),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const AppReveal(
            delay: Duration(milliseconds: 70),
            child: _SectionLabel('Account'),
          ),
          const SizedBox(height: AppSpacing.smMd),
          AppReveal(
            delay: const Duration(milliseconds: 110),
            child: _ProfileMenuGroup(
              items: [
                _ProfileMenuItem(
                  icon: Icons.person_rounded,
                  iconColor: Color(0xFFFFA21A),
                  iconBackground: Color(0xFFFFF3DE),
                  title: 'Personal Information',
                  subtitle: 'View and update your details',
                  path: AppRoutes.personalInformationPath,
                ),
                _ProfileMenuItem(
                  icon: Icons.edit_rounded,
                  iconColor: Color(0xFF18A84B),
                  iconBackground: Color(0xFFE7F8E9),
                  title: 'Edit Profile',
                  subtitle: 'Update your photo and info',
                  path: AppRoutes.editProfilePath,
                ),
                _ProfileMenuItem(
                  icon: Icons.badge_outlined,
                  iconColor: Color(0xFF248BC1),
                  iconBackground: Color(0xFFEAF6FC),
                  title: 'Digital Resident ID',
                  subtitle: 'View your verified ID',
                  path: AppRoutes.residentIdPath,
                ),
                _ProfileMenuItem(
                  icon: Icons.link_rounded,
                  iconColor: Color(0xFF22A447),
                  iconBackground: Color(0xFFE8F8E9),
                  title: 'Change Password',
                  subtitle: 'Keep your account secure',
                  path: AppRoutes.changePasswordPath,
                ),
                _ProfileMenuItem(
                  icon: Icons.shield_outlined,
                  iconColor: Color(0xFF248BC1),
                  iconBackground: Color(0xFFEAF6FC),
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  path: AppRoutes.legalInformationPath,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: const Duration(milliseconds: 150),
            child: _ProfileMenuGroup(
              items: const [
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  iconColor: Color(0xFF2793C9),
                  iconBackground: Color(0xFFEAF6FC),
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  path: AppRoutes.helpCenterPath,
                ),
                _ProfileMenuItem(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.primary,
                  iconBackground: AppColors.primaryContainer,
                  title: 'About E-KOLEK',
                  subtitle: 'Learn more about the app',
                  path: AppRoutes.aboutPath,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppReveal(
            delay: const Duration(milliseconds: 190),
            child: Center(
              child: TextButton.icon(
                onPressed: ref.watch(authControllerProvider).isLoggingOut
                    ? null
                    : _logout,
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: Text(
                  ref.watch(authControllerProvider).isLoggingOut
                      ? 'Signing out…'
                      : 'Sign out',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.smMd,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({
    required this.profile,
    required this.points,
    required this.badges,
  });

  final ResidentProfile profile;
  final int? points;
  final int? badges;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 182,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4EFFF), Color(0xFFF1F8F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.largeBorderRadius,
                border: Border.all(color: const Color(0xFFF0E9FA)),
              ),
              child: _ResidentIdentity(profile: profile),
            ),
          ),
          Positioned(
            left: AppSpacing.smMd,
            right: AppSpacing.smMd,
            top: 126,
            child: _ProfileStats(points: points, badges: badges),
          ),
        ],
      ),
    );
  }
}

class _ResidentIdentity extends StatelessWidget {
  const _ResidentIdentity({required this.profile});
  final ResidentProfile profile;

  @override
  Widget build(BuildContext context) {
    final approved = profile.approvalStatus.value == 'APPROVED';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        52,
      ),
      child: Row(
        children: [
          _ProfileAvatar(photoUrl: profile.photoUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (approved) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF14953C),
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatusPill(status: profile.approvalStatus.value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? const _AvatarFallback()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => const _AvatarFallback(),
                errorWidget: (_, _, _) => const _AvatarFallback(),
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5F7EA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 50,
        color: Color(0xFF159447),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'APPROVED';
    final label = switch (status) {
      'APPROVED' => 'Approved Resident',
      'PENDING' => 'Pending Review',
      'REJECTED' => 'Review Required',
      'SUSPENDED' => 'Account Suspended',
      _ => 'Resident',
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: approved ? const Color(0xFFDDF4E0) : AppColors.primaryContainer,
        borderRadius: AppRadius.circularBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: approved ? const Color(0xFF147C32) : AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.points, required this.badges});
  final int? points;
  final int? badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(color: const Color(0xFFF0EBF5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileMetric(
              icon: Icons.energy_savings_leaf_rounded,
              value: points?.toString() ?? '—',
              label: 'Eco Points',
              color: const Color(0xFF13963E),
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _ProfileMetric(
              icon: Icons.shield_rounded,
              value: badges?.toString() ?? '—',
              label: 'Badges',
              color: const Color(0xFF13963E),
            ),
          ),
          const _MetricDivider(),
          const Expanded(
            child: _ProfileMetric(
              icon: Icons.local_fire_department_rounded,
              value: '—',
              label: 'Day Streak',
              color: Color(0xFFFF7A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 52, color: AppColors.divider);
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.items});
  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.subtleShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ProfileMenuRow(item: items[index]),
            if (index < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 62,
                endIndent: AppSpacing.md,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String path;
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.item});
  final _ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.title}. ${item.subtitle}',
      child: InkWell(
        onTap: () => context.push(item.path),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smMd,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 21),
                ),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryLight,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileNotice extends StatelessWidget {
  const _ProfileNotice({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: AppRadius.mediumBorderRadius,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.warning,
            size: 21,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
