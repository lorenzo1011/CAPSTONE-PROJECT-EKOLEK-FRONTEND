import 'package:flutter/material.dart';

import '../../app/theme/app_layout.dart';
import '../../app/theme/app_spacing.dart';
import 'app_page_header.dart';
import 'app_reveal.dart';

class AdaptivePageScaffold extends StatelessWidget {
  const AdaptivePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.scrollable = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = switch (constraints.maxWidth) {
              >= AppLayout.wideBreakpoint => AppSpacing.xl2,
              >= AppLayout.tabletBreakpoint => AppSpacing.xl,
              _ => AppSpacing.md,
            };
            final content = Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppReveal(
                      child: AppPageHeader(
                        title: title,
                        subtitle: subtitle,
                        actions: actions,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (scrollable)
                      AppReveal(
                        delay: const Duration(milliseconds: 70),
                        child: body,
                      )
                    else
                      Expanded(
                        child: AppReveal(
                          delay: const Duration(milliseconds: 70),
                          child: body,
                        ),
                      ),
                  ],
                ),
              ),
            );

            return Align(
              alignment: Alignment.topCenter,
              child: scrollable
                  ? SingleChildScrollView(child: content)
                  : SizedBox.expand(child: content),
            );
          },
        ),
      ),
    );
  }
}
