import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class CreditCardWebViewScreen extends StatefulWidget {
  final Map<String, String>? header;
  final String? url;
  final Function? callback;
  final Function? onWebViewExit;
  final Future<NavigationActionPolicy> Function(
      InAppWebViewController, NavigationAction)? onNavigationRequest;
  final bool fromPushNotification;
  CreditCardWebViewScreen({
    this.url,
    this.callback,
    this.onWebViewExit,
    this.onNavigationRequest,
    this.fromPushNotification = false,
    this.header,
  });
  @override
  _CreditCardWebViewScreenState createState() =>
      _CreditCardWebViewScreenState();
}

class _CreditCardWebViewScreenState extends State<CreditCardWebViewScreen> {
  late InAppWebViewController webViewController;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    LogUtil.printLog('webview url ==>${widget.url}');

    // if (Platform.isAndroid) WebViewWidget.platform = SurfaceAndroidWebView();
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
        onPopInvoked(didPop, () {
          goBackHandler();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<DownloadController>(
            init: DownloadController(),
            tag: 'credit-card',
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: IndexedStack(
                      index: loadingPercentage == 100 ? 0 : 1,
                      children: [
                        Column(
                          children: <Widget>[
                            Expanded(
                              child: InAppWebView(
                                initialUrlRequest: URLRequest(
                                  headers: widget.header,
                                  url: WebUri.uri(Uri.parse(widget.url!)),
                                ),
                                initialSettings: InAppWebViewSettings(
                                  disableDefaultErrorPage: true,
                                  useHybridComposition: true,
                                  allowFileAccessFromFileURLs: true,
                                  allowUniversalAccessFromFileURLs: true,
                                  useShouldOverrideUrlLoading: true,
                                  useOnDownloadStart: true,
                                ),
                                onWebViewCreated:
                                    (InAppWebViewController controller) {
                                  webViewController = controller;
                                },
                                onLoadStart: (InAppWebViewController controller,
                                    Uri? uri) {},
                                onLoadStop: (InAppWebViewController controller,
                                    Uri? uri) async {
                                  LogUtil.printLog('onLoadStop');
                                },
                                onProgressChanged:
                                    (InAppWebViewController controller,
                                        int progress) {
                                  _handleLoad(progress);
                                },
                                onDownloadStartRequest:
                                    (InAppWebViewController controller,
                                        DownloadStartRequest request) {
                                  onDownloadStartRequest(controller, request);
                                },
                                shouldOverrideUrlLoading:
                                    (InAppWebViewController controller,
                                        NavigationAction action) {
                                  final navigationUrl =
                                      action.request.url.toString();
                                  if (navigationUrl.startsWith('whatsapp://') ||
                                      navigationUrl.startsWith('mailto:') ||
                                      navigationUrl.startsWith('tel:')) {
                                    LogUtil.printLog(
                                        'blocking navigation to $navigationUrl}');
                                    launch(navigationUrl);
                                    return Future.value(
                                        NavigationActionPolicy.CANCEL);
                                  } else if (navigationUrl
                                      .startsWith('about:blank')) {
                                    LogUtil.printLog(
                                        'blocking navigation to $navigationUrl}');
                                    return Future.value(
                                        NavigationActionPolicy.CANCEL);
                                  } else {
                                    if (widget.onNavigationRequest != null) {
                                      return widget.onNavigationRequest!(
                                          controller, action);
                                    }
                                    LogUtil.printLog(
                                        'allowing navigation to $navigationUrl');
                                    return Future.value(
                                        NavigationActionPolicy.ALLOW);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        CommonUI.buildWebViewProgressiveLoader(
                          loadingPercentage,
                          Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildAppBar() {
    final topPadding = getSafeTopPadding(30, context);
    final height = 70 + topPadding;
    return Container(
      color: ColorConstants.primaryAppColor,
      child: Stack(
        children: [
          Image.asset(
            AllImages().backgroundPatternIcon,
            alignment: Alignment.centerRight,
            height: height,
            width: double.infinity,
          ),
          Container(
            height: height,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20)
                .copyWith(top: topPadding),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    await goBackHandler();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    AllImages().wealthyIcon,
                    height: 32,
                    width: 72,
                  ),
                ),
                Text(
                  'Credit Cards',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.white,
                          ),
                ),
                Expanded(
                  child: Image.asset(
                    AllImages().creditCardIcon,
                    alignment: Alignment.centerRight,
                    height: 30,
                    width: 30,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _downloadFile(String base64code) async {
    PermissionStatus storageStatus = await getStorePermissionStatus();
    if (storageStatus.isGranted) {
      try {
        AutoRouter.of(context).pushNativeRoute(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
          ),
        );
        List splitByBase64 = base64code.split(";base64,");
        Uint8List bytes = base64.decode(splitByBase64[1]);

        String? downloadPath = await getDownloadPath();

        List splitBySlash = splitByBase64[0].split("/");
        String fileExtension = splitBySlash[1] ?? 'jpg';
        final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());

        File fileImg = File('$downloadPath/$date.${fileExtension}');
        await fileImg.writeAsBytes(List.from(bytes));
        bool isImageExists = await fileImg.exists();
        if (isImageExists) {
          await shareFiles(fileImg.path);
        }
        showToast(text: 'Downloaded');
      } catch (error) {
        LogUtil.printLog(error);
      } finally {
        AutoRouter.of(context).popForced();
      }
    } else {
      showToast(text: 'Please grant storage permission');
    }
  }

  void _downloadAsset(String url) async {
    DownloadController downloadController =
        Get.find<DownloadController>(tag: 'credit-card');
    List splitBySlash = url.split("/");
    final fileName = splitBySlash[splitBySlash.length - 1];
    String fileExt = fileName.substring(fileName.lastIndexOf('.'));
    downloadController.downloadFile(
      url: url,
      filename: fileName,
      extension: fileExt,
    );
  }

  void onDownloadStartRequest(
      InAppWebViewController controller, DownloadStartRequest request) {
    final navigationUrl = request.url.toString();
    // Share proposal Url
    if (navigationUrl.startsWith("share:")) {
      String shareUrl = navigationUrl.split("share:")[1];
      shareText(shareUrl);
    }
    if (navigationUrl.startsWith("data:")) {
      _downloadFile(navigationUrl);
    }

    if (isDownloadableUrl(navigationUrl)) {
      _downloadAsset(navigationUrl);
    }
  }
}
