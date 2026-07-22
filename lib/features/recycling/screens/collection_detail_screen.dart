import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/recycling_providers.dart';
import '../models/collection_transaction.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  const CollectionDetailScreen({super.key, required this.id, this.initial});
  final int id;
  final CollectionTransaction? initial;
  @override
  ConsumerState<CollectionDetailScreen> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState
    extends ConsumerState<CollectionDetailScreen> {
  CollectionTransaction? _data;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await ref.read(recyclingServiceProvider).detail(widget.id);
      if (mounted) setState(() => _data = value);
    } on AppException {
      if (mounted) {
        setState(
          () => _error = 'This recycling record is no longer available.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(title: const Text('Collection details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: data == null
                ? _EmptyDetail(loading: _loading, error: _error, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.screenPadding,
                      children: [
                        if (_loading) const LinearProgressIndicator(),
                        if (_error != null)
                          Card(child: ListTile(title: Text(_error!))),
                        Text(
                          data.number,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(AppFormatters.dateTime(data.processedAt)),
                        const SizedBox(height: 16),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Total recorded weight'),
                                trailing: Text(
                                  AppFormatters.weight(data.totalWeightKg),
                                ),
                              ),
                              ListTile(
                                title: const Text('Points awarded'),
                                trailing: Text(
                                  '${AppFormatters.points(data.totalPoints)} pts',
                                ),
                              ),
                              ListTile(
                                title: const Text('Status'),
                                trailing: Text(data.status.name),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Material breakdown',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ...data.items.map(
                          (item) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.category_rounded),
                              title: Text(item.material.name),
                              subtitle: Text(
                                '${AppFormatters.weight(item.weightKg)} • ${AppFormatters.pointsPerUnit(item.pointsPerKg, 'KG')}',
                              ),
                              trailing: Text(
                                '${AppFormatters.points(item.awardedPoints)} pts',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({
    required this.loading,
    required this.error,
    required this.onRetry,
  });
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => loading
      ? const CircularProgressIndicator()
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error ?? 'Collection unavailable'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        );
}
