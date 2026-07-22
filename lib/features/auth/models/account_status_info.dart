import 'resident_account_status.dart';

class AccountStatusInfo {
  const AccountStatusInfo({
    required this.userId,
    required this.status,
    this.profileId,
    this.displayName,
    this.residentId,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  factory AccountStatusInfo.fromCurrentUserData(Map<String, Object?> data) {
    final user = _map(data['user']);
    final resident = _map(data['resident']);
    final userId = user?['id'];
    if (userId is! int || resident == null) {
      throw const FormatException('Resident status response is incomplete.');
    }
    return AccountStatusInfo(
      userId: userId,
      profileId: resident['id'] is int ? resident['id']! as int : null,
      status: ResidentAccountStatus.fromBackend(resident['approval_status']),
      displayName: _nonEmpty(resident['full_name']),
      residentId: _nonEmpty(resident['resident_id']),
      rejectionReason: _nonEmpty(resident['rejection_reason']),
      submittedAt: _date(resident['created_at']),
      reviewedAt: _date(resident['approved_at']),
    );
  }

  final int userId;
  final int? profileId;
  final ResidentAccountStatus status;
  final String? displayName;
  final String? residentId;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  static Map<String, Object?>? _map(Object? value) => value is Map
      ? value.map((key, item) => MapEntry(key.toString(), item))
      : null;
  static String? _nonEmpty(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
