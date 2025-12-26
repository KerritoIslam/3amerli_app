import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

class InvoiceDetailPage extends StatefulWidget {
  final String invoiceId;
  final String? pdfUrl;
  const InvoiceDetailPage({super.key, required this.invoiceId, this.pdfUrl});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final pdfUrl = widget.pdfUrl;
    final viewerUrl = pdfUrl != null
        ? 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pdfUrl)}'
        : null;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    if (viewerUrl != null) {
      // Add a small delay to ensure the WebView platform is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.loadRequest(Uri.parse(viewerUrl));
        }
      });
    } else {
      _isLoading = false;
    }
  }

  Future<void> _openPdf() async {
    final pdf = widget.pdfUrl;
    if (pdf == null) {
      if (!mounted) return;
      TopToast.show(context, 'Aucun PDF disponible', isError: true);
      return;
    }
    final uri = Uri.parse(pdf);
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    TopToast.show(context, 'Impossible d\'ouvrir le PDF', isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
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
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                          placeholderBuilder: (context) => Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.invoiceId,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40, height: 40),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.pdfUrl != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            WebViewWidget(controller: _controller),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('Aucun PDF disponible',
                          style: TextStyle(color: Colors.grey))),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(
                  left: 28.0,
                  right: 28.0,
                  bottom: MediaQuery.of(context).padding.bottom + 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _openPdf,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context)
                                    .extension<BrandColors>()
                                    ?.brandTeal ??
                                AppColors.brandTeal),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4)),
                    child: Text('Partager',
                        style: TextStyle(
                            color: Theme.of(context)
                                    .extension<BrandColors>()
                                    ?.brandTeal ??
                                AppColors.brandTeal)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _openPdf,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                                .extension<BrandColors>()
                                ?.brandTeal ??
                            AppColors.brandTeal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8)),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/print.svg',
                            width: 20, height: 20),
                        const SizedBox(width: 8),
                        const Text('Ouvrir',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
