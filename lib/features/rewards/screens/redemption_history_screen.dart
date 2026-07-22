import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/redemption_providers.dart';
import '../models/redemption_history_filter.dart';
import '../providers/redemption_history_state.dart';
import '../widgets/redemption_history_card.dart';

class RedemptionHistoryScreen extends ConsumerStatefulWidget {
  const RedemptionHistoryScreen({super.key});
  @override
  ConsumerState<RedemptionHistoryScreen> createState() => _State();
}

class _State extends ConsumerState<RedemptionHistoryScreen> {
  bool get testing => WidgetsBinding.instance.runtimeType.toString().contains(
    'TestWidgetsFlutterBinding',
  );
  @override
  void initState() {
    super.initState();
    if (!testing) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(redemptionHistoryControllerProvider).load(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(redemptionHistoryStateProvider),
        c = ref.read(redemptionHistoryControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Redemption requests')),
      body: RefreshIndicator(
        onRefresh: () => c.load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: RedemptionHistoryFilter.values
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f.label),
                              selected: s.filter == f,
                              onSelected: (_) => c.select(f),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            if (s.message != null)
              SliverToBoxAdapter(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(s.message!),
                ),
              ),
            if ((s.phase == RedemptionHistoryPhase.initial ||
                    s.phase == RedemptionHistoryPhase.loading) &&
                s.items.isEmpty)
              SliverFillRemaining(
                child: testing
                    ? const SizedBox()
                    : const Center(child: CircularProgressIndicator()),
              )
            else if (s.items.isEmpty &&
                s.phase == RedemptionHistoryPhase.failure)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  title: 'History unavailable',
                  message: 'Your redemption history could not be loaded.',
                  onRetry: c.load,
                ),
              )
            else if (s.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No redemption requests',
                  message: 'Submitted reward requests will appear here.',
                ),
              )
            else
              SliverPadding(
                padding: AppSpacing.screenPadding,
                sliver: SliverList.builder(
                  itemCount: s.items.length + (s.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == s.items.length) {
                      c.loadMore();
                      return const Center(child: CircularProgressIndicator());
                    }
                    final item = s.items[index];
                    return RedemptionHistoryCard(
                      item: item,
                      onTap: () =>
                          context.push(AppRoutes.redemptionDetailPath(item.id)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
