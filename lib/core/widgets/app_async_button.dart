import 'package:flutter/material.dart';

class AppAsyncButton extends StatefulWidget {
  const AppAsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busyLabel = 'Please wait…',
    this.icon,
  });

  final String label;
  final String busyLabel;
  final IconData? icon;
  final Future<void> Function()? onPressed;

  @override
  State<AppAsyncButton> createState() => _AppAsyncButtonState();
}

class _AppAsyncButtonState extends State<AppAsyncButton> {
  bool _busy = false;

  Future<void> _run() async {
    final action = widget.onPressed;
    if (_busy || action == null) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: !_busy && widget.onPressed != null,
    label: _busy ? widget.busyLabel : widget.label,
    child: FilledButton.icon(
      onPressed: _busy || widget.onPressed == null ? null : _run,
      icon: _busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon ?? Icons.check_rounded),
      label: Text(_busy ? widget.busyLabel : widget.label),
    ),
  );
}
