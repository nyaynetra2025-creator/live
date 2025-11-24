import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetailPage extends StatefulWidget {
  final String title;
  final String link;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.link,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late final WebViewController _webViewController;
  bool _isWebLoading = true;

  @override
  void initState() {
    super.initState();
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isWebLoading = true);
          },
          onPageFinished: (String url) {
            // Inject CSS to remove ads and clean up the page
            _webViewController.runJavaScript('''
              (function() {
                // Create and inject style element
                var style = document.createElement('style');
                style.innerHTML = `
                  /* Hide ads and promotional content */
                  [class*="ad-"], [id*="ad-"], [class*="advertisement"], 
                  [id*="advertisement"], iframe[src*="ad"], 
                  [class*="promo"], [id*="promo"],
                  /* Hide headers, navigation, and menus */
                  header, nav, .header, .navigation, .nav, .menu,
                  [class*="header"], [id*="header"], [class*="nav"],
                  /* Hide footers */
                  footer, .footer, [class*="footer"], [id*="footer"],
                  /* Hide subscribe buttons and popups */
                  [class*="subscribe"], [id*="subscribe"],
                  [class*="popup"], [class*="modal"], [class*="overlay"],
                  /* Hide social share buttons */
                  [class*="share"], [class*="social"],
                  /* Hide related articles and recommendations */
                  [class*="related"], [class*="recommended"],
                  [class*="trending"], [class*="popular"],
                  /* Hide breadcrumbs */
                  [class*="breadcrumb"], [id*="breadcrumb"],
                  /* Hide author info and metadata (optional) */
                  [class*="author"], [class*="byline"],
                  /* Hide comments section */
                  [class*="comment"], [id*="comment"]
                  {
                    display: none !important;
                    visibility: hidden !important;
                    height: 0 !important;
                    width: 0 !important;
                    margin: 0 !important;
                    padding: 0 !important;
                  }
                  
                  /* Make article content full width and centered */
                  body {
                    max-width: 100% !important;
                    padding: 16px !important;
                    background: white !important;
                  }
                  
                  /* Article content styling */
                  article, main, [role="main"] {
                    max-width: 100% !important;
                    margin: 0 auto !important;
                    padding: 0 !important;
                  }
                  
                  /* Hide sticky elements */
                  [style*="position: fixed"], [style*="position: sticky"] {
                    position: relative !important;
                  }
                `;
                document.head.appendChild(style);
                
                // Remove specific elements by tag
                var elementsToRemove = document.querySelectorAll(
                  'header, nav, footer, aside, [role="banner"], [role="navigation"], [role="complementary"]'
                );
                elementsToRemove.forEach(function(el) {
                  el.style.display = 'none';
                });
              })();
            ''');
            
            if (mounted) setState(() => _isWebLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('News Article'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isWebLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
