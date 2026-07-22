import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => AdaptivePageScaffold(
    title: 'About E-KOLEK',
    subtitle: 'Resident mobile application',
    scrollable: true,
    body: Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.eco_rounded, size: 64),
            const SizedBox(height: 16),
            Text(
              'E-KOLEK Resident App',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0 (build 1)'),
          ],
        ),
      ),
    ),
  );
}
