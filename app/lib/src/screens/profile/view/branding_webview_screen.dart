import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/unauthorised_access_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class BrandingWebViewScreen extends StatefulWidget {
  @override
  _BrandingWebViewScreenState createState() => _BrandingWebViewScreenState();
}

class _BrandingWebViewScreenState extends State<BrandingWebViewScreen> {
  late InAppWebViewController _webViewController;
  int loadingPercentage = 0;
  String? _brandingUrl;

  final commonController = Get.find<CommonController>();

  void _handleLoad(int value) {
    if (mounted) {
      setState(() {
        loadingPercentage = value;
      });
    }
  }

  Future<String> getBrandingUrl() async {
    final agentId = (await getAgentId()).toString();
    final apiKey = (await getApiKey()).toString();
    final agentExternalId = (await getAgentExternalId()).toString();

    final baseUrl = F.appFlavor == Flavor.DEV
        ? 'https://app.buildwealthdev.in'
        : 'https://app.buildwealth.in';

    final appVersion = (await initPackageInfo()).version;

    final brandingUrl = '$baseUrl/profile/branding';

    await _setBrandingCookies(
      baseUrl,
      apiKey,
      agentId,
      agentExternalId,
      appVersion,
    );
    return brandingUrl;
  }

  Future<void> _setBrandingCookies(
    String baseUrl,
    String apiKey,
    String agentId,
    String agentExternalId,
    String appVersion,
  ) async {
    final cookieManager = CookieManager.instance();
    final expiresDate =
        DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch;

    final agentInfoCookie = jsonEncode({
      'id': agentId,
      'externalId': agentExternalId,
      // "phoneNumber": "(+91)2233233345",
      // "email": "testagent@gmail.com",
      // "agentType": "VARIABLE",
      // "name": "NIRMALA SRIVASTAVA",
      // "timeout": 43200,
      // "code": "WAGENT",
      // "hideRevenue": false,
      // "rmEmail": "mock_lqt3_28205@wmock.temp"
    });

    // Set all cookies in parallel for faster initialization
    await Future.wait(
      [
        cookieManager.setCookie(
          url: WebUri(baseUrl),
          name: 'wlag_xxid_acc',
          value: apiKey,
          expiresDate: expiresDate,
          isSecure: true,
        ),
        cookieManager.setCookie(
          url: WebUri(baseUrl),
          name: 'agentInfo',
          value: agentInfoCookie,
          expiresDate: expiresDate,
          isSecure: true,
        ),
        cookieManager.setCookie(
          url: WebUri(baseUrl),
          name: 'app_version',
          value: appVersion,
          expiresDate: expiresDate,
          isSecure: true,
        ),
      ],
    );
  }

  Future<void> _clearBrandingCookies() async {
    final baseUrl = F.appFlavor == Flavor.DEV
        ? 'https://app.buildwealthdev.in'
        : 'https://app.buildwealth.in';

    final cookieManager = CookieManager.instance();

    await cookieManager.deleteCookie(
        url: WebUri(baseUrl), name: 'wlag_xxid_acc');
    await cookieManager.deleteCookie(url: WebUri(baseUrl), name: 'agentInfo');
    await cookieManager.deleteCookie(url: WebUri(baseUrl), name: 'app_version');
  }

