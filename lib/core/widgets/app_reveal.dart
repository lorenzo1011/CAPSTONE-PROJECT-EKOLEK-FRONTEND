import 'package:flutter/material.dart';

import '../../app/theme/app_motion.dart';

class AppReveal extends StatelessWidget {
  const AppReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.035),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.emphasized + delay,
      curve: Interval(
        delay.inMilliseconds /
            (AppMotion.emphasized.inMilliseconds + delay.inMilliseconds),
        1,
        curve: AppMotion.entranceCurve,
      ),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: FractionalTranslation(
          translation: Offset(offset.dx * (1 - value), offset.dy * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
