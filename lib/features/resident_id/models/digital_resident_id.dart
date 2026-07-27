import 'resident_id_status.dart';

class DigitalResidentId {
  const DigitalResidentId({
    required this.residentId,
    required this.fullName,
    required this.barangayName,
    required this.qrIsActive,
    required this.status,
    this.profilePhotoUrl,
    this.qrPayload,
    this.qrIssuedAt,
    this.cardNumber,
    this.cardIssuedAt,
    this.cardExpiryDate,
  });

  factory DigitalResidentId.fromJson(Map<String, Object?> json) {
    final rawBarangay = json['barangay'];
    final barangay = rawBarangay is Map
        ? rawBarangay.map((key, value) => MapEntry(key.toString(), value))
        : const <String, Object?>{};
    final residentId = _string(json['resident_id']) ?? '';
    final qrActive = json['qr_is_active'] == true;
    final cardExpiryDate = _dateTime(json['id_card_expiry_date']);
    final contractStatus = ResidentIdStatus.fromContract(
      cardStatus: json['id_card_status'],
      qrIsActive: qrActive,
      hasResidentId: residentId.isNotEmpty,
    );
    return DigitalResidentId(
      residentId: residentId,
      fullName: _string(json['full_name']) ?? '',
      barangayName: _string(barangay['name']) ?? '',
      profilePhotoUrl: _string(json['profile_photo']),
      qrPayload: _string(json['qr_payload']),
      qrIsActive: qrActive,
      qrIssuedAt: _dateTime(json['qr_issued_at']),
      cardNumber: _string(json['id_card_number']),
      cardIssuedAt: _dateTime(json['id_card_issued_at']),
      cardExpiryDate: cardExpiryDate,
      status:
          contractStatus == ResidentIdStatus.active &&
              _isDateExpired(cardExpiryDate)
          ? ResidentIdStatus.expired
          : contractStatus,
    );
  }

  final String residentId;
  final String fullName;
  final String barangayName;
  final String? profilePhotoUrl;
  final String? qrPayload;
  final bool qrIsActive;
  final DateTime? qrIssuedAt;
  final String? cardNumber;
  final DateTime? cardIssuedAt;
  final DateTime? cardExpiryDate;
  final ResidentIdStatus status;

  bool get canDisplayQr =>
      status == ResidentIdStatus.active &&
      qrIsActive &&
      (qrPayload?.isNotEmpty ?? false) &&
      !isExpired;
  bool get isExpired => _isDateExpired(cardExpiryDate);
  bool get isPhysicalIdIssued => cardNumber?.isNotEmpty ?? false;
  bool get needsReplacement =>
      status == ResidentIdStatus.revoked ||
      status == ResidentIdStatus.replacementPending;
  bool get hasValidProfilePhoto => profilePhotoUrl?.isNotEmpty ?? false;
  String get qrUnavailableReason {
    if (status == ResidentIdStatus.expired || isExpired) {
      return 'This resident ID has expired. Contact CENRO for renewal.';
    }
    if (status == ResidentIdStatus.revoked) {
      return 'This ID or its QR has been deactivated. Contact CENRO for assistance.';
    }
    if (status == ResidentIdStatus.replacementPending) {
      return 'A replacement ID is being prepared. The previous QR is no longer valid.';
    }
    if (status == ResidentIdStatus.pendingGeneration) {
      return 'Your official resident ID is still being prepared.';
    }
    if (!qrIsActive || !(qrPayload?.isNotEmpty ?? false)) {
      return 'No active verification QR is available for this ID.';
    }
    return 'The QR status could not be verified. Refresh and try again.';
  }

  static String? _string(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
  static DateTime? _dateTime(Object? value) {
    final raw = _string(value);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  static bool _isDateExpired(DateTime? value, [DateTime? now]) {
    if (value == null) return false;
    final current = (now ?? DateTime.now()).toLocal();
    final today = DateTime(current.year, current.month, current.day);
    final expiryDate = DateTime(value.year, value.month, value.day);
    return expiryDate.isBefore(today);
  }

  @override
  String toString() =>
      'DigitalResidentId(status: ${status.name}, hasQr: ${qrPayload != null})';
}
