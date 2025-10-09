

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// inset shadow removed — no external dependency

class NavItem {
  final String icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

/// A simple animated bottom navigation bar.
///
/// Each item renders a circular red background (brand color) with a white
/// icon centered. When the item is selected the label expands next to the
/// icon using an [AnimatedSize]. The outer pill also animates its background
/// to indicate selection.
class AnimatedBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AnimatedBottomNavBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => NavBarItem(
            item: items[index],
            isSelected: selectedIndex == index,
            onTap: () => onItemSelected(index),
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  // Controls whether the outer pill shows the selected background.
  // We intentionally keep this false while the expansion animation runs
  // so the outer container remains transparent during the transition.
  late bool _showBackground;

  @override
  void initState() {
    super.initState();
    _showBackground = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selection just changed to true, keep background hidden until
    // the animation finishes. If it was deselected, hide it immediately.
    if (!oldWidget.isSelected && widget.isSelected) {
      // start with background hidden while expanding
      if (_showBackground) setState(() => _showBackground = false);
    } else if (oldWidget.isSelected && !widget.isSelected) {
      // hide background immediately when deselected
      if (_showBackground) setState(() => _showBackground = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Builder(builder: (context) {
        final animated = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // Trigger onEnd to flip the background on after expansion completes
          onEnd: () {
            if (!mounted) return;
            if (widget.isSelected && !_showBackground) {
              setState(() => _showBackground = true);
            }
            // when deselected we already set _showBackground = false in didUpdateWidget
          },
          height: 40,
          padding: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  blurRadius: 0.3,
                  offset: const Offset(0, -0.3),
                )
            ],
            // Use the local _showBackground flag so the color only appears
            // after the expansion animation completes.
            color: widget.isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular red background with white icon (always red per request)
              _IconCircle(icon: widget.item.icon, isSelected: widget.isSelected),

              // Animated label that appears when selected. The label's
              // container height is fixed to the circle diameter so the
              // item doesn't grow taller; only width changes.
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                child: widget.isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              widget.item.label,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: 0, height: 40),
              ),
            ],
          ),
        );

        // Always wrap the animated container to keep the widget tree stable
        // (this preserves AnimatedContainer/AnimatedSize transitions). We
        // toggle the visible shadow by adjusting `strength` to 0 when not
        // selected so the painter becomes a no-op visually.
        final showShadow = widget.isSelected || _showBackground;
        return InnerShadow(
          radius: 25,
          color: Colors.black,
          strength: showShadow ? 0.12 : 0.0,
          blur: 8,
          child: animated,
        );
      }),
    );
  }
}

/// Draws a subtle inner shadow inside a rounded rectangle by painting
/// gradient overlays on the edges. This avoids external packages and
/// approximates an inset shadow suitable for pill-shaped containers.
class InnerShadow extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final double strength; // 0..1
  final double blur; // height of the gradient

  const InnerShadow({
    Key? key,
    required this.child,
    this.radius = 12,
    this.color = const Color(0x22000000),
    this.strength = 0.18,
    this.blur = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _InnerShadowPainter(
                radius: radius,
                color: color.withOpacity(strength),
                blur: blur,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double blur;

  _InnerShadowPainter({required this.radius, required this.color, required this.blur});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    // Clip to rounded rect so gradients don't paint outside.
    canvas.save();
    canvas.clipRRect(rrect);

    // Top gradient
    final topRect = Rect.fromLTWH(0, 0, size.width, blur);
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0)],
      ).createShader(topRect);
    canvas.drawRect(topRect, topPaint);

    // Bottom gradient
    final bottomRect = Rect.fromLTWH(0, size.height - blur, size.width, blur);
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color, color.withOpacity(0)],
      ).createShader(bottomRect);
    canvas.drawRect(bottomRect, bottomPaint);

    // Left gradient
    final leftRect = Rect.fromLTWH(0, 0, blur, size.height);
    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, color.withOpacity(0)],
      ).createShader(leftRect);
    canvas.drawRect(leftRect, leftPaint);

    // Right gradient
    final rightRect = Rect.fromLTWH(size.width - blur, 0, blur, size.height);
    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [color, color.withOpacity(0)],
      ).createShader(rightRect);
    canvas.drawRect(rightRect, rightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius || oldDelegate.blur != blur;
  }
}

// Small private widget to keep the circular icon consistent and const-friendly.
class _IconCircle extends StatefulWidget {
  final String icon;
  final bool isSelected;
  const _IconCircle({required this.icon, required this.isSelected});

  @override
  State<_IconCircle> createState() => _IconCircleState();
}

class _IconCircleState extends State<_IconCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration:  BoxDecoration(
        boxShadow: [
           BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 0.3,
                offset: const Offset(0, -0.3),
              )
        ],
        color: widget.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          widget.icon,
          color: widget.isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}