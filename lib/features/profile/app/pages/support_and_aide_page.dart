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
  static const Color _linkBlue = Color(0xFF007AFF);

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
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => _launchPhone('+213770123456'),
                      child: Text('+213 770 123 456', style: const TextStyle(fontSize: 16, color: _linkBlue, height: 1.25)),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchEmail('Support@3ammerli.dz'),
                      child: Text('Support@3ammerli.dz', style: const TextStyle(fontSize: 16, color: _linkBlue, height: 1.25)),
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
