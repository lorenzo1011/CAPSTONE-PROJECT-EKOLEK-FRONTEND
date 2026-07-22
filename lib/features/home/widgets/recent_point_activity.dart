import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../wallet/models/point_transaction.dart';

class RecentPointActivity extends StatelessWidget {
  const RecentPointActivity({super.key, required this.items});
  final List<PointTransaction> items;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.history_rounded),
        title: Text('No point activity yet'),
        subtitle: Text(
          'Your point activity will appear here after you earn or use E-KOLEK points.',
        ),
      );
    }
    return Column(
      children: items.map((tx) {
        final sign = tx.points > 0 ? '+' : '';
        return ListTile(
          leading: Icon(
            tx.direction == PointDirection.spent
                ? Icons.redeem_rounded
                : Icons.eco_rounded,
          ),
          title: Text(
            tx.description.isEmpty ? tx.label : tx.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(AppFormatters.dateTime(tx.createdAt)),
          trailing: Semantics(
            label: '${tx.direction.name} ${tx.points.abs()} points',
            child: Text(
              '$sign${AppFormatters.points(tx.points)} pts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      }).toList(),
    );
  }
}
