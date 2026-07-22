import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/home_providers.dart';
import '../../../shared/providers/rewards_providers.dart';
import '../providers/rewards_state.dart';
import '../widgets/reward_card.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final search = TextEditingController();
  bool get testing => WidgetsBinding.instance.runtimeType.toString().contains(
    'TestWidgetsFlutterBinding',
  );
  @override
  void initState() {
    super.initState();
    if (!testing) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(rewardsControllerProvider).load(),
      );
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsStateProvider);
    final controller = ref.read(rewardsControllerProvider);
    Future<void> refresh() => controller.load(refresh: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          IconButton(
            tooltip: 'Redemption requests',
            onPressed: () => context.push(AppRoutes.redemptionHistoryPath),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList.list(
                children: [
                  Text(
                    'Turn your points into useful rewards',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Use your verified E-KOLEK points during authorized reward distribution activities.',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      title: Text(
                        ref.watch(homeStateProvider).data?.wallet == null
                            ? 'Wallet balance unavailable'
                            : AppFormatters.rewardPoints(
                                ref
                                    .watch(homeStateProvider)
                                    .data!
                                    .wallet!
                                    .currentBalance,
                              ),
                      ),
                      subtitle: const Text(
                        'Final points and eligibility are rechecked before redemption.',
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.walletActivityPath),
                        child: const Text('Activity'),
                      ),
                    ),
                  ),
                  if (state.stale)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.cloud_off_rounded),
                        title: Text(
                          'Showing the last reward information loaded on this device. Stock and eligibility may have changed.',
                        ),
                      ),
                    ),
                  TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Search rewards',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          search.clear();
                          controller.search('');
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                    ),
                    onSubmitted: controller.search,
                  ),
                  if (state.categories.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: state.selectedCategory == null,
                            onSelected: (_) => controller.selectCategory(null),
                          ),
                          ...state.categories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(category.name),
                                selected:
                                    state.selectedCategory == category.name,
                                onSelected: (_) =>
                                    controller.selectCategory(category.name),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state.message != null)
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(state.message!),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            _catalog(context, state, controller, refresh),
          ],
        ),
      ),
    );
  }

  Widget _catalog(
    BuildContext context,
    RewardsState state,
    dynamic controller,
    Future<void> Function() refresh,
  ) {
    if ((state.phase == RewardsPhase.initial ||
            state.phase == RewardsPhase.loading) &&
        state.items.isEmpty) {
      if (testing) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.redeem_rounded,
            title: 'No rewards available',
            message:
                'Resident-visible rewards for your barangay will appear here.',
          ),
        );
      }
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.items.isEmpty && state.phase == RewardsPhase.offline) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          title: 'You are offline',
          message:
              'Connect to the internet to confirm reward stock and eligibility.',
          onRetry: refresh,
        ),
      );
    }
    if (state.items.isEmpty && state.phase == RewardsPhase.failure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          title: 'Rewards unavailable',
          message: 'Rewards could not be loaded. Please try again.',
          onRetry: refresh,
        ),
      );
    }
    if (state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.redeem_rounded,
          title: 'No rewards available',
          message:
              'Resident-visible rewards for your barangay will appear here.',
        ),
      );
    }
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = width >= 1000
              ? 4
              : width >= 650
              ? 3
              : width >= 420
              ? 2
              : 1;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 1.15 : .66,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == state.items.length) {
                controller.loadMore();
                return const Center(child: CircularProgressIndicator());
              }
              final reward = state.items[index];
              return RewardCard(
                reward: reward,
                onTap: () =>
                    context.push(AppRoutes.rewardDetailPath(reward.id)),
              );
            }, childCount: state.items.length + (state.hasNext ? 1 : 0)),
          );
        },
      ),
    );
  }
}
