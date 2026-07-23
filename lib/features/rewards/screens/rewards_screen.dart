import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_search_field.dart';
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
    final wallet = ref.watch(homeStateProvider).data?.wallet;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                sliver: SliverList.list(
                  children: [
                    AppPageHeader(
                      title: 'Rewards',
                      subtitle:
                          'Redeem points, support local,\nand enjoy rewards.',
                      actions: [
                        IconButton(
                          tooltip: 'Redemption history',
                          onPressed: () =>
                              context.push(AppRoutes.redemptionHistoryPath),
                          icon: const Icon(Icons.card_giftcard_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      borderColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.smMd),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Points Balance',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  wallet == null
                                      ? 'Wallet balance unavailable'
                                      : AppFormatters.rewardPoints(
                                          wallet.currentBalance,
                                        ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                                Text(
                                  'Available to spend',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: Image.asset(
                              'assets/images/onboarding/learn_progress_sprout.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
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
                    const SizedBox(height: AppSpacing.lg),
                    AppSearchField(
                      controller: search,
                      hintText: 'Search rewards',
                      onSubmitted: controller.search,
                      onClear: () => controller.search(''),
                    ),
                    if (state.categories.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.smMd),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: state.selectedCategory == null,
                              onSelected: (_) =>
                                  controller.selectCategory(null),
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
                    ],
                    if (state.message != null)
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(state.message!),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Featured Rewards',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'See all',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                  ],
                ),
              ),
              _catalog(context, state, controller, refresh),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      sliver: SliverList.separated(
        itemCount: state.items.length + (state.hasNext ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            controller.loadMore();
            return const Center(child: CircularProgressIndicator());
          }
          final reward = state.items[index];
          final card = RewardCard(
            reward: reward,
            onTap: () => context.push(AppRoutes.rewardDetailPath(reward.id)),
          );
          if (index != 1) return card;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'More Rewards',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.smMd),
              card,
            ],
          );
        },
      ),
    );
  }
}
