import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';

class ApprovedWelcomeScreen extends ConsumerStatefulWidget {
  const ApprovedWelcomeScreen({super.key});

  @override
  ConsumerState<ApprovedWelcomeScreen> createState() =>
      _ApprovedWelcomeScreenState();
}

class _ApprovedWelcomeScreenState extends ConsumerState<ApprovedWelcomeScreen> {
  bool _completing = false;

  Future<void> _continue() async {
    if (_completing) return;
    setState(() => _completing = true);
    await ref.read(accountStatusControllerProvider).completeWelcome();
    if (mounted) context.go(AppRoutes.homePath);
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(currentAccountStatusInfoProvider)?.displayName;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Semantics(
                liveRegion: true,
                label: 'Your E-KOLEK resident account is approved.',
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 72,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          name == null
                              ? 'Welcome to E-KOLEK'
                              : 'Welcome, $name',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Your resident account has been approved. You can now explore recycling activities, learning content, eco-games, rewards, and your resident profile.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _completing ? null : _continue,
                            icon: _completing
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              _completing
                                  ? 'Opening E-KOLEK…'
                                  : 'Continue to Home',
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
        ),
      ),
    );
  }
}
