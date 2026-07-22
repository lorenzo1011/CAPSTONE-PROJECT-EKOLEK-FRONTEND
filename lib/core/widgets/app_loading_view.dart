import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message, this.compact = false});

  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Semantics(
      container: true,
      liveRegion: true,
      label: message ?? 'Loading',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: compact ? 22 : 32,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: content,
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: content,
      ),
    );
  }
}
