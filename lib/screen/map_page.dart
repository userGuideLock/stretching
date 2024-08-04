import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MapViewController extends GetxController {
  late final WebViewController webViewController;
  var isWebViewLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed
          },
          onPageStarted: (String url) {
            // Optionally handle page start
          },
          onPageFinished: (String url) {
            // Set the WebView as loaded once the page finishes loading
            isWebViewLoaded.value = true;
          },
          onHttpError: (HttpResponseError error) {
            // Optionally handle HTTP errors
            print("HTTP error: $error");
          },
          onWebResourceError: (WebResourceError error) {
            // Optionally handle web resource errors
            print("Web resource error: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://stretching-frontend.web.app')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://stretching-frontend.web.app'));

    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapViewController());

    return Scaffold(
      body: Obx(() {
        if (controller.isWebViewLoaded.value) {
          return WebViewWidget(controller: controller.webViewController);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }
      }),
    );
  }
}
