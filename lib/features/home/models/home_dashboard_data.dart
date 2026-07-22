import '../../wallet/models/point_transaction.dart';
import '../../wallet/models/wallet_summary.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.userId,
    this.wallet,
    required this.transactions,
    required this.refreshedAt,
    this.displayName,
  });
  final int userId;
  final String? displayName;
  final WalletSummary? wallet;
  final List<PointTransaction> transactions;
  final DateTime refreshedAt;
}
