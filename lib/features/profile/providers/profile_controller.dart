import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/profile_update_request.dart';
import '../services/profile_service.dart';
import 'profile_state.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._service);
  final ProfileService _service;
  ProfileState state = const ProfileState();
  CancelToken? _cancel;
  bool _busy = false;
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    state = state.copyWith(
      phase: state.profile == null
          ? ProfilePhase.loading
          : ProfilePhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel?.cancel();
    _cancel = CancelToken();
    try {
      final p = await _service.getCurrentProfile(cancelToken: _cancel);
      state = state.copyWith(
        phase: ProfilePhase.loaded,
        profile: p,
        stale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: ProfilePhase.offline,
        stale: state.profile != null,
        message: state.profile == null
            ? 'Your profile information could not be loaded. Please try again.'
            : 'Showing the last profile information loaded on this device.',
      );
    } on AppException {
      state = state.copyWith(
        phase: ProfilePhase.failure,
        stale: state.profile != null,
        message:
            'Your profile information could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> savePhone(String value) async {
    final current = state.profile;
    if (_busy || current == null) return false;
    final normalized = value.trim();
    if (normalized == current.phoneNumber) {
      state = state.copyWith(
        phase: ProfilePhase.loaded,
        message: 'No profile changes were made.',
      );
      notifyListeners();
      return false;
    }
    if (normalized.length > 20) {
      state = state.copyWith(
        phase: ProfilePhase.editing,
        message: 'Phone number cannot exceed 20 characters.',
      );
      notifyListeners();
      return false;
    }
    _busy = true;
    state = state.copyWith(phase: ProfilePhase.saving, clearMessage: true);
    notifyListeners();
    try {
      final result = await _service.updateProfile(
        ProfileUpdateRequest(phoneNumber: normalized),
      );
      state = state.copyWith(
        phase: ProfilePhase.saved,
        profile: result.profile,
        message: 'Profile updated successfully.',
      );
      return true;
    } on AppException {
      state = state.copyWith(
        phase: ProfilePhase.editing,
        message: 'Your profile changes could not be saved.',
      );
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPhoto(String path) async {
    if (_busy) return false;
    _busy = true;
    state = state.copyWith(
      phase: ProfilePhase.uploadingPhoto,
      uploadProgress: 0,
      clearMessage: true,
    );
    notifyListeners();
    try {
      final result = await _service.uploadPhoto(
        path,
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
            notifyListeners();
          }
        },
      );
      state = state.copyWith(
        phase: ProfilePhase.saved,
        profile: result.profile,
        message: 'Profile photo updated.',
        clearProgress: true,
      );
      return true;
    } on AppException {
      state = state.copyWith(
        phase: ProfilePhase.loaded,
        message: 'Your profile photo could not be updated.',
        clearProgress: true,
      );
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void reset() {
    _cancel?.cancel();
    state = const ProfileState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
