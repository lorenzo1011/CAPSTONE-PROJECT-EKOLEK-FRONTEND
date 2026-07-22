import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/redemption_preparation.dart';
import '../models/redemption_request.dart';
import '../models/redemption_request_result.dart';
import '../services/redemption_service.dart';
import '../services/rewards_service.dart';
import 'redemption_submission_state.dart';

class RedemptionSubmissionController extends ChangeNotifier {
  RedemptionSubmissionController(this._redemptions, this._rewards);
  final RedemptionService _redemptions;
  final RewardsService _rewards;
  RedemptionSubmissionState state = const RedemptionSubmissionState();
  CancelToken? _cancel;
  String? _key;
  Future<RedemptionRequestResult?> submit(
    RedemptionPreparation preparation,
  ) async {
    if (state.busy) return state.result;
    final event = preparation.event;
    if (event == null) {
      state = const RedemptionSubmissionState(
        phase: RedemptionSubmissionPhase.failure,
        message:
            'A valid Reward Distribution Event is required for this redemption.',
      );
      notifyListeners();
      return null;
    }
    state = const RedemptionSubmissionState(
      phase: RedemptionSubmissionPhase.revalidating,
    );
    notifyListeners();
    _cancel = CancelToken();
    try {
      final eligibility = await _rewards.eligibility(
        preparation.reward.id,
        quantity: preparation.preview.eligibility.quantity,
        eventId: event.id,
        cancelToken: _cancel,
      );
      if (!eligibility.eligible ||
          eligibility.totalPoints !=
              preparation.preview.eligibility.totalPoints) {
        state = const RedemptionSubmissionState(
          phase: RedemptionSubmissionPhase.failure,
          message:
              'Your reward eligibility has changed. Review the updated details before submitting again.',
        );
        notifyListeners();
        return null;
      }
      _key ??= _newKey();
      state = const RedemptionSubmissionState(
        phase: RedemptionSubmissionPhase.submitting,
      );
      notifyListeners();
      final result = await _redemptions.submit(
        RedemptionRequest(
          rewardId: preparation.reward.id,
          quantity: eligibility.quantity,
          eventId: event.id,
          idempotencyKey: _key!,
        ),
        cancelToken: _cancel,
      );
      state = RedemptionSubmissionState(
        phase: RedemptionSubmissionPhase.submitted,
        result: result,
      );
      notifyListeners();
      return result;
    } on NetworkException {
      state = const RedemptionSubmissionState(
        phase: RedemptionSubmissionPhase.uncertain,
        message:
            'E-KOLEK is checking whether your redemption request was received.',
      );
      notifyListeners();
      try {
        final found = await _redemptions.lookup(_key!);
        if (found != null) {
          final result = RedemptionRequestResult(
            requestCreated: false,
            duplicateRequest: true,
            redemption: found,
          );
          state = RedemptionSubmissionState(
            phase: RedemptionSubmissionPhase.submitted,
            result: result,
          );
          notifyListeners();
          return result;
        }
      } on AppException {
        /* Keep uncertain state. */
      }
      return null;
    } on AppException {
      state = const RedemptionSubmissionState(
        phase: RedemptionSubmissionPhase.failure,
        message:
            'Your redemption request could not be submitted. Please try again.',
      );
      notifyListeners();
      return null;
    }
  }

  String _newKey() {
    final random = Random.secure();
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${List.generate(4, (_) => random.nextInt(1 << 32).toRadixString(36)).join()}';
  }

  void reset() {
    _cancel?.cancel();
    _key = null;
    state = const RedemptionSubmissionState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
