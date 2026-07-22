import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../events/models/resident_event.dart';
import '../models/redemption_preview.dart';
import '../services/rewards_service.dart';
import 'reward_detail_state.dart';

class RewardDetailController extends ChangeNotifier {
  RewardDetailController(this._service, this.rewardId);
  final RewardsService _service;
  final int rewardId;
  RewardDetailState state = const RewardDetailState();
  CancelToken? _cancel;
  int _version = 0;
  Future<void> load({bool refresh = false}) async {
    state = state.copyWith(
      phase: refresh ? RewardDetailPhase.refreshing : RewardDetailPhase.loading,
      clearMessage: true,
    );
    notifyListeners();
    _cancel?.cancel();
    _cancel = CancelToken();
    try {
      final r = await Future.wait([
        _service.getReward(rewardId, cancelToken: _cancel),
        _service.validEvents(rewardId, cancelToken: _cancel),
      ]);
      final reward = r[0] as dynamic, events = r[1] as List<ResidentEvent>;
      final selected = events.isNotEmpty ? events.first : null;
      state = state.copyWith(
        phase: RewardDetailPhase.loaded,
        reward: reward,
        events: events,
        quantity: reward.minimumQuantity as int,
        selectedEvent: selected,
      );
      await checkEligibility();
    } on NetworkException {
      state = state.copyWith(
        phase: state.reward == null
            ? RewardDetailPhase.offline
            : RewardDetailPhase.loaded,
        message:
            'Connect to the internet to confirm reward stock and eligibility.',
      );
    } on AppException {
      state = state.copyWith(
        phase: RewardDetailPhase.unavailable,
        message: 'This reward is currently unavailable.',
      );
    }
    notifyListeners();
  }

  Future<void> setQuantity(int value) async {
    final r = state.reward;
    if (r == null || value < r.minimumQuantity || value > r.maximumQuantity) {
      return;
    }
    state = state.copyWith(quantity: value, clearPreview: true);
    notifyListeners();
    final version = ++_version;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (version == _version) await checkEligibility();
  }

  Future<void> selectEvent(ResidentEvent value) async {
    state = state.copyWith(selectedEvent: value, clearPreview: true);
    notifyListeners();
    await checkEligibility();
  }

  Future<void> checkEligibility() async {
    if (state.reward == null) return;
    state = state.copyWith(
      phase: RewardDetailPhase.checkingEligibility,
      clearMessage: true,
    );
    notifyListeners();
    try {
      final e = await _service.eligibility(
        rewardId,
        quantity: state.quantity,
        eventId: state.selectedEvent?.id,
      );
      state = state.copyWith(phase: RewardDetailPhase.loaded, eligibility: e);
    } on AppException {
      state = state.copyWith(
        phase: RewardDetailPhase.loaded,
        message: 'Your redemption eligibility could not be confirmed.',
      );
    }
    notifyListeners();
  }

  Future<RedemptionPreview?> prepare() async {
    await checkEligibility();
    if (state.eligibility?.eligible != true) return null;
    state = state.copyWith(phase: RewardDetailPhase.loadingPreview);
    notifyListeners();
    try {
      final p = await _service.preview(
        rewardId,
        quantity: state.quantity,
        eventId: state.selectedEvent?.id,
      );
      state = state.copyWith(phase: RewardDetailPhase.loaded, preview: p);
      return p;
    } on AppException {
      state = state.copyWith(
        phase: RewardDetailPhase.loaded,
        message: 'Your redemption preview could not be prepared.',
      );
      return null;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
