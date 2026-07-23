import 'package:flutter/material.dart';

import '../../app/theme/app_motion.dart';

class AppReveal extends StatefulWidget {
  const AppReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.025),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<AppReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  Duration get _totalDuration => AppMotion.emphasized + widget.delay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (reduceMotion) {
      _controller.value = 1;
      _started = true;
      return;
    }

    if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _totalDuration.inMilliseconds;
    final start = totalMs == 0
        ? 0.0
        : widget.delay.inMilliseconds / totalMs;
    final curve = Interval(start.clamp(0.0, 1.0).toDouble(), 1, curve: AppMotion.entranceCurve);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = curve.transform(_controller.value);
        return Opacity(
          opacity: value,
          child: FractionalTranslation(
            translation: Offset(
              widget.offset.dx * (1 - value),
              widget.offset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
