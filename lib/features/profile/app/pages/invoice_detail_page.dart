import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceDetailPage extends StatefulWidget {
  final String invoiceId;
  final String? pdfUrl;
  const InvoiceDetailPage({super.key, required this.invoiceId, this.pdfUrl});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  static const Color _darkGreen = Color(0xFF083B2E);
  static const Color _primary = Color(0xFFA7C957);

  Future<void> _openPdf() async {
    final pdf = widget.pdfUrl;
    if (pdf == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun PDF disponible')));
      return;
    }
    final uri = Uri.parse(pdf);
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le PDF')));
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
                        child: SvgPicture.asset('assets/icons/back_arrow.svg', width: 18, height: 18, color: _darkGreen, placeholderBuilder: (_) => const Icon(Icons.arrow_back, color: _darkGreen)),
                      ),
                    ),
                    const Spacer(),
                    Center(child: Text(widget.invoiceId, style: const TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w700, fontSize: 20, color: _darkGreen))),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primary),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Center(child: Text('Invoice preview for ${widget.invoiceId}', style: const TextStyle(color: Colors.black54))),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _openPdf,
                            style: OutlinedButton.styleFrom(
                                side:  BorderSide(color: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4)),
                            child:  Text('Partager', style: TextStyle(color: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal)),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _openPdf,
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/icons/print.svg', width: 20, height: 20),
                                const SizedBox(width: 8),
                                const Text('Imprimer', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
