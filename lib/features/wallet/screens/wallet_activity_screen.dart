import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/home_providers.dart';
import '../../home/widgets/recent_point_activity.dart';

class WalletActivityScreen extends ConsumerStatefulWidget {
  const WalletActivityScreen({super.key});

  @override
  ConsumerState<WalletActivityScreen> createState() =>
      _WalletActivityScreenState();
}

class _WalletActivityScreenState extends ConsumerState<WalletActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletActivityControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(walletActivityControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet activity')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.load(refresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            children: [
              Text(
                'Point history',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review points earned, redeemed, and adjusted on your account.',
              ),
              const SizedBox(height: 16),
              if (controller.loading && controller.items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (controller.items.isEmpty &&
                  controller.errorMessage != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: Text(controller.errorMessage!),
                    trailing: IconButton(
                      tooltip: 'Retry',
                      onPressed: controller.load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                )
              else ...[
                if (controller.errorMessage != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(controller.errorMessage!),
                    ),
                  ),
                Card(child: RecentPointActivity(items: controller.items)),
                const SizedBox(height: 12),
                if (controller.hasNext)
                  Center(
                    child: FilledButton.tonalIcon(
                      onPressed: controller.loadingMore
                          ? null
                          : controller.load,
                      icon: controller.loadingMore
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.expand_more_rounded),
                      label: Text(
                        controller.loadingMore
                            ? 'Loading more'
                            : 'Load more activity',
                      ),
                    ),
                  )
                else if (controller.items.isNotEmpty)
                  Text(
                    'All ${controller.items.length} activities loaded • ${AppFormatters.dateTime(DateTime.now())}',
                    textAlign: TextAlign.center,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
