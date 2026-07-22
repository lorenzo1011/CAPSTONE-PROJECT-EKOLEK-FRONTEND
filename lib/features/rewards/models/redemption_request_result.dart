import 'resident_redemption.dart';

class RedemptionRequestResult {
  const RedemptionRequestResult({
    required this.requestCreated,
    required this.duplicateRequest,
    required this.redemption,
  });
  factory RedemptionRequestResult.fromJson(Map<String, Object?> j) {
    final raw = j['redemption'];
    if (raw is! Map) throw const FormatException('Invalid redemption');
    return RedemptionRequestResult(
      requestCreated: j['request_created'] == true,
      duplicateRequest: j['duplicate_request'] == true,
      redemption: ResidentRedemption.fromJson(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      ),
    );
  }
  final bool requestCreated, duplicateRequest;
  final ResidentRedemption redemption;
}
