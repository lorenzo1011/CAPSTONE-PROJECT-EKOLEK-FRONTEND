import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';

class RankingRow extends StatelessWidget {
  const RankingRow({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.unit,
    required this.highlighted,
    required this.isTied,
    this.subtitle,
  });
  final int rank;
  final String name;
  final num score;
  final String unit;
  final bool highlighted, isTied;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label:
        'Rank $rank, $name, $score $unit${highlighted ? ', your position' : ''}${isTied ? ', tied' : ''}',
    child: Card(
      color: highlighted
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(child: Text('$rank')),
        title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text([?subtitle, if (isTied) 'Tied rank'].join(' · ')),
        trailing: Text(
          '${AppFormatters.leaderboardScore(score)} $unit',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ),
  );
}
