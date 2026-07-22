import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/rewards_providers.dart';
import '../models/redemption_preparation.dart';
import '../providers/reward_detail_state.dart';
import '../widgets/redemption_eligibility_card.dart';
import '../widgets/reward_image.dart';
import '../widgets/reward_quantity_selector.dart';
import '../widgets/reward_stock_indicator.dart';

class RewardDetailScreen extends ConsumerStatefulWidget {
  const RewardDetailScreen({super.key, required this.rewardId});
  final int rewardId;
  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool get testing => WidgetsBinding.instance.runtimeType.toString().contains(
    'TestWidgetsFlutterBinding',
  );
  @override
  void initState() {
    super.initState();
    if (!testing) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(rewardDetailControllerProvider(widget.rewardId)).load(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = rewardDetailControllerProvider(widget.rewardId);
    final controller = ref.read(provider);
    final state = ref.watch(provider).state;
    if (state.reward == null) {
      return Scaffold(
        appBar: AppBar(),
        body:
            state.phase == RewardDetailPhase.loading ||
                state.phase == RewardDetailPhase.initial
            ? const Center(child: CircularProgressIndicator())
            : AppErrorView(
                title: 'Reward unavailable',
                message:
                    state.message ?? 'This reward is currently unavailable.',
                onRetry: controller.load,
              ),
      );
    }
    final reward = state.reward!;
    final busy = state.phase == RewardDetailPhase.loadingPreview;
    return Scaffold(
      appBar: AppBar(title: Text(reward.name)),
      body: RefreshIndicator(
        onRefresh: () => controller.load(refresh: true),
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RewardImage(
                        name: reward.name,
                        url: reward.imageUrl,
                        heroTag: 'reward-${reward.id}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      reward.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (reward.category.isNotEmpty) Text(reward.category),
                    Text(
                      AppFormatters.rewardPoints(reward.pointsRequired),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    RewardStockIndicator(
                      availability: reward.availability,
                      quantity: reward.stock.availableQuantity,
                    ),
                    if (reward.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(reward.description),
                    ],
                    const Divider(height: 32),
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (reward.maximumQuantity > reward.minimumQuantity)
                      RewardQuantitySelector(
                        value: state.quantity,
                        minimum: reward.minimumQuantity,
                        maximum: reward.maximumQuantity,
                        onChanged: controller.setQuantity,
                      )
                    else
                      const Text('Quantity: 1'),
                    const SizedBox(height: 16),
                    Text(
                      'Points preview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${AppFormatters.rewardPoints(reward.pointsRequired)} × ${state.quantity}',
                      ),
                      trailing: Text(
                        AppFormatters.rewardPoints(
                          reward.pointsRequired * state.quantity,
                        ),
                      ),
                      subtitle: const Text(
                        'Preview only. Your wallet has not been changed.',
                      ),
                    ),
                    if (reward.requiresRewardEvent) ...[
                      Text(
                        'Reward Distribution Event',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.events.isEmpty)
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.event_busy_rounded),
                          title: Text('No active eligible event'),
                          subtitle: Text(
                            'A valid Reward Distribution Event is required for this redemption.',
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          initialValue: state.selectedEvent?.id,
                          decoration: const InputDecoration(
                            labelText: 'Active event',
                          ),
                          items: state.events
                              .map(
                                (event) => DropdownMenuItem(
                                  value: event.id,
                                  child: Text(
                                    event.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            final event = state.events
                                .where((item) => item.id == id)
                                .firstOrNull;
                            if (event != null) controller.selectEvent(event);
                          },
                        ),
                    ],
                    RedemptionEligibilityCard(
                      value: state.eligibility,
                      checking:
                          state.phase == RewardDetailPhase.checkingEligibility,
                    ),
                    if (state.message != null)
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(state.message!),
                      ),
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.badge_outlined),
                        title: Text('How redemption works'),
                        subtitle: Text(
                          'Present your physical E-KOLEK Resident ID during an authorized event. Points and stock are finalized only after a successful redemption transaction.',
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: !busy && state.eligibility?.eligible == true
                          ? () async {
                              final preview = await controller.prepare();
                              if (preview != null && context.mounted) {
                                context.push(
                                  AppRoutes.redemptionReviewPath(reward.id),
                                  extra: RedemptionPreparation(
                                    reward: reward,
                                    preview: preview,
                                    event: state.selectedEvent,
                                  ),
                                );
                              }
                            }
                          : null,
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fact_check_outlined),
                      label: const Text('Review redemption'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
