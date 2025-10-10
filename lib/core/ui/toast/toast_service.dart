import 'package:flutter/material.dart';

enum ToastType { info, success, warning, error }

class ToastService {
  ToastService._();

  static final _instance = ToastService._();

  static ToastService get instance => _instance;

  OverlayEntry? _entry;

  void _removeCurrent() {
    _entry?.remove();
    _entry = null;
  }

  void showToast(BuildContext context, String message, {ToastType type = ToastType.info, Duration duration = const Duration(seconds: 3)}) {
    _removeCurrent();

    final color = _colorForType(type, Theme.of(context));

    _entry = OverlayEntry(builder: (context) {
      return Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: _ToastWidget(message: message, background: color),
          ),
        ),
      );
    });

  Overlay.of(context).insert(_entry!);

    Future.delayed(duration, () {
      _removeCurrent();
    });
  }

  Color _colorForType(ToastType type, ThemeData theme) {
    if (type == ToastType.success) return Colors.green.shade600;
    if (type == ToastType.warning) return Colors.orange.shade700;
    if (type == ToastType.error) return Colors.red.shade600;
    return theme.colorScheme.primary;
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final Color background;

  const _ToastWidget({Key? key, required this.message, required this.background}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
