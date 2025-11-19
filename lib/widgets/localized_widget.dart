import 'package:flutter/material.dart';
import '../utils/constants/app_language.dart';

/// A widget that rebuilds its child when the app language changes.
/// Use this to wrap widgets that use AppLanguage translations.
/// 
/// Example:
/// ```dart
/// LocalizedWidget(
///   builder: (context) => Text(AppLanguage.welcomeTitle),
/// )
/// ```
class LocalizedWidget extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const LocalizedWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) {
        return builder(context);
      },
    );
  }
}

