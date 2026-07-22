import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Recyclable materials')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                const Text(
                  'Current active material rates. Actual awards use the rate stored on each collection item.',
                ),
                const SizedBox(height: 16),
                if (state.materials.isEmpty)
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(
                      state.materialsMessage ??
                          'Material information is loading.',
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
          ),
        ),
      ),
    );
  }
}
