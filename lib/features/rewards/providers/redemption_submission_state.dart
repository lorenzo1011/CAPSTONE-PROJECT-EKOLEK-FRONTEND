import '../models/redemption_request_result.dart';

enum RedemptionSubmissionPhase {
  idle,
  revalidating,
  submitting,
  uncertain,
  submitted,
  failure,
}

class RedemptionSubmissionState {
  const RedemptionSubmissionState({
    this.phase = RedemptionSubmissionPhase.idle,
    this.result,
    this.message,
  });
  final RedemptionSubmissionPhase phase;
  final RedemptionRequestResult? result;
  final String? message;
  bool get busy =>
      phase == RedemptionSubmissionPhase.revalidating ||
      phase == RedemptionSubmissionPhase.submitting ||
      phase == RedemptionSubmissionPhase.uncertain;
}
