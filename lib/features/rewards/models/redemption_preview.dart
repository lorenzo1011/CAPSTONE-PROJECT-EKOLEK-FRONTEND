import 'redemption_eligibility.dart';

class RedemptionPreview {
  const RedemptionPreview({
    required this.eligibility,
    required this.isNonCommitting,
    required this.reservationCreated,
  });
  factory RedemptionPreview.fromJson(Map<String, Object?> j) =>
      RedemptionPreview(
        eligibility: RedemptionEligibility.fromJson(j),
        isNonCommitting: j['is_non_committing'] == true,
        reservationCreated: j['reservation_created'] == true,
      );
  final RedemptionEligibility eligibility;
  final bool isNonCommitting, reservationCreated;
}
