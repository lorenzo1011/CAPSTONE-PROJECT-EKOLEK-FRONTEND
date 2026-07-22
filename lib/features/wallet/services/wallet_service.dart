import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/point_transaction.dart';
import '../models/wallet_summary.dart';

class WalletService {
  WalletService(this._client);
  final ApiClient _client;
  Future<WalletSummary> getWalletSummary({CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.wallet,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _data(r.data);
    return WalletSummary.fromJson(d);
  }

  Future<PaginatedResponse<PointTransaction>> getPointTransactions({
    int page = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.pointTransactions,
      queryParameters: {'page': page, 'page_size': pageSize},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _data(r.data), raw = d['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: d['count'] is int ? d['count']! as int : raw.length,
      items: raw
          .whereType<Map>()
          .map(
            (e) => PointTransaction.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
      hasNext: d['next'] != null,
    );
  }

  Map<String, Object?> _data(Object? raw) {
    final root = raw is Map ? raw : null, data = root?['data'];
    if (data is! Map) throw const InvalidResponseException();
    return data.map((k, v) => MapEntry(k.toString(), v));
  }
}
