import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/providers/events_providers.dart';
import '../models/resident_event.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.eventType,
    this.initialEvent,
  });

  final int eventId;
  final ResidentEventType eventType;
  final ResidentEvent? initialEvent;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  ResidentEvent? _event;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _event = widget.initialEvent;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await ref
          .read(eventsServiceProvider)
          .detail(widget.eventId, widget.eventType);
      if (mounted) setState(() => _event = value);
    } on AppException {
      if (mounted) {
        setState(
          () => _error =
              'Schedule details could not be loaded. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: event == null
                ? _loading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: AppSpacing.screenPadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error ?? 'Schedule details are unavailable.',
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.screenPadding,
                      children: [
                        if (_loading) const LinearProgressIndicator(),
                        if (_error != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: Text(_error!),
                            ),
                          ),
                        Icon(
                          event.type == ResidentEventType.collection
                              ? Icons.recycling_rounded
                              : Icons.card_giftcard_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline_rounded),
                                title: Text(event.status.name),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.calendar_today_rounded,
                                ),
                                title: Text(
                                  '${event.date.month}/${event.date.day}/${event.date.year}',
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.schedule_rounded),
                                title: Text(
                                  '${event.startTime}–${event.endTime}',
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text(event.location),
                              ),
                              if (event.barangayName != null)
                                ListTile(
                                  leading: const Icon(Icons.place_outlined),
                                  title: Text(event.barangayName!),
                                ),
                              if (event.description.isNotEmpty)
                                ListTile(
                                  leading: const Icon(
                                    Icons.description_outlined,
                                  ),
                                  title: Text(event.description),
                                ),
                            ],
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
