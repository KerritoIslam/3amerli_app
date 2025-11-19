import 'package:flutter/material.dart';
import '../utils/constants/app_dimensions.dart';

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
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  this.indicatorColor = Colors.black,
  this.inactiveColor = const Color(0xFFD3D3D3),
  this.indicatorHeight = AppDimensions.spacing,
    this.duration = const Duration(milliseconds: 220),
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  })  : assert(tabs.length > 0),
        assert(currentIndex >= 0 && currentIndex < tabs.length);

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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(builder: (context, constraints) {
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

              // Draw inactive segments (one per tab) with gaps between them so
              // inactiveColor is visible as discrete ticks instead of a single bar.
              if (tabWidth > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: widget.indicatorHeight,
                  child: Row(
                    children: List.generate(tabCount, (i) {
                      final segWidth = (tabWidth > AppDimensions.spacing) ? tabWidth - AppDimensions.spacing : tabWidth * 0.8;
                      return SizedBox(
                        width: tabWidth,
                        child: Center(
                          child: Container(
                            width: segWidth,
                            height: widget.indicatorHeight,
                            decoration: BoxDecoration(
                              color: widget.inactiveColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(widget.indicatorHeight / 2),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

            // Animated indicator (narrower than full tab width so gaps show)
            if (tabWidth > 0)
              AnimatedPositioned(
                duration: widget.duration,
                curve: Curves.easeInOut,
                left: widget.currentIndex * tabWidth + (AppDimensions.spacing / 2),
                bottom: 0,
                width: (tabWidth > AppDimensions.spacing) ? tabWidth - AppDimensions.spacing : tabWidth * 0.8,
                height: widget.indicatorHeight,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    height: widget.indicatorHeight,
                    decoration: BoxDecoration(
                      color: widget.indicatorColor,
                      borderRadius: BorderRadius.circular(widget.indicatorHeight / 2),
                    ),
                  ),
                ),
              ),

            // (top divider removed as per design request)
          ],
        ),
      );
    }),
    );
  }
}
