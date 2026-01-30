import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper function to handle file downloads (PDFs, documents, etc.)
Future<void> handleFileDownload(
  BuildContext context,
  DownloadStartRequest downloadStartRequest,
) async {
  final url = downloadStartRequest.url.toString();
  final suggestedFilename =
      downloadStartRequest.suggestedFilename ?? 'download';
  final mimeType = downloadStartRequest.mimeType ?? '';

  LogUtil.printLog("Download requested: $url");
  LogUtil.printLog("Suggested filename: $suggestedFilename");
  LogUtil.printLog("MIME type: $mimeType");

  // Check if it's a PDF file (using MIME type, filename, or URL path)
  final urlPath = Uri.parse(url).path.toLowerCase();
  final isPdf = mimeType.toLowerCase().contains('pdf') ||
      suggestedFilename.toLowerCase().endsWith('.pdf') ||
      urlPath.endsWith('.pdf');

  LogUtil.printLog("Is PDF file: $isPdf");
  LogUtil.printLog("urlPath: $urlPath");

  // Skip non-PDF files
  if (!isPdf) {
    LogUtil.printLog("Non-PDF file detected, skipping: $suggestedFilename");
    return;
  }

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(ColorConstants.primaryAppColor),
        ),
      ),
    );

    // Download the file using HTTP client
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();

    // Read bytes for PDF preview or saving
    final bytes = await consolidateHttpClientResponseBytes(response);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show inline viewer with download option
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => _PdfViewerDialog(
          pdfBytes: bytes,
          filename: suggestedFilename,
        ),
      );
    }
  } catch (e) {
    LogUtil.printLog("Error downloading file: $e");

    // Close loading dialog if open
    if (context.mounted) {
      Navigator.of(context).pop();
      showToast(text: 'An error occurred while downloading the file');
    }
  }
}

/// Helper function to save file to storage
Future<void> _saveFileToStorage(
    BuildContext context, Uint8List bytes, String filename) async {
  try {
    // Request storage permission
    final status = await getStorePermissionStatus();

    if (status.isGranted) {
      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        // Add timestamp to filename
        final date = DateFormat('ddMMyyyyHHmm').format(DateTime.now());
        final dateTimeFileName =
            filename.toString().replaceAll('.pdf', '') + date + '.pdf';

        final filePath = '${directory.path}/$dateTimeFileName';

        // Write bytes to file
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        LogUtil.printLog("File downloaded to: $filePath");

        // Show success message with bottom sheet
        if (context.mounted) {
          CommonUI.showBottomSheet(
            getGlobalContext(),
            child: DownloadedReportBottomSheet(
              reportName: filename,
              onView: () async {
                final data = await OpenFile.open(
                  filePath,
                  type: 'application/pdf',
                );
                LogUtil.printLog(data.toString());
              },
              onShare: () async {
                try {
                  await shareFiles(filePath);
                } catch (error) {
                  LogUtil.printLog(
                      "Failed to share. Please try after some time");
                }
              },
            ),
          );
        }
      } else {
        if (context.mounted) {
          showToast(text: 'Could not access storage directory');
        }
      }
    } else {
      if (context.mounted) {
        showToast(text: 'Storage permission is required to download files');
      }
    }
  } catch (e) {
    LogUtil.printLog("Error saving file: $e");
    if (context.mounted) {
      showToast(text: 'Failed to save file');
    }
  }
}

