import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class InsuranceWebViewScreen extends StatefulWidget {
  final String? url;
  final Function? callback;
  final Function? onWebViewExit;
  final Future<NavigationActionPolicy> Function(
      InAppWebViewController, NavigationAction)? onNavigationRequest;
  final bool fromPushNotification;
  // For certain insurance like term,
  // the appbar is completely handled by insurance platform
  final bool shouldHandleAppBar;

  InsuranceWebViewScreen({
    this.url,
    this.shouldHandleAppBar = true,
    this.callback,
    this.onWebViewExit,
    this.onNavigationRequest,
    this.fromPushNotification = false,
  });
  @override
  _InsuranceWebViewScreenState createState() => _InsuranceWebViewScreenState();
}

class _InsuranceWebViewScreenState extends State<InsuranceWebViewScreen> {
  bool showAppBar = false;
  bool showBackButton = false;
  late InAppWebViewController _webViewController;

  int loadingPercentage = 0;

  bool fromBackButton = false;
  bool stopNavigation = false;

  void _handleLoad(int value) {
    if (mounted) {
      setState(() {
        loadingPercentage = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    showAppBar = widget.shouldHandleAppBar;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    super.dispose();
  }

  Future<bool> goBackHandler() async {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(top: 30),
          child: GetBuilder<DownloadController>(
              init: DownloadController(),
              tag: 'insurance',
              builder: (_) {
                return Column(
                  children: [
                    if (showAppBar)
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: getSafeTopPadding(16, context),
                          bottom: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (showBackButton)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: ColorConstants.black,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  try {
                                    bool canGoBack =
                                        await _webViewController.canGoBack();

                                    if (canGoBack) {
                                      if (!fromBackButton) {
                                        setState(() {
                                          fromBackButton = true;
                                        });
                                      }

                                      _webViewController.goBack();

                                      // There is some delay in loading the previous page
                                      await Future.delayed(
                                          Duration(milliseconds: 1000));
                                      // String currentUrl =
                                      // await webViewController.currentUrl();

                                      Uri currentUri =
                                          (await _webViewController.getUrl())!;

                                      bool isInsuranceUrl = currentUri.origin
                                              .contains(
                                                  "insurance.wealthyinsurance") ||
                                          currentUri.origin
                                              .contains("www.wealthyinsurance");

                                      if (isInsuranceUrl) {
                                        if (widget.shouldHandleAppBar) {
                                          setState(() {
                                            showBackButton = false;
                                            showAppBar = true;
                                            fromBackButton = false;
                                          });
                                        } else {
                                          setState(() {
                                            showBackButton = false;
                                            showAppBar = false;
                                            fromBackButton = false;
                                          });
                                        }
                                      }

                                      // return Future.value(false);
                                    } else {
                                      AutoRouter.of(context).popForced();
                                    }
                                  } catch (error) {
                                    LogUtil.printLog(error);
                                  }
                                },
                              )
                            else
                              SizedBox(),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: ColorConstants.black,
                                size: 24,
                              ),
                              onPressed: () async {
                                if (widget.onWebViewExit != null) {
                                  widget.onWebViewExit!();
                                } else if (widget.callback == null) {
                                  AutoRouter.of(context).popForced();
                                } else {
                                  widget.callback!(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: loadingPercentage == 100 ? 0 : 1,
                        children: [
                          Column(
                            children: <Widget>[
                              Expanded(
                                child: InAppWebView(
                                  initialUrlRequest: URLRequest(
                                    url: WebUri.uri(Uri.parse(widget.url!)),
                                  ),
                                  onPermissionRequest:
                                      (controller, request) async {
                                    bool permissionsReady =
                                        await _areFileUploadPermissionsReady();
                                    if (!permissionsReady) {
                                      LogUtil.printLog(
                                          'File upload permissions not ready - requesting permissions');
                                      await _requestFileUploadPermissions();
                                    } else {
                                      LogUtil.printLog(
                                          'File upload permissions already ready');
                                    }
                                    return PermissionResponse(
                                      resources: request.resources,
                                      action: PermissionResponseAction.GRANT,
                                    );
                                  },
                                  initialSettings: InAppWebViewSettings(
                                    disableDefaultErrorPage: true,
                                    useHybridComposition: true,
                                    allowFileAccessFromFileURLs: true,
                                    allowUniversalAccessFromFileURLs: true,
                                    useShouldOverrideUrlLoading: true,
                                    useOnDownloadStart: true,
                                    useOnLoadResource: true,
                                    mediaPlaybackRequiresUserGesture: false,
                                    allowFileAccess: true,
                                    javaScriptEnabled: true,
                                    domStorageEnabled: true,
                                    // Additional settings for file upload support
                                    supportMultipleWindows: true,
                                    javaScriptCanOpenWindowsAutomatically: true,
                                    // Mixed content settings
                                    mixedContentMode: MixedContentMode
                                        .MIXED_CONTENT_ALWAYS_ALLOW,
                                    // Try disabling hybrid composition if file upload doesn't work
                                    // useHybridComposition: false,
                                    // Force user agent that supports file uploads
                                    // userAgent:
                                    //     "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.193 Mobile Safari/537.36",
                                  ),
                                  onWebViewCreated:
                                      (InAppWebViewController controller) {
                                    _webViewController = controller;
                                  },
                                  onCreateWindow:
                                      (controller, createWindowAction) async {
                                    // This is essential for file upload dialogs to work
                                    LogUtil.printLog(
                                        'onCreateWindow triggered - URL: ${createWindowAction.request.url}');
                                    LogUtil.printLog(
                                        'onCreateWindow - WindowId: ${createWindowAction.windowId}');
                                    LogUtil.printLog(
                                        'onCreateWindow - isDialog: ${createWindowAction.isDialog}');

                                    final url = createWindowAction.request.url
                                        .toString();
                                    // For file uploads, we need to allow window creation
                                    // but also handle it properly
                                    if (createWindowAction.isDialog == true) {
                                      LogUtil.printLog(
                                          'Dialog window detected - allowing creation for file upload');
                                      return true;
                                    }

                                    // For other new windows, create a headless webview for download
                                    LogUtil.printLog(
                                        'Creating headless webview for download: $url');

                                    await _createHeadlessWebViewForDownload(
                                        createWindowAction);

                                    return true;
                                  },
                                  onJsAlert:
                                      (controller, jsAlertRequest) async {
                                    // Handle JavaScript alerts
                                    LogUtil.printLog(
                                        'onJsAlert triggered - Message: ${jsAlertRequest.message}');
                                    LogUtil.printLog(
                                        'onJsAlert - URL: ${jsAlertRequest.url}');
                                    return JsAlertResponse(
                                      handledByClient: false,
                                    );
                                  },
                                  onJsConfirm:
                                      (controller, jsConfirmRequest) async {
                                    // Handle JavaScript confirms
                                    LogUtil.printLog(
                                        'onJsConfirm triggered - Message: ${jsConfirmRequest.message}');
                                    LogUtil.printLog(
                                        'onJsConfirm - URL: ${jsConfirmRequest.url}');
                                    return JsConfirmResponse(
                                      handledByClient: false,
                                    );
                                  },
                                  onJsPrompt:
                                      (controller, jsPromptRequest) async {
                                    // Handle JavaScript prompts
                                    LogUtil.printLog(
                                        'onJsPrompt triggered - Message: ${jsPromptRequest.message}');
                                    LogUtil.printLog(
                                        'onJsPrompt - URL: ${jsPromptRequest.url}');
                                    LogUtil.printLog(
                                        'onJsPrompt - DefaultValue: ${jsPromptRequest.defaultValue}');
                                    return JsPromptResponse(
                                      handledByClient: false,
                                    );
                                  },
                                  onLoadStart:
                                      (InAppWebViewController controller,
                                          Uri? uri) {
                                    final url = uri.toString();
                                    if (fromBackButton &&
                                        url.contains("/term/redirect")) {
                                      _webViewController.goBack();

                                      setState(() {
                                        showBackButton = false;
                                        showAppBar = false;
                                        fromBackButton = false;
                                        stopNavigation = true;
                                      });
                                    }
                                  },
                                  onLoadStop:
                                      (InAppWebViewController controller,
                                          Uri? uri) async {
                                    LogUtil.printLog('onLoadStop');
                                  },
                                  onLoadResource: (controller, resource) async {
                                    // Handle resource loading - this can help with file upload resources
                                    LogUtil.printLog(
                                        'Loading resource: ${resource.url}');

                                    // Check for specific URL pattern and request permissions if needed
                                    // Pattern: https://api.wealthy.in/fdapi/fd_[dynamic_id]/user-details/
                                    String resourceUrl =
                                        resource.url.toString();
                                    if (resourceUrl.contains(
                                            'https://api.wealthy.in/fdapi/') &&
                                        resourceUrl
                                            .contains('/user-details/')) {
                                      LogUtil.printLog(
                                          'Detected user-details API call - checking file upload permissions');

                                      bool permissionsReady =
                                          await _areFileUploadPermissionsReady();
                                      if (!permissionsReady) {
                                        LogUtil.printLog(
                                            'File upload permissions not ready - requesting permissions');
                                        await _requestFileUploadPermissions();
                                      } else {
                                        LogUtil.printLog(
                                            'File upload permissions already ready');
                                      }
                                    }
                                  },
                                  onConsoleMessage:
                                      (controller, consoleMessage) async {
                                    // Log console messages to help debug file upload issues
                                    LogUtil.printLog(
                                        'Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
                                    if (consoleMessage.message
                                        .toLowerCase()
                                        .contains('file')) {
                                      LogUtil.printLog(
                                          'File-related console message detected: ${consoleMessage.message}');
                                    }
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
                                  // onPrintRequest:
                                  //     (controller, url, printJobController) {},
                                  shouldOverrideUrlLoading:
                                      (InAppWebViewController controller,
                                          NavigationAction action) {
                                    return navigationListener(
                                        controller, action);
                                  },
                                ),
                              ),
                            ],
                          ),
                          // if (widget.showAppBar)
                          CommonUI.buildWebViewProgressiveLoader(
                              loadingPercentage),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
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

        File file = File('$downloadPath/$date.${fileExtension}');
        await file.writeAsBytes(List.from(bytes));
        bool isExists = await file.exists();
        if (isExists) {
          // Pop the loader
          AutoRouter.of(context).popForced();

          CommonUI.showBottomSheet(
            getGlobalContext(),
            child: DownloadedReportBottomSheet(
              onShare: () async {
                try {
                  await shareFiles(file.path);
                } catch (error) {
                  LogUtil.printLog(
                      "Failed to share. Please try after some time");
                }
              },
              onView: () async {
                await openFile(file.path);
              },
            ),
          );
          showToast(text: 'Downloaded');
        } else {
          AutoRouter.of(context).popForced();
          showToast(text: 'Download failed. Please try again');
        }
      } catch (error) {
        LogUtil.printLog(error);
        AutoRouter.of(context).popForced();
        showToast(text: 'Download failed. Please try again');
      }
    } else {
      showToast(text: 'Please grant storage permission');
    }
  }

  void _downloadAsset(String url) async {
    DownloadController downloadController =
        Get.find<DownloadController>(tag: 'insurance');
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
      InAppWebViewController controller, DownloadStartRequest request) async {
    final navigationUrl = request.url.toString();
    LogUtil.printLog('onDownloadStartRequest url: $navigationUrl');
    // Share proposal Url
    if (navigationUrl.startsWith("share:")) {
      String shareUrl = navigationUrl.split("share:")[1];
      shareText(shareUrl);
      LogUtil.printLog('Share link handled');
      return;
    }

    if (navigationUrl.startsWith("blob:")) {
      try {
        // Blob URLs are page-local; fetch + convert to data URL in-page
        final escapedUrl = navigationUrl.replaceAll('"', '\\"');
        final jsFunctionBody = """
          const res = await fetch(\"$escapedUrl\");
          const blob = await res.blob();
          return await new Promise((resolve) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.readAsDataURL(blob);
          });
        """;

        // Prefer callAsyncJavaScript for a structured response; fall back to evaluateJavascript
        String? dataUrl;
        try {
          final callResult = await controller.callAsyncJavaScript(
            functionBody: jsFunctionBody,
          );
          if (callResult?.value is String) {
            dataUrl = callResult?.value as String;
            LogUtil.printLog('Blob fetched via callAsyncJavaScript');
          }
        } catch (callErr) {
          LogUtil.printLog('callAsyncJavaScript failed: $callErr');
        }

        if (dataUrl == null) {
          final evalResult = await controller.evaluateJavascript(
            source: "(async () => {" + jsFunctionBody + "})();",
          );
          if (evalResult is String) {
            dataUrl = evalResult;
            LogUtil.printLog('Blob fetched via evaluateJavascript fallback');
          }
        }

        if (dataUrl != null && dataUrl.startsWith("data:")) {
          _downloadFile(dataUrl);
          LogUtil.printLog('Blob converted to data URL and download started');
        } else {
          LogUtil.printLog('Blob fetch did not return data URL');
        }
      } catch (e) {
        LogUtil.printLog('Blob download failed: $e');
      }
      return;
    }

    if (navigationUrl.startsWith("data:")) {
      _downloadFile(navigationUrl);
      LogUtil.printLog('Data URL download started');
      return;
    }

    if (isDownloadableUrl(navigationUrl)) {
      LogUtil.printLog('Asset download triggered for $navigationUrl');
      _downloadAsset(navigationUrl);
    }
  }

  Future<void> _createHeadlessWebViewForDownload(
      CreateWindowAction createWindowAction) async {
    WebUri? webViewUrl = createWindowAction.request.url;

    // Create a proper headless webview
    late HeadlessInAppWebView headlessWebView;

    headlessWebView = HeadlessInAppWebView(
      windowId: createWindowAction.windowId,
      initialUrlRequest:
          webViewUrl != null ? URLRequest(url: webViewUrl) : null,
      initialSettings: InAppWebViewSettings(
        useOnDownloadStart: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        supportMultipleWindows: false,
      ),
      onDownloadStartRequest: (controller, request) {
        LogUtil.printLog('Download triggered in headless webview');
        // Handle download
        onDownloadStartRequest(controller, request);
        // Dispose the headless webview
        headlessWebView.dispose();
      },
      onLoadStop: (controller, url) {
        LogUtil.printLog('Headless webview loaded: $url');
      },
      onLoadError: (controller, url, code, message) {
        LogUtil.printLog('Headless webview error: $message');
        // Dispose on error
        headlessWebView.dispose();
      },
    );

    // Run the headless webview
    await headlessWebView.run();

    // Auto-dispose after 30 seconds as a safety measure
    Future.delayed(Duration(seconds: 30), () {
      try {
        headlessWebView.dispose();
      } catch (e) {
        LogUtil.printLog('Error disposing headless webview: $e');
      }
    });
  }

  Future<NavigationActionPolicy> navigationListener(
      InAppWebViewController controller, NavigationAction action) {
    final navigationUrl = action.request.url.toString();
    LogUtil.printLog('navigationUrl==>$navigationUrl');
    if (stopNavigation &&
        !navigationUrl.contains("insurance.wealthyinsurance") &&
        !navigationUrl.contains("applinks.buildwealth")) {
      setState(() {
        stopNavigation = false;
      });
    }

    // Share proposal Url
    if (navigationUrl.startsWith("share:")) {
      String shareUrl = navigationUrl.split("share:")[1];
      shareText(shareUrl);
      return Future.value(NavigationActionPolicy.CANCEL);
    }

    if (navigationUrl.startsWith('https://wa') ||
        navigationUrl.startsWith('whatsapp://') ||
        navigationUrl.startsWith('mailto:') ||
        navigationUrl.startsWith('tel:')) {
      launch(navigationUrl);
      return Future.value(NavigationActionPolicy.CANCEL);
    }

    if (navigationUrl.startsWith("data:")) {
      _downloadFile(navigationUrl);

      return Future.value(NavigationActionPolicy.CANCEL);
    }

    if (isDownloadableUrl(navigationUrl)) {
      _downloadAsset(navigationUrl);

      return Future.value(NavigationActionPolicy.CANCEL);
    }

    if (!navigationUrl.contains("insurance.wealthyinsurance") &&
        !navigationUrl.contains("applinks.buildwealth")) {
      bool isOldInsuranceUrl = navigationUrl.contains("www.wealthyinsurance");
      bool isFromFD =
          isRouteParentOfCurrent(context, FixedDepositListRoute.name);

      if ((!isOldInsuranceUrl && !isFromFD) &&
          (!showAppBar || !showBackButton)) {
        setState(() {
          fromBackButton = false;
          showAppBar = true;
          showBackButton = true;
        });
      } else {
        setState(() {
          fromBackButton = false;
        });
      }

      return Future.value(NavigationActionPolicy.ALLOW);
    }

    if (widget.onNavigationRequest != null) {
      if (navigationUrl.contains("insurance.wealthyinsurance") && showAppBar) {
        setState(() {
          showAppBar = false;
          showBackButton = false;
        });
      }
      return widget.onNavigationRequest!(controller, action);
    }

    LogUtil.printLog('allowing navigation to $navigationUrl');
    return Future.value(NavigationActionPolicy.ALLOW);
  }

  /// Request file-related permissions proactively for file upload functionality
  Future<void> _requestFileUploadPermissions() async {
    try {
      LogUtil.printLog('Requesting file upload permissions proactively');

      List<Permission> permissionsToRequest = [
        Permission.camera,
        Permission.photos,
        Permission.storage,
      ];

      // Add Android-specific permissions
      if (Platform.isAndroid) {
        permissionsToRequest.add(Permission.manageExternalStorage);
      }

      // Check current status first
      Map<Permission, PermissionStatus> currentStatuses = {};
      for (Permission permission in permissionsToRequest) {
        currentStatuses[permission] = await permission.status;
        LogUtil.printLog(
            'Current status for $permission: ${currentStatuses[permission]}');
      }

      // Filter out already granted permissions
      List<Permission> permissionsNeedingRequest = permissionsToRequest
          .where((permission) =>
              currentStatuses[permission] != PermissionStatus.granted)
          .toList();

      if (permissionsNeedingRequest.isNotEmpty) {
        LogUtil.printLog('Requesting permissions: $permissionsNeedingRequest');

        // Request permissions
        Map<Permission, PermissionStatus> statuses =
            await permissionsNeedingRequest.request();

        // Log results
        statuses.forEach((permission, status) {
          LogUtil.printLog('Permission request result - $permission: $status');

          if (status == PermissionStatus.denied) {
            LogUtil.printLog('Warning: $permission was denied');
          } else if (status == PermissionStatus.permanentlyDenied) {
            LogUtil.printLog('Warning: $permission was permanently denied');
          }
        });

        // Check if critical permissions for file upload are granted
        bool hasCameraOrPhotos =
            (await Permission.camera.status == PermissionStatus.granted) ||
                (await Permission.photos.status == PermissionStatus.granted);

        bool hasStorageAccess =
            (await Permission.storage.status == PermissionStatus.granted);

        if (hasCameraOrPhotos && hasStorageAccess) {
          LogUtil.printLog('✅ File upload permissions are ready');
        } else {
          LogUtil.printLog('⚠️ Some file upload permissions are missing');

          // Show user-friendly message if permissions are critical
          if (!hasStorageAccess) {
            LogUtil.printLog('Storage permission is required for file uploads');
          }
        }
      } else {
        LogUtil.printLog('✅ All file upload permissions already granted');
      }
    } catch (error) {
      LogUtil.printLog('Error requesting file upload permissions: $error');
    }
  }

  /// Check if file upload permissions are ready
  Future<bool> _areFileUploadPermissionsReady() async {
    try {
      bool hasCameraOrPhotos =
          (await Permission.camera.status == PermissionStatus.granted) ||
              (await Permission.photos.status == PermissionStatus.granted);

      bool hasStorageAccess =
          (await Permission.storage.status == PermissionStatus.granted);

      return hasCameraOrPhotos && hasStorageAccess;
    } catch (error) {
      LogUtil.printLog('Error checking file upload permissions: $error');
      return false;
    }
  }
}
