import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/resident_redemption.dart';
import 'redemption_status_chip.dart';
import 'reward_image.dart';

class RedemptionHistoryCard extends StatelessWidget {
  const RedemptionHistoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  final ResidentRedemption item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RewardImage(
                  name: item.item.rewardName,
                  url: item.item.imageUrl,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item.rewardName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.referenceCode != null) Text(item.referenceCode!),
                  Text(
                    '${item.item.quantity} item(s) · ${AppFormatters.rewardPoints(item.item.totalPoints)}',
                  ),
                  RedemptionStatusChip(status: item.status),
                  Text(AppFormatters.dateTime(item.requestedAt)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}