@RoutePage()
class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final CookieManager cookieManager = CookieManager.instance();
  bool isLoading = true;
  double progress = 0;
  bool cookiesReady = false;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final baseUrl = F.appFlavor == Flavor.PROD
        ? 'https://app.buildwealth.in'
        : 'https://app.buildwealthdev.in';

    // Set the auth cookies before loading the webview
    await _setProfileCookies(baseUrl);

    // Mark cookies as ready and rebuild to show WebView
    setState(() {
      cookiesReady = true;
    });
  }

  Future<void> _setProfileCookies(String baseUrl) async {
    try {
      final agentId = (await getAgentId()).toString();
      final apiKey = (await getApiKey()).toString();
      final agentExternalId = (await getAgentExternalId()).toString();
      final appVersion = (await initPackageInfo()).version;
      final source = Platform.isAndroid
          ? 'partner_android_v${appVersion}'
          : 'partner_ios_v${appVersion}';

      final expiresDate =
          DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch;

      // Parse URL once and reuse
      final webUri = WebUri(baseUrl);
      final domain = Uri.parse(baseUrl).host;
      const path = '/';

      final agent = Get.find<HomeController>().advisorOverviewModel?.agent;

      final agentInfoCookie = jsonEncode({
        'id': agentId,
        'externalId': agentExternalId,
        "phoneNumber": agent?.phoneNumber ?? '',
        "email": agent?.email ?? '',
        "agentType": agent?.agentType ?? '',
        "name": agent?.name ?? '',
      });

      // Set all cookies in parallel for faster initialization
      await Future.wait(
        [
          cookieManager.setCookie(
            url: webUri,
            name: 'wlag_xxid_acc',
            value: apiKey,
            expiresDate: expiresDate,
            isSecure: true,
            domain: domain,
            path: path,
          ),
          cookieManager.setCookie(
            url: webUri,
            name: 'agentInfo',
            value: agentInfoCookie,
            expiresDate: expiresDate,
            isSecure: true,
            domain: domain,
            path: path,
          ),
          cookieManager.setCookie(
            url: webUri,
            name: 'app_version',
            value: appVersion,
            expiresDate: expiresDate,
            isSecure: true,
            domain: domain,
            path: path,
          ),
          cookieManager.setCookie(
            url: webUri,
            name: 'source',
            value: source,
            expiresDate: expiresDate,
            isSecure: true,
            domain: domain,
            path: path,
          ),
        ],
      );
    } catch (e) {
      LogUtil.printLog("Error setting cookies: $e");
    }
  }

  Future<void> _clearProfileCookies() async {
    final baseUrl = F.appFlavor == Flavor.PROD
        ? 'https://app.buildwealth.in'
        : 'https://app.buildwealthdev.in';

    // Parse URL once and reuse
    final webUri = WebUri(baseUrl);
    final domain = Uri.parse(baseUrl).host;
    const path = '/';

    await cookieManager.deleteCookie(
        url: webUri, name: 'wlag_xxid_acc', domain: domain, path: path);
    await cookieManager.deleteCookie(
        url: webUri, name: 'agentInfo', domain: domain, path: path);
    await cookieManager.deleteCookie(
        url: webUri, name: 'app_version', domain: domain, path: path);
    await cookieManager.deleteCookie(
        url: webUri, name: 'source', domain: domain, path: path);
    LogUtil.printLog("Profile cookies cleared");
  }

  void _refreshAgentModel() {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    profileController?.getAdvisorOverview();

    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    homeController.getAdvisorOverview();
  }

  /// Handles back button press: clears history and returns to profile-details or pops screen
  Future<void> _handleBackPress() async {
    if (webViewController != null) {
      final currentUrl = await webViewController!.getUrl();

      final baseUrl = F.appFlavor == Flavor.PROD
          ? 'https://app.buildwealth.in'
          : 'https://app.buildwealthdev.in';
      final profileUpdateUrl = '$baseUrl/profile-details';

      if (currentUrl != null && currentUrl.toString() != profileUpdateUrl) {
        // Clear history and load profile-details page
        LogUtil.printLog("Clearing history and loading profile-details");
        if (Platform.isAndroid) {
          await webViewController!.clearHistory();
        }
        await webViewController!
            .loadUrl(urlRequest: URLRequest(url: WebUri(profileUpdateUrl)));
      } else {
        // Already on profile-details page, pop the screen
        AutoRouter.of(context).pop();
      }
    } else {
      AutoRouter.of(context).pop();
    }
  }

  /// Builds and returns InAppWebView settings configuration
  InAppWebViewSettings _buildWebViewSettings() {
    return InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      allowFileAccessFromFileURLs: true,
      allowUniversalAccessFromFileURLs: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      thirdPartyCookiesEnabled: true,
      supportMultipleWindows: true,
      javaScriptCanOpenWindowsAutomatically: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      useHybridComposition: true,
      hardwareAcceleration: true,
      clearCache: false,
      cacheEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      // Prevent black screen during loading
      transparentBackground: true,
    );
  }

  /// Handles popup window creation: shows a dialog with new WebView
  Future<bool> _handleCreateWindow(InAppWebViewController controller,
      CreateWindowAction createWindowAction) async {
    final requestUrl = createWindowAction.request.url;
    LogUtil.printLog(
        "InAppWebView requested to create a new window: $requestUrl");

    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PopupWebViewDialog(
          windowId: createWindowAction.windowId,
        );
      },
    );
    return true;
  }

  /// Handles window close: no longer needed as popup handles its own closing
  void _handleCloseWindow(InAppWebViewController controller) {
    LogUtil.printLog("WebView window close requested (handled by popup)");
  }

  /// Handles geolocation permission requests
  Future<GeolocationPermissionShowPromptResponse> _handleGeolocationPermission(
      InAppWebViewController controller, String origin) async {
    LogUtil.printLog("Geolocation permission requested for origin: $origin");
    await [Permission.location].request();
    return GeolocationPermissionShowPromptResponse(
      allow: true,
      origin: origin,
    );
  }

  /// Converts HTTP URLs to HTTPS for kyc domains (both dev and prod)
  String _convertHttpToHttps(WebUri url) {
    String urlToLoad = url.toString();
    if (url.scheme == 'http' &&
        (url.host.contains('kyc.wealthydev.in') ||
            url.host.contains('kyc.wealthy.in'))) {
      urlToLoad = urlToLoad.replaceFirst('http://', 'https://');
      LogUtil.printLog("Converting popup HTTP to HTTPS: $urlToLoad");
    }
    return urlToLoad;
  }

  /// Handles URL loading override: converts HTTP to HTTPS for kyc domain
  Future<NavigationActionPolicy> _handleShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final url = navigationAction.request.url;
    LogUtil.printLog("Attempting to load URL: $url");

    // Handle UPI and payment app deep links
    if (url != null) {
      final uri = url.toString();
      if (uri.contains('upi://') ||
          uri.contains('phonepe://') ||
          uri.contains('tez://') ||
          uri.contains('paytmmp://') ||
          uri.contains('bharatpe://')) {
        LogUtil.printLog(
            "Payment deep link detected, launching external app: $uri");
        launchUrl(url.uriValue);
        return NavigationActionPolicy.CANCEL;
      }
    }

    // Check if URL is dashboard and pop the screen
    if (url != null) {
      final baseUrl = F.appFlavor == Flavor.PROD
          ? 'https://app.buildwealth.in'
          : 'https://app.buildwealthdev.in';
      final dashboardUrl = '$baseUrl/dashboard';

      if (url.toString() == dashboardUrl) {
        LogUtil.printLog("Dashboard URL detected, popping ProfileUpdateScreen");
        AutoRouter.of(context).pop();
        return NavigationActionPolicy.CANCEL;
      }
    }

    // Use the existing method to convert HTTP to HTTPS for kyc domains
    if (url != null && url.scheme == 'http') {
      final httpsUrl = _convertHttpToHttps(url);

      // Only proceed if conversion happened
      if (httpsUrl != url.toString()) {
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(httpsUrl)));
        return NavigationActionPolicy.CANCEL;
      }
    }

    return NavigationActionPolicy.ALLOW;
  }

  /// Handles page load start: sets loading state to true
  void _handleLoadStart(InAppWebViewController controller, WebUri? url) {
    setState(() {
      isLoading = true;
    });
    LogUtil.printLog("InAppWebView started loading: $url");
  }

  /// Handles page load completion: sets loading state to false
  void _handleLoadStop(InAppWebViewController controller, WebUri? url) {
    setState(() {
      isLoading = false;
    });
    LogUtil.printLog("InAppWebView finished loading: $url");
  }

  /// Updates and logs the page loading progress
  void _handleProgressChanged(InAppWebViewController controller, int progress) {
    setState(() {
      this.progress = progress / 100;
    });
    LogUtil.printLog("Loading progress: $progress%");
  }

  /// Logs WebView load errors
  void _handleLoadError(
      InAppWebViewController controller, Uri? url, int code, String message) {
    LogUtil.printLog(
        "InAppWebView load error: Code=$code, Message=$message, URL=$url");
  }

  /// Logs WebView HTTP errors
  void _handleLoadHttpError(InAppWebViewController controller, Uri? url,
      int statusCode, String description) {
    LogUtil.printLog(
        "InAppWebView HTTP error: StatusCode=$statusCode, Description=$description, URL=$url");
  }

  /// Logs WebView console messages for debugging
  void _handleConsoleMessage(
      InAppWebViewController controller, ConsoleMessage consoleMessage) {
    LogUtil.printLog("WebView Console: ${consoleMessage.message}");
  }

  /// Handles file downloads (PDFs, documents, etc.)
  Future<void> _handleDownloadStart(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest) async {
    await handleFileDownload(context, downloadStartRequest);
  }

  /// Builds and returns the linear progress indicator widget
  Widget _buildLoadingIndicator() {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: ColorConstants.white,
      valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.primaryAppColor),
    );
  }

  /// Builds and returns the main InAppWebView widget with all callbacks
  Widget _buildWebView(BuildContext context,
      {int? windowId, WebUri? initialUrl}) {
    return InAppWebView(
      windowId: windowId,
      initialUrlRequest: windowId == null && initialUrl != null
          ? URLRequest(url: initialUrl)
          : null,
      initialSettings: _buildWebViewSettings(),
      onWebViewCreated: (controller) {
        if (windowId == null) {
          webViewController = controller;
          LogUtil.printLog("InAppWebView created");

          // Add JavaScript handler for partner app communication
          controller.addJavaScriptHandler(
            handlerName: 'partner_app_communication_handler',
            callback: (args) {
              LogUtil.printLog(
                  '[Main WebView] partner_app_communication_handler received: ${args.toString()}');
              final data = args.firstOrNull?.toString() ?? '';
              switch (data.toUpperCase()) {
                case 'CLOSE':
                  _handleBackPress();
                  break;

                default:
                  LogUtil.printLog('[Main WebView] Unhandled data: $data');
              }
            },
          );
        } else {
          LogUtil.printLog(
              "Popup InAppWebView created with windowId: $windowId");
        }
      },
      onCreateWindow: _handleCreateWindow,
      onCloseWindow: _handleCloseWindow,
      onLoadStart: _handleLoadStart,
      onLoadStop: _handleLoadStop,
      onProgressChanged: _handleProgressChanged,
      onLoadError: _handleLoadError,
      onLoadHttpError: _handleLoadHttpError,
      onConsoleMessage: _handleConsoleMessage,
      shouldOverrideUrlLoading: _handleShouldOverrideUrlLoading,
      onGeolocationPermissionsShowPrompt: _handleGeolocationPermission,
      onDownloadStartRequest: _handleDownloadStart,
    );
  }

  @override
  void dispose() {
    _clearProfileCookies();

    // Schedule refresh after the widget tree is unlocked
    Future.microtask(() => _refreshAgentModel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = F.appFlavor == Flavor.PROD
        ? 'https://app.buildwealth.in'
        : 'https://app.buildwealthdev.in';

    final profileUpdateUrl = '$baseUrl/profile-details';
    final profileUpdateUri = WebUri(profileUpdateUrl);

    LogUtil.printLog('profileUpdateUri==>${profileUpdateUri.toString()}');

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,

        // appBar: CustomAppBar(
        //   titleText: 'Update Profile',
        //   onBackPress: _handleBackPress,
        // ),
        body: Padding(
          padding: EdgeInsets.only(top: getSafeTopPadding(30, context)),
          child: !cookiesReady
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryAppColor),
                  ),
                )
              : Stack(
                  children: [
                    _buildWebView(context, initialUrl: profileUpdateUri),
                    if (isLoading) _buildLoadingIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Stateful widget for the popup WebView dialog with its own loading state
class _PopupWebViewDialog extends StatefulWidget {
  final int windowId;

  const _PopupWebViewDialog({
    required this.windowId,
  });

  @override
  State<_PopupWebViewDialog> createState() => _PopupWebViewDialogState();
}

class _PopupWebViewDialogState extends State<_PopupWebViewDialog> {
  bool isLoading = true;
  double progress = 0;

  /// Builds and returns the linear progress indicator widget
  Widget _buildLoadingIndicator() {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: ColorConstants.white,
      valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.primaryAppColor),
    );
  }

  /// Builds WebView settings for the popup
  InAppWebViewSettings _buildWebViewSettings() {
    return InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      allowFileAccessFromFileURLs: true,
      allowUniversalAccessFromFileURLs: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      thirdPartyCookiesEnabled: true,
      supportMultipleWindows: true,
      javaScriptCanOpenWindowsAutomatically: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      useHybridComposition: true,
      hardwareAcceleration: true,
      clearCache: false,
      cacheEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
    );
  }

  /// Handles page load start
  void _handleLoadStart(InAppWebViewController controller, WebUri? url) {
    setState(() {
      isLoading = true;
    });
    LogUtil.printLog("Popup WebView started loading: $url");
  }

  /// Handles page load completion
  void _handleLoadStop(InAppWebViewController controller, WebUri? url) {
    setState(() {
      isLoading = false;
    });
    LogUtil.printLog("Popup WebView finished loading: $url");
  }

  /// Updates progress
  void _handleProgressChanged(InAppWebViewController controller, int progress) {
    setState(() {
      this.progress = progress / 100;
    });
    LogUtil.printLog("Popup loading progress: $progress%");
  }

  /// Handles geolocation permission requests
  Future<GeolocationPermissionShowPromptResponse> _handleGeolocationPermission(
      InAppWebViewController controller, String origin) async {
    LogUtil.printLog(
        "Popup geolocation permission requested for origin: $origin");
    await [Permission.location].request();
    return GeolocationPermissionShowPromptResponse(
      allow: true,
      origin: origin,
    );
  }

  /// Converts HTTP URLs to HTTPS for kyc domains
  String _convertHttpToHttps(WebUri url) {
    String urlToLoad = url.toString();
    if (url.scheme == 'http' &&
        (url.host.contains('kyc.wealthydev.in') ||
            url.host.contains('kyc.wealthy.in'))) {
      urlToLoad = urlToLoad.replaceFirst('http://', 'https://');
      LogUtil.printLog("Converting popup HTTP to HTTPS: $urlToLoad");
    }
    return urlToLoad;
  }

  /// Handles URL loading override
  Future<NavigationActionPolicy> _handleShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final url = navigationAction.request.url;
    LogUtil.printLog("Popup attempting to load URL: $url");

    // Handle UPI and payment app deep links
    if (url != null) {
      final uri = url.toString();
      if (uri.contains('upi://') ||
          uri.contains('phonepe://') ||
          uri.contains('tez://') ||
          uri.contains('paytmmp://') ||
          uri.contains('bharatpe://')) {
        LogUtil.printLog(
            "Payment deep link detected in popup, launching external app: $uri");
        launchUrl(url.uriValue);
        return NavigationActionPolicy.CANCEL;
      }
    }

    // Convert HTTP to HTTPS for kyc domains
    if (url != null && url.scheme == 'http') {
      final httpsUrl = _convertHttpToHttps(url);

      if (httpsUrl != url.toString()) {
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(httpsUrl)));
        return NavigationActionPolicy.CANCEL;
      }
    }

    return NavigationActionPolicy.ALLOW;
  }

  /// Handles window close: closes the popup dialog when window.close() is called
  void _handleCloseWindow(InAppWebViewController controller) {
    LogUtil.printLog("Popup WebView window close requested");
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handles file downloads in popup (PDFs, documents, etc.)
  Future<void> _handleDownloadStart(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest) async {
    await handleFileDownload(context, downloadStartRequest);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: Padding(
          padding: EdgeInsets.only(top: getSafeTopPadding(30, context)),
          child: Stack(
            children: [
              InAppWebView(
                windowId: widget.windowId,
                initialSettings: _buildWebViewSettings(),
                onWebViewCreated: (controller) {
                  LogUtil.printLog(
                      "Popup InAppWebView created with windowId: ${widget.windowId}");

                  // Add JavaScript handler for partner app communication
                  controller.addJavaScriptHandler(
                    handlerName: 'partner_app_communication_handler',
                    callback: (args) {
                      LogUtil.printLog(
                          '[Popup WebView] partner_app_communication_handler received: ${args.toString()}');
                      final data = args.firstOrNull?.toString() ?? '';
                      switch (data.toUpperCase()) {
                        case 'CLOSE':
                          _handleCloseWindow(controller);
                          break;

                        default:
                          LogUtil.printLog(
                              '[Popup WebView] Unhandled data: $data');
                      }
                    },
                  );
                },
                onCloseWindow: _handleCloseWindow,
                onLoadStart: _handleLoadStart,
                onLoadStop: _handleLoadStop,
                onProgressChanged: _handleProgressChanged,
                onLoadError: (controller, url, code, message) {
                  LogUtil.printLog(
                      "Popup WebView load error: Code=$code, Message=$message, URL=$url");
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  LogUtil.printLog(
                      "Popup WebView HTTP error: StatusCode=$statusCode, Description=$description, URL=$url");
                },
                onConsoleMessage: (controller, consoleMessage) {
                  LogUtil.printLog(
                      "Popup WebView Console: ${consoleMessage.message}");
                },
                shouldOverrideUrlLoading: _handleShouldOverrideUrlLoading,
                onGeolocationPermissionsShowPrompt:
                    _handleGeolocationPermission,
                onDownloadStartRequest: _handleDownloadStart,
              ),
              if (isLoading) _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// PDF Viewer Dialog Widget for inline PDF viewing with download option
class _PdfViewerDialog extends StatefulWidget {
  final Uint8List pdfBytes;
  final String filename;

  const _PdfViewerDialog({
    required this.pdfBytes,
    required this.filename,
  });

  @override
  State<_PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<_PdfViewerDialog> {
  int currentPage = 0;
  int totalPages = 0;
  bool isDownloading = false;

  Future<void> _downloadPdf() async {
    setState(() {
      isDownloading = true;
    });

    try {
      await _saveFileToStorage(context, widget.pdfBytes, widget.filename);
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header with title and close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConstants.primaryAppColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.filename,
                      style: TextStyle(
                        color: ColorConstants.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ColorConstants.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            // PDF Viewer
            Expanded(
              child: PDFView(
                pdfData: widget.pdfBytes,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                defaultPage: currentPage,
                onViewCreated: (PDFViewController controller) async {
                  final pages = await controller.getPageCount() ?? 0;
                  setState(() {
                    totalPages = pages;
                  });
                },
                onPageChanged: (int? page, int? total) {
                  if (page != null) {
                    setState(() {
                      currentPage = page;
                      if (total != null && totalPages == 0) {
                        totalPages = total;
                      }
                    });
                  }
                },
              ),
            ),
            // Page indicator and download button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConstants.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  if (totalPages > 0)
                    Text(
                      'Page ${currentPage + 1} of $totalPages',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorConstants.tertiaryBlack,
                      ),
                    )
                  else
                    SizedBox(),
                  // Download button
                  ElevatedButton.icon(
                    onPressed: isDownloading ? null : _downloadPdf,
                    icon: isDownloading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorConstants.white),
                            ),
                          )
                        : Icon(Icons.download, size: 20),
                    label: Text(
                      isDownloading ? 'Downloading...' : 'Download',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryAppColor,
                      foregroundColor: ColorConstants.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
