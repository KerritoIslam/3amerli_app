import 'package:flutter/material.dart';

/// A simple shimmering skeleton box used as a loading placeholder.
///
/// This preserves the previous `SkeletonBox(width, height, borderRadius)` API
/// and adds a subtle left-to-right shimmer animation.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({Key? key, this.width = double.infinity, this.height = 12, this.borderRadius}) : super(key: key);

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    final highlightColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // animation value 0.0 -> 1.0
        final t = _controller.value;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            child: CustomPaint(
              painter: _ShimmerPainter(progress: t, baseColor: baseColor, highlightColor: highlightColor),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({required this.progress, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill base
    final paint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, paint);

    // Create a moving linear gradient for shimmer
    final gradientWidth = size.width * 0.3; // shimmer band width
    final dx = (size.width + gradientWidth) * progress - gradientWidth;

    final rect = Rect.fromLTWH(dx, 0, gradientWidth, size.height);
    final shader = LinearGradient(
      colors: [Colors.transparent, highlightColor, Colors.transparent],
      stops: const [0.15, 0.5, 0.85],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect);

    final shimmerPaint = Paint()..shader = shader;
    canvas.drawRect(rect, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.baseColor != baseColor || oldDelegate.highlightColor != highlightColor;
  }
}
