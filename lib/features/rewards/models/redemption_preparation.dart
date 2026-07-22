import '../../events/models/resident_event.dart';
import 'redemption_preview.dart';
import 'reward_item.dart';

class RedemptionPreparation {
  const RedemptionPreparation({
    required this.reward,
    required this.preview,
    this.event,
  });
  final RewardItem reward;
  final RedemptionPreview preview;
  final ResidentEvent? event;
}
