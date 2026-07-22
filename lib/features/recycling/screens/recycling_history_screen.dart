import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/recycling_providers.dart';
import '../providers/recycling_state.dart';
import '../widgets/collection_card.dart';

class RecyclingHistoryScreen extends ConsumerStatefulWidget {
  const RecyclingHistoryScreen({super.key});
  @override
  ConsumerState<RecyclingHistoryScreen> createState() => _State();
}

class _State extends ConsumerState<RecyclingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = ref.read(currentAuthUserProvider);
      if (u != null) ref.read(recyclingControllerProvider).load(u);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentAuthUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      final controller = ref.read(recyclingControllerProvider);
      controller.reset();
      if (next != null && next.isApprovedResident) {
        controller.load(next);
      }
    });
    final s = ref.watch(recyclingStateProvider),
        u = ref.watch(currentAuthUserProvider);
    Future<void> refresh() => u == null
        ? Future.value()
        : ref.read(recyclingControllerProvider).load(u, refresh: true);
    return AdaptivePageScaffold(
      title: 'Recycling activity',
      subtitle:
          'A verified record of collected materials, measured weight, and awarded points.',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.materialsPath),
          icon: const Icon(Icons.category_outlined),
          label: const Text('Material rates'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          itemCount:
              s.collections.length +
              2 +
              (s.hasNext && s.collections.isNotEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.stale)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.cloud_off_rounded),
                        title: Text(
                          'Showing the last recycling activity loaded on this device.',
                        ),
                      ),
                    ),
                  if (s.materialsMessage != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(s.materialsMessage!),
                      ),
                    ),
                ],
              );
            }
            if (index == 1 && s.collections.isEmpty) {
              if (s.phase == RecyclingPhase.loading) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (s.message != null) {
                return ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(s.message!),
                  trailing: IconButton(
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                );
              }
              return const ListTile(
                leading: Icon(Icons.history_rounded),
                title: Text('No recycling activity yet'),
                subtitle: Text('Your verified collections will appear here.'),
              );
            }
            final itemIndex = index - 1;
            if (itemIndex < s.collections.length) {
              final item = s.collections[itemIndex];
              return CollectionCard(
                collection: item,
                onTap: () => context.push(
                  AppRoutes.recyclingDetailPath(item.id),
                  extra: item,
                ),
              );
            }
            return Center(
              child: FilledButton.tonal(
                onPressed: s.phase == RecyclingPhase.loadingMore
                    ? null
                    : () => ref
                          .read(recyclingControllerProvider)
                          .load(u!, more: true),
                child: Text(
                  s.phase == RecyclingPhase.loadingMore
                      ? 'Loading more'
                      : 'Load more',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
