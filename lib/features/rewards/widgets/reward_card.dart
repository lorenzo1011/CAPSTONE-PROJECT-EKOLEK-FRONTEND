import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/reward_item.dart';
import 'reward_image.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.reward, required this.onTap});
  final RewardItem reward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 92,
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 92,
              child: RewardImage(
                name: reward.name,
                url: reward.imageUrl,
                heroTag: 'reward-${reward.id}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    reward.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppFormatters.rewardPoints(reward.pointsRequired),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF159447),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(onPressed: onTap, child: const Text('Redeem')),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
}
