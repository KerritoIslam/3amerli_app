import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:amerli_app/features/success/app/pages/success_page.dart';
import 'package:amerli_app/features/failure/app/pages/failure_page.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String checkoutUrl;

  const PaymentWebViewPage({super.key, required this.checkoutUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkForRedirect(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if this is a success/failure redirect
            final url = request.url;

            // Check for custom scheme (amerli://)
            if (url.startsWith('amerli://')) {
              _handleDeepLink(url);
              return NavigationDecision.prevent;
            }

            // Check for HTTPS redirect patterns
            if (url.contains('/payment/success') ||
                url.contains('amerli.app/success')) {
              _handleDeepLink(url);
              return NavigationDecision.prevent;
            }

            if (url.contains('/payment/failure') ||
                url.contains('amerli.app/failure')) {
              _handleDeepLink(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    // Android-specific configuration for reCAPTCHA support
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            // Allow geolocation for reCAPTCHA if needed
            return GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          },
        );
    }

    // Load request after configuration
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkForRedirect(String url) {
    // Also check in onPageStarted for faster detection
    if (url.startsWith('amerli://') ||
        url.contains('/payment/success') ||
        url.contains('/payment/failure') ||
        url.contains('amerli.app/success') ||
        url.contains('amerli.app/failure')) {
      _handleDeepLink(url);
    }
  }

  void _handleDeepLink(String url) {
    debugPrint('🔗 Payment redirect detected: $url');

    // Parse the URL to extract query parameters
    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    // Determine if success or failure
    final isSuccess = url.contains('success');

    if (!mounted) return;

    // Pop the WebView and navigate to appropriate page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isSuccess
            ? SuccessPage(
                orderId: params['orderId'],
                date: params['date'],
                paymentMethod: params['paymentMethod'] ?? params['payementWay'],
                amount: params['amount'] ?? params['total'],
                invoiceUrl: params['invoiceUrl'],
              )
            : FailurePage(
                orderId: params['orderId'],
                date: params['date'],
                paymentMethod: params['paymentMethod'] ?? params['payementWay'],
                amount: params['amount'] ?? params['total'],
                failureReason: params['reason'] ??
                    params['error'] ??
                    AppLanguage.paymentFailed,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(AppLanguage.cancelPayment),
                content: Text(AppLanguage.areYouSureCancelPayment),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLanguage.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLanguage.yesCancel),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          AppLanguage.securePayment,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
