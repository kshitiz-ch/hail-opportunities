import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class WebViewScreen extends StatefulWidget {
  final String? url;
  final Function? callback;
  final Function? onWebViewExit;
  final Function(NavigationRequest)? onNavigationRequest;
  final bool fromPushNotification;
  WebViewScreen({
    this.url,
    this.callback,
    this.onWebViewExit,
    this.onNavigationRequest,
    this.fromPushNotification = false,
  });
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController webViewController;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    initialiseWebViewController();
    // if (Platform.isAndroid) WebViewWidget.platform = SurfaceAndroidWebView();
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
            if (request.url.startsWith('whatsapp://') ||
                request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              LogUtil.printLog('blocking navigation to $request}');
              launch(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('about:blank') ||
                request.url.startsWith('intent')) {
              LogUtil.printLog('blocking navigation to $request}');
              return NavigationDecision.prevent;
            } else {
              if (widget.onNavigationRequest != null) {
                widget.onNavigationRequest!(request);
              }
              LogUtil.printLog('allowing navigation to $request');
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url!));
  }

  void _handleLoad(int value) {
    if (mounted) {
      setState(() {
        loadingPercentage = value;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> goBackHandler() async {
    bool canGoBack = await webViewController.canGoBack();

    if (canGoBack) {
      await webViewController.goBack();
      return;
    }
    if (widget.onWebViewExit != null) {
      widget.onWebViewExit!();
    }
    AutoRouter.of(context).popForced();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, goBackHandler);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Builder(builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ColorConstants.black,
                    size: 24,
                  ),
                  onPressed: () {
                    if (widget.onWebViewExit != null) {
                      widget.onWebViewExit!();
                    } else if (widget.callback == null) {
                      AutoRouter.of(context).popForced();
                    } else {
                      widget.callback!(context);
                    }
                  },
                ),
              );
            })
          ],
          // leading: Builder(builder: (BuildContext context) {
          //   return IconButton(
          //     icon: Icon(
          //       Icons.close,
          //       color: ColorConstants.black,
          //       size: 24,
          //     ),
          //     onPressed: () {
          //       if (widget.onWebViewExit != null) {
          //         widget.onWebViewExit();
          //       } else if (widget.callback == null) {
          //         AutoRouter.of(context).popForced();
          //       } else {
          //         widget.callback(context);
          //       }
          //     },
          //   );
          // }),
          backgroundColor: ColorConstants.white,
          elevation: 0,
        ),
        body: IndexedStack(
          index: loadingPercentage == 100 ? 0 : 1,
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: WebViewWidget(
                    controller: webViewController,
                  ),
                ),
              ],
            ),
            CommonUI.buildWebViewProgressiveLoader(loadingPercentage),
          ],
        ),
      ),
    );
  }
}
