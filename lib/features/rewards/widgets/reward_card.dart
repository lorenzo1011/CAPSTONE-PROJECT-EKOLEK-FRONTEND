import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/reward_item.dart';
import 'reward_image.dart';
import 'reward_stock_indicator.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.reward, required this.onTap});
  final RewardItem reward;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RewardImage(
            name: reward.name,
            url: reward.imageUrl,
            heroTag: 'reward-${reward.id}',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (reward.category.isNotEmpty)
                    Text(
                      reward.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Text(
                    AppFormatters.rewardPoints(reward.pointsRequired),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  FittedBox(
                    child: RewardStockIndicator(
                      availability: reward.availability,
                      quantity: reward.stock.availableQuantity,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onTap,
                      child: const Text('View details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
