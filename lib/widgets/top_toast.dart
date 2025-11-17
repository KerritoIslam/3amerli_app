import 'dart:async';

import 'package:flutter/material.dart';

/// A small reusable top toast that appears as an overlay at the top of the
/// screen. It supports:
/// - custom message
/// - primary color background (from theme)
/// - a thin linear progress indicator used as a timer
/// - swipe-to-dismiss (horizontal)
/// Usage:
///   TopToast.show(context, message: '...');
class TopToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(BuildContext context,
      {required String message, Duration duration = const Duration(seconds: 3)}) {
    // If already showing, remove first
    _hide();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    _entry = OverlayEntry(builder: (ctx) {
      return _TopToastOverlay(
        message: message,
        backgroundColor: primary,
        duration: duration,
      );
    });

  Overlay.of(context).insert(_entry!);

    // Auto-hide
    _timer = Timer(duration, () => _hide());
  }

  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void dismiss() => _hide();
}

class _TopToastOverlay extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;

  const _TopToastOverlay({required this.message, required this.backgroundColor, required this.duration});

  @override
  State<_TopToastOverlay> createState() => _TopToastOverlayState();
}

class _TopToastOverlayState extends State<_TopToastOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  double _progress = 0.0;
  Timer? _localTimer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim.forward();

    // progress ticker
    final tick = 50; // ms
    final ticks = widget.duration.inMilliseconds ~/ tick;
    int count = 0;
    _localTimer = Timer.periodic(Duration(milliseconds: tick), (t) {
      count++;
      setState(() {
        _progress = (count / (ticks > 0 ? ticks : 1)).clamp(0.0, 1.0);
      });
      if (count >= ticks) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(_anim),
            child: Dismissible(
              key: const ValueKey('top_toast'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => TopToast.dismiss(),
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => TopToast.dismiss(),
                          child: Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        height: 2,
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: widget.backgroundColor.withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
