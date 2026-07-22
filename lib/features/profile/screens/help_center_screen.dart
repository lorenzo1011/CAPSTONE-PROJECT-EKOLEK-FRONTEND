import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_empty_state.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdaptivePageScaffold(
    title: 'Help Center',
    subtitle: 'Support information',
    body: AppEmptyState(
      icon: Icons.help_outline_rounded,
      title: 'Help information unavailable',
      message:
          'No verified help articles or official support channel are currently available in the resident system.',
    ),
  );
}
