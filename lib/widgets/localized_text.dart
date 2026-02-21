import 'package:flutter/material.dart';
import '../utils/constants/app_language.dart';

/// A Text widget that automatically rebuilds when the app language changes.
/// Use this instead of Text() for strings that use AppLanguage.
/// 
/// Example:
/// ```dart
/// LocalizedText(AppLanguage.welcomeTitle)
/// ```
class LocalizedText extends StatelessWidget {
  final String Function() textBuilder;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText(
    this.textBuilder, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) {
        return Text(
          textBuilder(),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}


