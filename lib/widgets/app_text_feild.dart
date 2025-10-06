import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants/app_colors.dart';
import '../utils/constants/app_dimensions.dart';

/// A flexible, reusable input field used across the app.
///
/// Notes:
/// - If [controller] is not provided the widget will create and manage one
///   internally and expose the text through the controller property.
/// - [leading] and [trailing] are optional widgets shown before/after the
///   field (leading inside prefix, trailing inside suffix area).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.autovalidateMode,
    this.hintText,
    this.labelText,
    this.leading,
    this.trailing,
    this.fillColor,
    this.filled,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.contentPadding,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.inputFormatters,
    this.obscuringCharacter = '•',
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.errorText,
    this.onTap,
    this.suffixText,
    this.prefixText,
    this.textCapitalization = TextCapitalization.none,
    this.onEditingComplete,
  });

  // Basic control
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  // Input Type
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  // Validation
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  // Decoration
  final String? hintText;
  final String? labelText;
  final Widget? leading;
  final Widget? trailing;
  final Color? fillColor;
  final bool? filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final EdgeInsetsGeometry? contentPadding;

  // Behavior
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;

  // Text styling
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;

  // Security & input
  final List<TextInputFormatter>? inputFormatters;
  final String obscuringCharacter;

  // Accessibility & misc
  final TextAlign textAlign;
  final bool autofocus;
  final String? errorText;
  final VoidCallback? onTap;
  final String? suffixText;
  final String? prefixText;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _internalController;
  bool _usingInternalController = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _usingInternalController = true;
      _internalController = TextEditingController();
    } else {
      _internalController = widget.controller!;
    }
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null &&
        _usingInternalController) {
      // Switch to external controller provided by parent
      _internalController.dispose();
      _usingInternalController = false;
    } else if (oldWidget.controller != null && widget.controller == null &&
        !_usingInternalController) {
      // Parent removed controller, create internal one
      _internalController = TextEditingController.fromValue(_effectiveController.value);
      _usingInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_usingInternalController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppDimensions.radiusFull);
    final defaultBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.0),
    );

    final effectiveDecoration = InputDecoration(
      hintText: widget.hintText,
      labelText: widget.labelText,
      prefixIcon: widget.leading,
      suffixIcon: widget.trailing,
      fillColor: widget.fillColor,
      filled: widget.filled ?? false,
      border: widget.border ?? defaultBorder,
      enabledBorder: widget.enabledBorder ?? defaultBorder,
      focusedBorder: widget.focusedBorder ?? defaultBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.2),
      ),
      contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      errorText: widget.errorText,
      hintStyle: widget.hintStyle,
      labelStyle: widget.labelStyle,
      suffixText: widget.suffixText,
      prefixText: widget.prefixText,
    );

    return TextFormField(
      controller: _effectiveController,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      style: widget.style,
      inputFormatters: widget.inputFormatters,
      obscuringCharacter: widget.obscuringCharacter,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      decoration: effectiveDecoration,
    );
  }
}
