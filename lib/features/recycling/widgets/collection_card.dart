import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/collection_transaction.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.collection, this.onTap});
  final CollectionTransaction collection;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label:
        '${collection.number}, ${AppFormatters.weight(collection.totalWeightKg)}, ${collection.totalPoints} points',
    child: Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.recycling_rounded),
        title: Text(collection.number),
        subtitle: Text(
          '${AppFormatters.dateTime(collection.processedAt)}\n${AppFormatters.weight(collection.totalWeightKg)} • ${collection.status.name}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('+${AppFormatters.points(collection.totalPoints)} pts'),
            if (onTap != null) const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}
