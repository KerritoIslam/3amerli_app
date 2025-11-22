import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/settings.dart';
import '../../../../core/config/injection.dart' as di;
import '../../../../utils/constants/app_language.dart';
import '../../../../core/utils/top_toast.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  static const Color _darkGreen = Color(0xFF083B2E);

  @override
  void initState() {
    super.initState();
    // Listen to language changes to update the UI
    AppLanguage.localeNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLanguage.localeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getLanguageCode() {
    final current = AppLanguage.current;
    switch (current) {
      case AppLocale.fr:
        return 'FR';
      case AppLocale.ar:
        return 'AR';
      case AppLocale.en:
        return 'EN';
    }
  }

  void _openLanguageSelector(BuildContext context) {
    final settings = di.sl<Settings>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLanguage.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
              title: Text(AppLanguage.french),
              onTap: () async {
                Navigator.of(ctx).pop();
                await settings.setLanguage('fr');
                if (context.mounted) {
                  TopToast.show(context, AppLanguage.languageUpdated);
                }
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(AppLanguage.english),
              onTap: () async {
                Navigator.of(ctx).pop();
                await settings.setLanguage('en');
                if (context.mounted) {
                  TopToast.show(context, AppLanguage.languageUpdated);
                }
              },
            ),
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: Text(AppLanguage.arabic),
              onTap: () async {
                Navigator.of(ctx).pop();
                await settings.setLanguage('ar');
                if (context.mounted) {
                  TopToast.show(context, AppLanguage.languageUpdated);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLanguage.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/icons/back_arrow.svg',
                            width: 18,
                            height: 18,
                            colorFilter:
                                ColorFilter.mode(_darkGreen, BlendMode.srcIn),
                            placeholderBuilder: (_) => const Icon(
                                Icons.arrow_back,
                                color: _darkGreen)),
                      ),
                    ),
                    const Spacer(),
                    Center(
                        child: Text(AppLanguage.language,
                            style: const TextStyle(
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: _darkGreen))),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            // Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () => _openLanguageSelector(context),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 40),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    // Use the requested dual shadows to match the design
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1F000000),
                          offset: Offset(4, 4),
                          blurRadius: 8),
                      BoxShadow(
                          color: Color(0x1F000000),
                          offset: Offset(-4, -4),
                          blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(AppLanguage.selectLanguage,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500))),
                      Container(
                        width: 48,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(_getLanguageCode(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _darkGreen)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
