import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportAndAidePage extends StatefulWidget {
  const SupportAndAidePage({super.key});

  @override
  State<SupportAndAidePage> createState() => _SupportAndAidePageState();
}

class _SupportAndAidePageState extends State<SupportAndAidePage> {
  static const Color _darkGreen = Color(0xFF083B2E);
  

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le composeur téléphonique')));
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le client mail')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Support & Aide',
                            style: const TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w700, fontSize: 20, color: _darkGreen)),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Besoin d\'aide ? Nous sommes là pour vous', style: const TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w700, fontSize: 18, color: _darkGreen)),
                    const SizedBox(height: 12),
                    const Text('Contactez-nous directement au :', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    // Phone and email in a single horizontal line; use horizontal scroll if viewport is too small
                    SizedBox(
                      height: 28,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _launchPhone('+213770123456'),
                              child: Text(
                                '+213 770 123 456',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal, height: 1.25 , decoration: TextDecoration.underline , decorationColor: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('ou', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.25)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _launchEmail('Support@3ammerli.dz'),
                              child: Text(
                                'Support@3ammerli.dz',
                                style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal, height: 1.25 , decoration: TextDecoration.underline , decorationColor: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal,
                              ),
                            ),
                        )],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
