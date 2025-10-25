import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const Color _darkGreen = Color(0xFF083B2E);

  void _openLanguageSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français (FR)'),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Langue définie sur FR')));
              },
            ),
            ListTile(
              title: const Text('English (EN)'),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to EN')));
              },
            ),
            ListTile(
              title: const Text('العربية (AR)'),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير اللغة إلى العربية')));
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fermer'))],
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
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: SvgPicture.asset('assets/icons/back_arrow.svg', width: 18, height: 18, color: _darkGreen, placeholderBuilder: (_) => const Icon(Icons.arrow_back, color: _darkGreen)),
                    ),
                  ),
                  const Spacer(),
                  Center(child: Text('Language', style: const TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w700, fontSize: 20, color: _darkGreen))),
                  const Spacer(flex: 2),
                ],
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('Modifier la langue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                      Container(
                        width: 48,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                        child: const Text('FR', style: TextStyle(fontWeight: FontWeight.w700, color: _darkGreen)),
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
