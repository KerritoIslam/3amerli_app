import 'package:flutter/material.dart';

import '../utils/constants/app_colors.dart';
import '../utils/constants/app_dimensions.dart';
import '../utils/constants/app_text_styles.dart';

/// AppButton
///
/// A flexible, app-styled button used across the application.
/// Defaults:
/// - full circular corners (AppDimensions.radiusFull)
/// - filled with theme primary color
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = AppDimensions.radiusFull,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.height,
    this.width,
    this.isLoading = false,
    this.enabled = true,
    this.textStyle,
    this.isOutlined = false,
    this.isFilled = true,
    this.isText = false,
    this.tooltip,
  });

  // Core
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;

  // Styling
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  // Behavior
  final bool isLoading;
  final bool enabled;

  // Text
  final TextStyle? textStyle;

  // Shape & Type
  final bool isOutlined;
  final bool isFilled;
  final bool isText;

  // Accessibility
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primary = backgroundColor ?? theme.colorScheme.primary;
    final Color onPrimary = textColor ?? theme.colorScheme.onPrimary;
    final Color resolvedBorderColor = borderColor ?? AppColors.greyBorder;
  final EdgeInsetsGeometry defaultPadding = padding ?? const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM, vertical: AppDimensions.spacing);
  final double defaultHeight = height ?? 48.0; // fallback if not provided
  final TextStyle defaultTextStyle = (textStyle ?? AppTextStyles.buttonLargeBold).copyWith(color: onPrimary);

    final child = isLoading
        ? SizedBox(
            height: (defaultHeight * 0.5),
            width: (defaultHeight * 0.5),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: defaultTextStyle,
                ),
              ),
            ],
          );

    final buttonChild = Padding(
      padding: defaultPadding,
      child: Center(child: child),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: resolvedBorderColor, width: borderWidth),
    );

    Widget button;

    final effectiveOnPressed = (enabled && !isLoading) ? onPressed : null;

    if (isText) {
      button = TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: shape,
          foregroundColor: textColor ?? theme.textTheme.labelLarge?.color,
        ),
        child: SizedBox(width: width, height: defaultHeight, child: buttonChild),
      );
    } else if (isOutlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: resolvedBorderColor, width: borderWidth),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          foregroundColor: textColor ?? theme.colorScheme.primary,
          backgroundColor: isFilled ? primary.withOpacity(0.02) : Colors.transparent,
        ),
        child: SizedBox(width: width, height: defaultHeight, child: buttonChild),
      );
    } else {
      // Filled (default)
      button = ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: EdgeInsets.zero,
        ),
        child: SizedBox(width: width, height: defaultHeight, child: buttonChild),
      );
    }

    final wrapped = tooltip != null ? Tooltip(message: tooltip!, child: button) : button;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 0),
      child: wrapped,
    );
  }
}
