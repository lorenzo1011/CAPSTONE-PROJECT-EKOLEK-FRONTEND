import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/events_providers.dart';
import '../models/resident_event.dart';
import '../providers/events_controller.dart';

class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});
  @override
  ConsumerState<SchedulesScreen> createState() => _S();
}

class _S extends ConsumerState<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = ref.read(currentAuthUserProvider);
      if (u != null) ref.read(eventsControllerProvider).load(u);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(eventsControllerProvider),
        u = ref.watch(currentAuthUserProvider);
    Future<void> refresh() async {
      if (u != null) await ref.read(eventsControllerProvider).load(u);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              SegmentedButton<ScheduleFilter>(
                segments: const [
                  ButtonSegment(value: ScheduleFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: ScheduleFilter.collection,
                    label: Text('Collection'),
                  ),
                  ButtonSegment(
                    value: ScheduleFilter.rewards,
                    label: Text('Rewards'),
                  ),
                ],
                selected: {c.filter},
                onSelectionChanged: (v) => c.select(v.first),
              ),
              if (c.loading && c.events.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (c.error != null && c.events.isEmpty)
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(c.error!),
                  trailing: IconButton(
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                )
              else if (c.filtered.isEmpty)
                const ListTile(
                  leading: Icon(Icons.event_busy),
                  title: Text('No schedules available'),
                )
              else
                ...c.filtered.map(
                  (e) => Card(
                    child: ListTile(
                      leading: Icon(
                        e.type == ResidentEventType.collection
                            ? Icons.recycling_rounded
                            : Icons.card_giftcard_rounded,
                      ),
                      title: Text(e.title),
                      subtitle: Text(
                        '${e.date.month}/${e.date.day}/${e.date.year} • ${e.startTime}–${e.endTime}\n${e.location}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        AppRoutes.eventDetailPath(e.type.name, e.id),
                        extra: e,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
