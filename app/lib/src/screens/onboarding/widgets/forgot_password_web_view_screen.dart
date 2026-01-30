import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class ForgotPasswordWebViewScreen extends StatefulWidget {
  final String? url;

  const ForgotPasswordWebViewScreen({Key? key, required this.url})
      : super(key: key);

  @override
  State<ForgotPasswordWebViewScreen> createState() =>
      _ForgotPasswordWebViewScreenState();
}

class _ForgotPasswordWebViewScreenState
    extends State<ForgotPasswordWebViewScreen> {
  int loadingPercentage = 0;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    initialiseWebViewController();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _handleLoad(int value) {
    if (mounted) {
      setState(() {
        loadingPercentage = value;
      });
    }
  }

  void initialiseWebViewController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _handleLoad(progress);
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            LogUtil.printLog("request.url ${request.url}");
            if (request.url.endsWith('/dashboards/login/')) {
              //go to app login page instead web login page
              AutoRouter.of(context)
                  .popUntil(ModalRoute.withName(SignInEmailRoute.name));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url!));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.white,
      child: IndexedStack(
        index: loadingPercentage == 100 ? 0 : 1,
        children: [
          WebViewWidget(
            controller: webViewController,
          ),
          CommonUI.buildWebViewProgressiveLoader(loadingPercentage),
        ],
      ),
    );
  }
}
