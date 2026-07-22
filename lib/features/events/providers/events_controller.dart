import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/models/auth_user.dart';
import '../models/resident_event.dart';
import '../services/events_service.dart';

enum ScheduleFilter { all, collection, rewards }

class EventsController extends ChangeNotifier {
  EventsController(this._service);
  final EventsService _service;
  List<ResidentEvent> events = [];
  bool loading = false;
  String? error;
  ScheduleFilter filter = ScheduleFilter.all;
  CancelToken? _cancel;
  List<ResidentEvent> get filtered => events
      .where(
        (e) =>
            filter == ScheduleFilter.all ||
            (filter == ScheduleFilter.collection &&
                e.type == ResidentEventType.collection) ||
            (filter == ScheduleFilter.rewards &&
                e.type == ResidentEventType.rewardDistribution),
      )
      .toList();
  Future<void> load(AuthUser user) async {
    if (loading || !user.isApprovedResident) return;
    loading = true;
    error = null;
    notifyListeners();
    _cancel = CancelToken();
    try {
      final result = await Future.wait([
        _service.collection(cancelToken: _cancel),
        _service.rewards(cancelToken: _cancel),
      ]);
      events = {
        for (final e in [...result[0].items, ...result[1].items])
          '${e.type.name}-${e.id}': e,
      }.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      error = 'Your barangay schedules could not be loaded. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void select(ScheduleFilter value) {
    filter = value;
    notifyListeners();
  }

  void reset() {
    _cancel?.cancel();
    events = [];
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
