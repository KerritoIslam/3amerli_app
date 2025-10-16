import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A small circular icon used across the app. Shows a filled circle when
/// selected and an outline/alternate color when not.
class IconCircle extends StatelessWidget {
  /// Path to an SVG asset to render inside the circle. If null, [dataIcon]
  /// will be used instead.
  final String? asset;
  /// Fallback `IconData` used when [asset] is null.
  final IconData? dataIcon;
  /// Optional override for the circle background when selected.
  final Color? selectedColor;
  /// Optional override for the circle background when not selected.
  final Color? unselectedColor;
  final bool isSelected;
  /// Diameter of the circular container. Defaults to 40.0
  final double size;
  /// Size of the inner icon. If null it's derived from [size].
  /// Defaults to half of [size] clamped between 16 and 24.
  final double? iconSize;
  /// If true, keep the icon's original color (do not override with theme colors).
  final bool keepIconColor;

  const IconCircle({
    Key? key,
    this.asset,
    this.dataIcon,
    required this.isSelected,
    this.selectedColor,
    this.unselectedColor,
    this.size = 40.0,
    this.iconSize,
    this.keepIconColor = false,
  })  : assert(asset != null || dataIcon != null, 'Either asset or dataIcon must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
  final effectiveIconSize = (iconSize ?? (size * 0.5)).clamp(16.0, 24.0);
    // Determine colors, falling back to the theme when overrides are null.
    final bgColor = isSelected
        ? (selectedColor ?? Theme.of(context).colorScheme.tertiaryContainer)
        : (unselectedColor ?? Theme.of(context).colorScheme.onPrimary);
    final Color? iconColor = keepIconColor
        ? null
        : (isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.tertiaryContainer);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 0.3,
            offset: const Offset(0, -0.3),
          )
        ],
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: asset != null
            ? SvgPicture.asset(
                asset!,
                // pass color only when not preserving original colors
                color: iconColor,
                width: effectiveIconSize,
                height: effectiveIconSize,
              )
            : Icon(
                dataIcon,
                // pass color only when not preserving original colors
                color: iconColor,
                size: effectiveIconSize,
              ),
      ),
    );
  }
}
