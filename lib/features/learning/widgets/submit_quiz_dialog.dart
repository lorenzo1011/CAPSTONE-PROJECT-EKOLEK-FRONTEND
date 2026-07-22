import 'package:flutter/material.dart';

Future<bool> showSubmitQuizDialog(
  BuildContext context, {
  required int unansweredCount,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.fact_check_rounded),
        title: const Text('Submit this attempt?'),
        content: Text(
          unansweredCount > 0
              ? '$unansweredCount required question${unansweredCount == 1 ? '' : 's'} remain unanswered.'
              : 'Your answers will be finalized and can no longer be changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: unansweredCount > 0
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ) ??
    false;
