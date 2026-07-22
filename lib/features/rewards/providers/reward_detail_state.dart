import '../../events/models/resident_event.dart';
import '../models/redemption_eligibility.dart';
import '../models/redemption_preview.dart';
import '../models/reward_item.dart';

enum RewardDetailPhase {
  initial,
  loading,
  loaded,
  refreshing,
  checkingEligibility,
  loadingPreview,
  offline,
  unavailable,
  failure,
}

class RewardDetailState {
  const RewardDetailState({
    this.phase = RewardDetailPhase.initial,
    this.reward,
    this.eligibility,
    this.preview,
    this.events = const [],
    this.quantity = 1,
    this.selectedEvent,
    this.message,
  });
  final RewardDetailPhase phase;
  final RewardItem? reward;
  final RedemptionEligibility? eligibility;
  final RedemptionPreview? preview;
  final List<ResidentEvent> events;
  final int quantity;
  final ResidentEvent? selectedEvent;
  final String? message;
  RewardDetailState copyWith({
    RewardDetailPhase? phase,
    RewardItem? reward,
    RedemptionEligibility? eligibility,
    RedemptionPreview? preview,
    List<ResidentEvent>? events,
    int? quantity,
    ResidentEvent? selectedEvent,
    String? message,
    bool clearMessage = false,
    bool clearPreview = false,
  }) => RewardDetailState(
    phase: phase ?? this.phase,
    reward: reward ?? this.reward,
    eligibility: eligibility ?? this.eligibility,
    preview: clearPreview ? null : preview ?? this.preview,
    events: events ?? this.events,
    quantity: quantity ?? this.quantity,
    selectedEvent: selectedEvent ?? this.selectedEvent,
    message: clearMessage ? null : message ?? this.message,
  );
}
