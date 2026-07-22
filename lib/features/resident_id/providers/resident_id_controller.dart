import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/models/auth_user.dart';
import '../services/resident_id_service.dart';
import 'resident_id_state.dart';

class ResidentIdController extends ChangeNotifier {
  ResidentIdController(this._service);
  final ResidentIdService _service;
  ResidentIdState _state = const ResidentIdState();
  CancelToken? _cancelToken;
  int? _ownerUserId;
  bool _disposed = false;
  ResidentIdState get state => _state;

  Future<void> loadFor(AuthUser? user, {bool refresh = false}) async {
    if (user == null || !user.isApprovedResident) {
      clear();
      _set(
        const ResidentIdState(
          status: ResidentIdLoadStatus.unavailable,
          message: 'The Digital Resident ID is not available for this account.',
        ),
      );
      return;
    }
    if (_ownerUserId != user.id) {
      clear();
    }
    _ownerUserId = user.id;
    if (_state.status == ResidentIdLoadStatus.loading ||
        _state.status == ResidentIdLoadStatus.refreshing ||
        (!refresh && _state.status == ResidentIdLoadStatus.loaded)) {
      return;
    }
    _set(
      _state.copyWith(
        status: _state.id == null
            ? ResidentIdLoadStatus.loading
            : ResidentIdLoadStatus.refreshing,
      ),
    );
    _cancelToken = CancelToken();
    try {
      final id = await _service.getDigitalResidentId(cancelToken: _cancelToken);
      if (_ownerUserId == user.id) {
        _set(
          ResidentIdState(
            status: ResidentIdLoadStatus.loaded,
            id: id,
            lastUpdated: DateTime.now().toUtc(),
          ),
        );
      }
    } on CancelledRequestException {
      return;
    } on NetworkException {
      _failed(
        ResidentIdLoadStatus.offline,
        'You appear to be offline. Connect to the internet and try again.',
      );
    } on ForbiddenException {
      clear();
      _set(
        const ResidentIdState(
          status: ResidentIdLoadStatus.unavailable,
          message: 'The Digital Resident ID is not available for this account.',
        ),
      );
    } on AppException {
      _failed(
        ResidentIdLoadStatus.failure,
        'Your E-KOLEK Resident ID could not be loaded. Please try again.',
      );
    }
  }

  void _failed(ResidentIdLoadStatus status, String message) => _set(
    _state.copyWith(
      status: status,
      message: message,
      isStale: _state.id != null,
    ),
  );
  void clear() {
    _cancelToken?.cancel();
    _ownerUserId = null;
    _state = const ResidentIdState();
    if (!_disposed) notifyListeners();
  }

  void _set(ResidentIdState value) {
    _state = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    super.dispose();
  }
}
