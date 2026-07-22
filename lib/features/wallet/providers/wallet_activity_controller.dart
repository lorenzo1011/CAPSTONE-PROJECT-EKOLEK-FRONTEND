import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../models/point_transaction.dart';
import '../services/wallet_service.dart';

class WalletActivityController extends ChangeNotifier {
  WalletActivityController(this._service);

  final WalletService _service;
  final List<PointTransaction> _items = [];
  CancelToken? _cancelToken;
  bool _disposed = false;
  bool loading = false;
  bool loadingMore = false;
  bool hasNext = true;
  int _nextPage = 1;
  String? errorMessage;

  List<PointTransaction> get items => List.unmodifiable(_items);

  Future<void> load({bool refresh = false}) async {
    if (loading || loadingMore) return;
    if (!refresh && !hasNext) return;
    if (refresh) {
      _nextPage = 1;
      hasNext = true;
      errorMessage = null;
    }
    final firstPage = _nextPage == 1;
    loading = firstPage;
    loadingMore = !firstPage;
    notifyListeners();
    _cancelToken = CancelToken();
    try {
      final result = await _service.getPointTransactions(
        page: _nextPage,
        cancelToken: _cancelToken,
      );
      if (refresh || firstPage) _items.clear();
      final knownIds = _items.map((item) => item.id).toSet();
      _items.addAll(result.items.where((item) => knownIds.add(item.id)));
      hasNext = result.hasNext;
      if (hasNext) _nextPage++;
      errorMessage = null;
    } on NetworkException {
      errorMessage =
          'You appear to be offline. Point activity could not be refreshed.';
    } on AppException {
      errorMessage = 'Point activity could not be loaded. Please try again.';
    } finally {
      loading = false;
      loadingMore = false;
      if (!_disposed) notifyListeners();
    }
  }

  void reset() {
    _cancelToken?.cancel();
    _items.clear();
    _nextPage = 1;
    hasNext = true;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    super.dispose();
  }
}
