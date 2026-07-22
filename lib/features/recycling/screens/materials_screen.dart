import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/recycling_providers.dart';

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recyclingStateProvider);
    final user = ref.watch(currentAuthUserProvider);
    Future<void> retry() => user == null
        ? Future.value()
        : ref.read(recyclingControllerProvider).load(user, refresh: true);
    return AdaptivePageScaffold(
      title: 'Material guide',
      subtitle:
          'Current active point rates and preparation guidance for accepted recyclables.',
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Text(
            'Rates may change over time. Completed collections always use the rate recorded during verification.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.materials.isEmpty)
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text(
                state.materialsMessage ?? 'Material information is loading.',
              ),
              trailing: IconButton(
                onPressed: retry,
                icon: const Icon(Icons.refresh_rounded),
              ),
            )
          else
            ...state.materials.map(
              (material) => Card(
                child: ListTile(
                  leading: const Icon(Icons.recycling_rounded),
                  title: Text(material.name),
                  subtitle: Text(
                    material.description.isEmpty
                        ? material.category
                        : material.description,
                  ),
                  trailing: Text(
                    AppFormatters.pointsPerUnit(
                      material.currentPointsPerKg,
                      material.unit,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
