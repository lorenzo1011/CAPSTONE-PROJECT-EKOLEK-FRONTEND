import 'dart:async';

class SessionExpiredHandler {
  final _controller = StreamController<void>.broadcast();
  bool _notified = false;

  Stream<void> get events => _controller.stream;

  void notifyExpired() {
    if (_notified || _controller.isClosed) return;
    _notified = true;
    _controller.add(null);
  }

  void reset() => _notified = false;

  Future<void> dispose() => _controller.close();
}
