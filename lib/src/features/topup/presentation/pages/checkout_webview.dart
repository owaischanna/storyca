import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens a Flutterwave hosted checkout [link] and watches every navigation
/// for the redirect back to storryca.com/top-up, which carries the payment
/// outcome on its query string. Pops with `{tx_ref, transaction_id}` (or
/// `null` if the reader backs out without paying) — the caller still has to
/// call `/wallet/verify` with those, since this screen never decides on its
/// own whether the payment succeeded.
class CheckoutWebview extends StatefulWidget {
  const CheckoutWebview({super.key, required this.link});

  final String link;

  @override
  State<CheckoutWebview> createState() => _CheckoutWebviewState();
}

class _CheckoutWebviewState extends State<CheckoutWebview> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _handleNavigation(url),
          onNavigationRequest: (request) {
            _handleNavigation(request.url);
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  void _handleNavigation(String url) {
    if (_handled) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final query = uri.queryParameters;
    final txRef = query['tx_ref'];
    final transactionId = query['transaction_id'];
    if (txRef == null && transactionId == null) return;
    _handled = true;
    context.pop({'tx_ref': txRef, 'transaction_id': transactionId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      appBar: AppBar(
        backgroundColor: Color(0xFF020004),
        foregroundColor: Colors.white,
        title: const Text('Top Up'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
