import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<ConnectivityStatus> currentStatus() async {
    try {
      return _mapResults(await _connectivity.checkConnectivity());
    } on Object {
      return ConnectivityStatus.unknown;
    }
  }

  Stream<ConnectivityStatus> get statusStream =>
      _connectivity.onConnectivityChanged.map(_mapResults).distinct();

  static ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((item) => item == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }
}
