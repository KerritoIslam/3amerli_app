import 'package:flutter/material.dart';

/// A small, reusable custom tab bar with an animated bottom indicator.
///
/// - Tabs are provided as a list of widgets (commonly Text).
/// - The indicator slides under the active tab and has configurable height/color.
/// - Tabs are evenly spaced across available width.
class CustomTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color indicatorColor;
  final Color inactiveColor;
  final double indicatorHeight;
  final Duration duration;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;
  final EdgeInsetsGeometry padding;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.indicatorColor = Colors.black,
    this.inactiveColor = const Color(0xFFD3D3D3),
    this.indicatorHeight = 4.0,
    this.duration = const Duration(milliseconds: 220),
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  })  : assert(tabs.length > 0),
        assert(currentIndex >= 0 && currentIndex < tabs.length),
        super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    final activeStyle = widget.activeTextStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    final inactiveStyle = widget.inactiveTextStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.inactiveColor);

    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final tabCount = widget.tabs.length;
      final tabWidth = totalWidth.isFinite && tabCount > 0 ? totalWidth / tabCount : 0.0;

      return Container(
        padding: widget.padding,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Row of tabs
            Row(
              children: List.generate(widget.tabs.length, (i) {
                final isActive = i == widget.currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => widget.onTap(i),
                    splashFactory: NoSplash.splashFactory,
                    child: Center(
                      child: DefaultTextStyle.merge(
                        style: isActive ? (activeStyle ?? const TextStyle()) : (inactiveStyle ?? const TextStyle()),
                        child: widget.tabs[i],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Animated indicator
            if (tabWidth > 0)
              AnimatedPositioned(
                duration: widget.duration,
                curve: Curves.easeInOut,
                left: widget.currentIndex * tabWidth,
                bottom: 0,
                width: tabWidth,
                height: widget.indicatorHeight,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    height: widget.indicatorHeight,
                    color: widget.indicatorColor,
                  ),
                ),
              ),

            // Thin top divider to match the subtle tick look from the design
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(height: 1, color: widget.inactiveColor.withOpacity(0.25)),
            ),
          ],
        ),
      );
    });
  }
}
