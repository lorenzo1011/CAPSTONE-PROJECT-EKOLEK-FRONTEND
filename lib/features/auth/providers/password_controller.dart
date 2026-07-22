import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../services/password_service.dart';

class PasswordController extends ChangeNotifier {
  PasswordController(this._service);
  final PasswordService _service;
  bool busy = false;
  String? email;
  String? ticket;
  String? message;
  Map<String, List<String>> fieldErrors = const {};
  DateTime? cooldownUntil;
  CancelToken? _cancel;
  Future<bool> request(String value) => _guard(() async {
    if (cooldownUntil?.isAfter(DateTime.now()) ?? false) {
      throw const RateLimitException(
        message: 'Please wait before requesting another reset code.',
      );
    }
    await _service.requestReset(value, cancelToken: _cancel);
    email = value;
    cooldownUntil = DateTime.now().add(const Duration(seconds: 60));
    message =
        'If an account matches the information provided, password reset instructions will be sent.';
  });
  Future<bool> verify(String code) => _guard(() async {
    final value = email;
    if (value == null) throw const ValidationException();
    ticket = await _service.verifyCode(value, code, cancelToken: _cancel);
  });
  Future<bool> reset(String password, String confirmation) => _guard(() async {
    final value = ticket;
    if (value == null) throw const ValidationException();
    await _service.confirmReset(
      value,
      password,
      confirmation,
      cancelToken: _cancel,
    );
    ticket = null;
    email = null;
    message = 'Your password has been updated. You can now sign in.';
  });
  Future<bool> change(String oldPassword, String newPassword) => _guard(
    () =>
        _service.changePassword(oldPassword, newPassword, cancelToken: _cancel),
  );
  Future<bool> _guard(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    message = null;
    fieldErrors = const {};
    _cancel = CancelToken();
    notifyListeners();
    try {
      await action();
      return true;
    } on ValidationException catch (e) {
      fieldErrors = e.fieldErrors;
      message = e.message;
      return false;
    } on AppException catch (e) {
      message = e.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
