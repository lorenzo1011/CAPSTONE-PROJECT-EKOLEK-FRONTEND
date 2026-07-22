import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';
import '../models/resident_account_status.dart';
import '../providers/account_status_state.dart';

class AccountStatusScreen extends ConsumerStatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  ConsumerState<AccountStatusScreen> createState() =>
      _AccountStatusScreenState();
}

class _AccountStatusScreenState extends ConsumerState<AccountStatusScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(accountStatusControllerProvider).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountStatusStateProvider);
    final authUser = ref.watch(currentAuthUserProvider);
    final status =
        state.info?.status ??
        ResidentAccountStatus.fromBackend(authUser?.approvalStatus.value);
    final content = _contentFor(status, state.info?.rejectionReason);
    final controller = ref.watch(accountStatusControllerProvider);
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refresh(manual: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Semantics(
                    liveRegion: true,
                    label: content.semanticLabel,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            Icon(content.icon, size: 64, color: content.color),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              content.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              content.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (state.lastSuccessfulRefresh != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Last checked ${DateFormat.yMMMd().add_jm().format(state.lastSuccessfulRefresh!.toLocal())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (state.message != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                state.message!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            if (state.phase ==
                                AccountStatusPhase.refreshing) ...[
                              const SizedBox(height: AppSpacing.md),
                              const LinearProgressIndicator(),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: state.isBusy
                                    ? null
                                    : () => controller.refresh(manual: true),
                                icon: state.isBusy
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh_rounded),
                                label: Text(
                                  state.isBusy ? 'Checking…' : 'Refresh Status',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: authController.isLoggingOut
                                    ? null
                                    : () async {
                                        controller.reset();
                                        await authController.logout();
                                      },
                                icon: const Icon(Icons.logout_rounded),
                                label: Text(
                                  authController.isLoggingOut
                                      ? 'Signing out…'
                                      : 'Sign Out',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusContent _contentFor(
    ResidentAccountStatus status,
    String? reason,
  ) => switch (status) {
    ResidentAccountStatus.pending => const _StatusContent(
      Icons.hourglass_top_rounded,
      'Account review in progress',
      'Your resident registration is awaiting CENRO review. Refresh your status after an administrator reviews your application.',
      AppColors.primary,
      'Resident account status: pending review.',
    ),
    ResidentAccountStatus.rejected => _StatusContent(
      Icons.assignment_late_outlined,
      'Registration needs attention',
      reason == null
          ? 'Your registration was not approved. Please contact CENRO for assistance.'
          : 'Your registration was not approved. $reason',
      Theme.of(context).colorScheme.error,
      'Resident account status: registration not approved.',
    ),
    ResidentAccountStatus.suspended => _StatusContent(
      Icons.pause_circle_outline_rounded,
      'Account access suspended',
      'Resident app access is currently unavailable. Please contact CENRO for assistance.',
      Theme.of(context).colorScheme.error,
      'Resident account status: suspended.',
    ),
    ResidentAccountStatus.approved ||
    ResidentAccountStatus.unknown => const _StatusContent(
      Icons.verified_user_outlined,
      'Account verification required',
      'E-KOLEK could not confirm resident access. Refresh your status or sign out and try again.',
      AppColors.primary,
      'Resident account status could not be confirmed.',
    ),
  };
}

class _StatusContent {
  const _StatusContent(
    this.icon,
    this.title,
    this.message,
    this.color,
    this.semanticLabel,
  );
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String semanticLabel;
}
