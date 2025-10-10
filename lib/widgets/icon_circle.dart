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

  const IconCircle({
    Key? key,
    this.asset,
    this.dataIcon,
    required this.isSelected,
    this.selectedColor,
    this.unselectedColor,
    this.size = 40.0,
    this.iconSize,
  })  : assert(asset != null || dataIcon != null, 'Either asset or dataIcon must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
  final effectiveIconSize = (iconSize ?? (size * 0.5)).clamp(16.0, 24.0);
    // Determine colors, falling back to the theme when overrides are null.
    final bgColor = isSelected
        ? (selectedColor ?? Theme.of(context).colorScheme.primary)
        : (unselectedColor ?? Theme.of(context).colorScheme.onPrimary);
    final iconColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;

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
                color: iconColor,
                width: effectiveIconSize,
                height: effectiveIconSize,
              )
            : Icon(
                dataIcon,
                color: iconColor,
                size: effectiveIconSize,
              ),
      ),
    );
  }
}
