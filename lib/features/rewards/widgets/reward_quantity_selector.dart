import 'package:flutter/material.dart';

class RewardQuantitySelector extends StatelessWidget {
  const RewardQuantitySelector({
    super.key,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });
  final int value, minimum, maximum;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Quantity $value. Minimum $minimum, maximum $maximum',
    child: Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Decrease quantity',
          onPressed: value > minimum ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Increase quantity',
          onPressed: value < maximum ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
  );
}
