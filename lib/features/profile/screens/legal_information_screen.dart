import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_empty_state.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdaptivePageScaffold(
    title: 'Legal information',
    subtitle: 'Terms and privacy documents',
    body: AppEmptyState(
      icon: Icons.gavel_outlined,
      title: 'Legal documents unavailable',
      message:
          'No approved terms, privacy policy, or other legal document has been published in the resident system.',
    ),
  );
}
