import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const PaymentWebViewPage({Key? key, required this.url, this.title}) : super(key: key);

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Clear all cookies and cache before loading payment page
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    
    // Create controller with platform-specific parameters
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);
    
    // Configure Android-specific settings for reCAPTCHA support
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = _controller.platform as AndroidWebViewController;
      
      // Clear cache to start fresh
      await androidController.clearCache();
      
      androidController
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            return GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          },
        );
    }
    
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          // ignore: avoid_print
          print('🌐 WebView loading: $url');
        },
        onPageFinished: (String url) async {
          // ignore: avoid_print
          print('✅ WebView loaded: $url');
          
          // Enable DOM storage and database for reCAPTCHA
          if (_controller.platform is AndroidWebViewController) {
            final androidController = _controller.platform as AndroidWebViewController;
            
            // Inject storage polyfills and ensure cookies are enabled
            await androidController.runJavaScript('''
              // Enable localStorage and sessionStorage
              window.localStorage = window.localStorage || {};
              window.sessionStorage = window.sessionStorage || {};
              
              // Log for debugging
              console.log('WebView loaded successfully');
              console.log('User Agent:', navigator.userAgent);
              console.log('Cookies enabled:', navigator.cookieEnabled);
            ''');
          }
          
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        onWebResourceError: (WebResourceError error) {
          // ignore: avoid_print
          print('❌ WebView error: ${error.description} | Code: ${error.errorCode} | Type: ${error.errorType}');
        },
        onNavigationRequest: (NavigationRequest request) {
          // ignore: avoid_print
          print('🔗 Navigation to: ${request.url}');
          
          // Intercept custom scheme deep links (amerli://)
          if (request.url.startsWith('amerli://')) {
            // ignore: avoid_print
            print('✅ Detected deep link: ${request.url}');
            
            // Parse the URL to extract route and query parameters
            final uri = Uri.parse(request.url);
            final host = uri.host; // 'success' or 'failure'
            final queryParams = uri.queryParameters;
            
            // ignore: avoid_print
            print('📍 Route: /$host with params: $queryParams');
            
            if (mounted) {
              // Build the route path with query parameters
              final queryString = queryParams.entries
                  .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
                  .join('&');
              
              final routePath = '/$host${queryString.isNotEmpty ? '?$queryString' : ''}';
              
              // ignore: avoid_print
              print('🚀 Navigating to: $routePath');
              
              // Use go_router to navigate
              context.go(routePath);
            }
            
            return NavigationDecision.prevent;
          }
          
          // Allow all other navigation for payment flow
          return NavigationDecision.navigate;
        },
      ))
      // Set a modern user agent to ensure compatibility with reCAPTCHA
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36')
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Paiement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement du paiement...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