  Future<void> _initializeBrandingUrl() async {
    final url = await getBrandingUrl();
    if (mounted) {
      setState(() {
        _brandingUrl = url;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeBrandingUrl();
    _checkAndRequestPermissionsAtStart();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  /// Check and request photo/camera permissions when the screen starts
  Future<void> _checkAndRequestPermissionsAtStart() async {
    try {
      LogUtil.printLog('Checking photo/camera permissions at startup');

      bool permissionsReady = await _areFileUploadPermissionsReady();

      if (!permissionsReady) {
        LogUtil.printLog(
            'Photo/camera permissions not ready - requesting at startup');
        await _requestFileUploadPermissions();
      } else {
        LogUtil.printLog('Photo/camera permissions already granted at startup');
      }
    } catch (error) {
      LogUtil.printLog('Error checking permissions at startup: $error');
    }
  }

  @override
  void dispose() {
    _clearBrandingCookies();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!commonController.brandingSectionFlag.value) {
        return UnauthorisedAccessScreen(title: 'Partner Branding');
      }

      return _buildBrandingWebView(context);
    });
  }

  Widget _buildBrandingWebView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: ColorConstants.black,
                    size: 20,
                  ),
                  onPressed: () async {
                    try {
                      final canGoBack = await _webViewController.canGoBack();

                      if (canGoBack) {
                        _webViewController.goBack();
                      } else {
                        AutoRouter.of(context).popForced();
                      }
                    } catch (error) {
                      LogUtil.printLog(error);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ColorConstants.black,
                    size: 24,
                  ),
                  onPressed: () async {
                    AutoRouter.of(context).popForced();
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: _brandingUrl == null
                ? Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: loadingPercentage == 100 ? 0 : 1,
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri.uri(Uri.parse(_brandingUrl!)),
                        ),
                        onPermissionRequest: (controller, request) async {
                          bool permissionsReady =
                              await _areFileUploadPermissionsReady();
                          if (!permissionsReady) {
                            LogUtil.printLog(
                                'Photo/camera permissions not ready - requesting permissions');
                            await _requestFileUploadPermissions();
                          } else {
                            LogUtil.printLog(
                                'Photo/camera permissions already ready');
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
                          mixedContentMode:
                              MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                          // Try disabling hybrid composition if file upload doesn't work
                          // useHybridComposition: false,
                          // Force user agent that supports file uploads
                          // userAgent:
                          //     "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.193 Mobile Safari/537.36",
                        ),
                        onWebViewCreated: (InAppWebViewController controller) {
                          _webViewController = controller;
                        },
                        onLoadStart:
                            (InAppWebViewController controller, Uri? uri) {
                          LogUtil.printLog('onLoadStart');
                        },
                        onLoadStop: (InAppWebViewController controller,
                            Uri? uri) async {
                          LogUtil.printLog('onLoadStop');
                        },
                        onProgressChanged:
                            (InAppWebViewController controller, int progress) {
                          _handleLoad(progress);
                        },
                        onCreateWindow: (controller, createWindowAction) async {
                          // This is essential for file upload dialogs to work
                          LogUtil.printLog(
                              'onCreateWindow triggered - URL: ${createWindowAction.request.url}');
                          LogUtil.printLog(
                              'onCreateWindow - WindowId: ${createWindowAction.windowId}');
                          LogUtil.printLog(
                              'onCreateWindow - isDialog: ${createWindowAction.isDialog}');

                          // For file uploads, we need to allow window creation
                          // but also handle it properly
                          if (createWindowAction.isDialog == true) {
                            LogUtil.printLog(
                                'Dialog window detected - allowing creation for file upload');
                            return true;
                          }

                          final uri = createWindowAction.request.url;
                          final didShare = openShareDialog(uri);
                          if (didShare) {
                            LogUtil.printLog('Share action handled for: $uri');
                          }

                          return true;
                        },
                        onJsAlert: (controller, jsAlertRequest) async {
                          // Handle JavaScript alerts
                          LogUtil.printLog(
                              'onJsAlert triggered - Message: ${jsAlertRequest.message}');
                          LogUtil.printLog(
                              'onJsAlert - URL: ${jsAlertRequest.url}');
                          return JsAlertResponse(
                            handledByClient: false,
                          );
                        },
                        onJsConfirm: (controller, jsConfirmRequest) async {
                          // Handle JavaScript confirms
                          LogUtil.printLog(
                              'onJsConfirm triggered - Message: ${jsConfirmRequest.message}');
                          LogUtil.printLog(
                              'onJsConfirm - URL: ${jsConfirmRequest.url}');
                          return JsConfirmResponse(
                            handledByClient: false,
                          );
                        },
                        onJsPrompt: (controller, jsPromptRequest) async {
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
                        onLoadResource: (controller, resource) async {
                          // Handle resource loading - this can help with file upload resources
                          LogUtil.printLog('Loading resource: ${resource.url}');
                        },
                        onConsoleMessage: (controller, consoleMessage) async {
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
                        onDownloadStartRequest:
                            (InAppWebViewController controller,
                                DownloadStartRequest request) {},
                        shouldOverrideUrlLoading:
                            (InAppWebViewController controller,
                                NavigationAction action) {
                          final uri = action.request.url;

                          LogUtil.printLog('shouldOverrideUrlLoading: $uri');

                          final didShare = openShareDialog(uri);
                          if (didShare) {
                            LogUtil.printLog('Share action handled for: $uri');
                            return Future.value(NavigationActionPolicy.CANCEL);
                          }

                          return Future.value(NavigationActionPolicy.ALLOW);
                        },
                      ),
                      CommonUI.buildWebViewProgressiveLoader(loadingPercentage),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool openShareDialog(WebUri? uri) {
    try {
      if (uri != null &&
          uri.host.contains('whatsapp') &&
          uri.path.contains('send')) {
        final text = uri.queryParameters['text'];
        if (text.isNotNullOrEmpty) {
          shareText(text!);
        }

        return true; // Indicate that we handled the share action
      }
    } catch (e) {}
    return false; // Indicate that we did not handle the share action
  }

  /// Request photo and camera permissions for image upload functionality
  Future<void> _requestFileUploadPermissions() async {
    try {
      LogUtil.printLog('Requesting photo/camera permissions for image uploads');

      List<Permission> permissionsToRequest = [
        Permission.camera,
        Permission.photos,
      ];

      // Remove Android-specific storage permissions since we only need photos/camera

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

        // Check if critical permissions for photo/camera access are granted
        bool hasCameraOrPhotos =
            (await Permission.camera.status == PermissionStatus.granted) ||
                (await Permission.photos.status == PermissionStatus.granted);

        if (hasCameraOrPhotos) {
          LogUtil.printLog('✅ Photo/camera permissions are ready');
        } else {
          LogUtil.printLog('⚠️ Photo/camera permissions are missing');
          LogUtil.printLog(
              'Camera or photos permission is required for photo uploads');
        }
      } else {
        LogUtil.printLog('✅ All photo/camera permissions already granted');
      }
    } catch (error) {
      LogUtil.printLog('Error requesting file upload permissions: $error');
    }
  }

  /// Check if photo/camera permissions are ready for image uploads
  Future<bool> _areFileUploadPermissionsReady() async {
    try {
      bool hasCameraOrPhotos =
          (await Permission.camera.status == PermissionStatus.granted) ||
              (await Permission.photos.status == PermissionStatus.granted);

      return hasCameraOrPhotos;
    } catch (error) {
      LogUtil.printLog('Error checking photo/camera permissions: $error');
      return false;
    }
  }
}
