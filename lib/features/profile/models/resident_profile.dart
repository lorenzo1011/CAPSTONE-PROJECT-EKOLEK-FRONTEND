import '../../auth/models/auth_user.dart';
import 'profile_field_permissions.dart';

class ResidentBarangaySummary {
  const ResidentBarangaySummary({required this.name, this.area});
  factory ResidentBarangaySummary.fromJson(Map<String, Object?> j) =>
      ResidentBarangaySummary(
        name: j['name'] as String,
        area: j['district_or_area'] as String?,
      );
  final String name;
  final String? area;
}

class ResidentIdCardSummary {
  const ResidentIdCardSummary({
    required this.number,
    required this.status,
    this.issuedAt,
    this.expiryDate,
  });
  factory ResidentIdCardSummary.fromJson(Map<String, Object?> j) =>
      ResidentIdCardSummary(
        number: j['card_number'] as String,
        status: j['status'] as String,
        issuedAt: _date(j['issued_at']),
        expiryDate: _date(j['expiry_date']),
      );
  final String number, status;
  final DateTime? issuedAt, expiryDate;
  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() : null;
}

class ResidentProfile {
  const ResidentProfile({
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.birthdate,
    required this.barangay,
    required this.completeAddress,
    required this.approvalStatus,
    required this.memberSince,
    required this.permissions,
    this.photoUrl,
    this.residentId,
    this.approvedAt,
    this.idCard,
    this.updatedAt,
  });
  factory ResidentProfile.fromJson(Map<String, Object?> j) {
    final barangay = j['barangay'];
    if (barangay is! Map) throw const FormatException('Invalid barangay');
    final card = j['id_card'];
    return ResidentProfile(
      email: j['email'] as String,
      phoneNumber: j['phone_number'] as String? ?? '',
      fullName: j['full_name'] as String,
      birthdate: DateTime.parse(j['birthdate'] as String).toUtc(),
      barangay: ResidentBarangaySummary.fromJson(_map(barangay)),
      completeAddress: j['complete_address'] as String,
      photoUrl: j['profile_photo'] as String?,
      residentId: j['resident_id'] as String?,
      approvalStatus: ResidentApprovalStatus.fromJson(j['approval_status']),
      approvedAt: _date(j['approved_at']),
      memberSince: DateTime.parse(j['member_since'] as String).toUtc(),
      idCard: card is Map ? ResidentIdCardSummary.fromJson(_map(card)) : null,
      permissions: ProfileFieldPermissions.fromJson(j['editable_fields']),
      updatedAt: _date(j['updated_at']),
    );
  }
  final String email, phoneNumber, fullName, completeAddress;
  final String? photoUrl, residentId;
  final DateTime birthdate, memberSince;
  final DateTime? approvedAt, updatedAt;
  final ResidentBarangaySummary barangay;
  final ResidentApprovalStatus approvalStatus;
  final ResidentIdCardSummary? idCard;
  final ProfileFieldPermissions permissions;
  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() : null;
  static Map<String, Object?> _map(Map v) =>
      v.map((k, v) => MapEntry(k.toString(), v));
  @override
  String toString() =>
      'ResidentProfile(status: ${approvalStatus.value}, hasResidentId: ${residentId != null})';
}
