import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/freshchat/freshchat_service.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/common/network_offline_controller.dart';
import 'package:app/src/screens/commons/splash/view/splash_screen_animation.dart';
import 'package:app/src/utils/auth_util.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/lockscreen_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart' as fc;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Global background message handler for Firebase push notifications
/// This function is called when the app receives a notification while terminated/killed
/// The @pragma annotation ensures this function is available during tree-shaking
@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage? message) async {
  LogUtil.printLog('receive notification ${message?.notification?.title}');

  // Process notification data payload
  if (message?.data != null) {
    // Handle data message - contains custom key-value pairs
    final dynamic data = message!.data;
    LogUtil.printLog('data=> $data');
  }

  // Process notification display content
  if (message?.notification != null) {
    // Handle notification message - contains title, body, etc.
    final dynamic notification = message!.notification;
    LogUtil.printLog('notification=> $notification');
  }

  // Handle Freshchat-specific notifications even when app is terminated
  if (message != null) {
    await handleFreshchatNotification(message.data);
  }
}

/// Handles Freshchat-specific push notifications
/// Checks if the notification is from Freshchat service and processes it accordingly
Future<void> handleFreshchatNotification(Map<String, dynamic> message) async {
  // Verify if this notification belongs to Freshchat
  if (await fc.Freshchat.isFreshchatNotification(message)) {
    LogUtil.printLog("is Freshchat notification");

    // Let Freshchat SDK handle its own notifications
    fc.Freshchat.handlePushNotification(message);
  }
}

@RoutePage()
class SplashScreen extends StatefulWidget {
  final bool? showLogoutMessage;

  // When user logs out, splash screen again loads
  // That time initial app start will be false
  final bool isInitialAppStart;

  // Lock screen will be disabled if the below state is true
  final bool? isHalfAgentFlow;

  SplashScreen({
    this.showLogoutMessage = false,
    this.isInitialAppStart = true,
    this.isHalfAgentFlow = false,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  late AuthenticationBloc authenticationBloc;
  bool isAppLocked = false;
  AppLifecycleState? _lastState;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// flag to check if no internet page is active or not
  /// fix for issue : mobile network is ON now user makes wifi ON also, this makes the current page popForced
  /// as onConnectivityChanged stream is triggered

  bool isNetworkOffline = false;

  /// flag to prevent duplicate notification handling when app is launched from notification
  bool hasProcessedInitialNotification = false;

  final NavigationController navigationController =
      Get.put<NavigationController>(NavigationController(), permanent: true);

  final NetworkOfflineController networkOfflineController =
      Get.put<NetworkOfflineController>(
    NetworkOfflineController(),
    permanent: true,
  );

  /// Core notification action handler
  /// Processes notification data and navigates to appropriate screens
  /// @param message: The notification message containing data and metadata
  /// @param viaLaunch: Whether the app was launched via notification (affects navigation behavior)
  takeActionOnNotifications(RemoteMessage message, {bool viaLaunch = false}) {
    LogUtil.printLog('inside take action ${message.data.toString()}');
    LogUtil.printLog(
        'action==> ${message.data['ntype'].toString().toLowerCase()}');

    // Save notification data for later use
    navigationController.savePushNotificationData(message);

    // Determine which screen/widget to navigate to based on notification data
    final widgetToNavigate = navigationController.pushNotificationHandler(
        navigationController.pushNotificationData,
        context: context,
        viaLaunch: viaLaunch);

    if (widgetToNavigate != null) {
      if (viaLaunch) {
        // App was launched by notification - handle navigation differently
        // This ensures proper navigation flow when app starts from notification
        navigationController.pushNotificationHandler(
            navigationController.pushNotificationData,
            context: context,
            viaLaunch: viaLaunch);
      } else {
        // App was already running - use normal navigation
        AutoRouter.of(context).push(widgetToNavigate);
      }
    }
  }

  /// Displays a local notification when app is in foreground
  /// This creates a rich notification with optional big picture style
  /// @param notificationId: Unique identifier for the notification
  /// @param notificationTitle: Title text to display
  /// @param notificationContent: Body text to display
  /// @param payload: JSON string containing notification data for handling taps
  Future<void> _showNotification(
    int notificationId,
    String? notificationTitle,
    String? notificationContent,
    String payload, {
    String channelId = '100',
    String channelTitle = 'wealthy_PN',
    String channelDescription = 'wealthy push notification channel',
    Priority notificationPriority = Priority.high,
    Importance notificationImportance = Importance.max,
  }) async {
    BigPictureStyleInformation? bigPictureStyleInformation;

    try {
      // Parse notification payload to check for big picture image
      Map data = json.decode(payload);
      Map wcontext = json.decode(data["wcontext"]);

      // If notification contains a big picture URL, download and display it
      if (wcontext["pn_big_picture"] != null) {
        String imageUrl = wcontext["pn_big_picture"];
        final http.Response response = await http.get(Uri.parse(imageUrl));

        // Convert downloaded image to format suitable for notification
        bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap.fromBase64String(
                base64Encode(response.bodyBytes)));
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    // Configure Android-specific notification appearance
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
      channelId, channelTitle, channelDescription: channelDescription,
      styleInformation: bigPictureStyleInformation, // Rich media support
      playSound: true,
      // Icon background color for Local push notifications (the ones shown when app is on foreground)
      color: ColorConstants.primaryAppColor,
      importance: notificationImportance,
      priority: notificationPriority,
    );

    // Configure iOS-specific notification appearance
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(presentSound: true);

    // Combine platform-specific settings
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // Display the local notification
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload, // Data passed when notification is tapped
    );
  }

  /// Handles local notification taps
  /// Called when user taps on a local notification (shown when app was in foreground)
  /// Converts the notification payload back to RemoteMessage format for processing
  Future<dynamic> onSelectNotification(
      NotificationResponse notificationResponse) async {
    LogUtil.printLog("INSIDE onSelectNotification: $notificationResponse");

    // Convert local notification payload back to RemoteMessage format
    // and process it the same way as Firebase notifications
    takeActionOnNotifications(
        RemoteMessage(data: json.decode(notificationResponse.payload!)),
        viaLaunch: isAppLocked); // Pass current app lock state
  }

  @override
  void initState() {
    if (widget.showLogoutMessage!) {
      showToast(
        text: "Token expired. Please log in again ",
      );
    }

    networkOfflineController
        .checkNetworkConnectionStream()
        .listen((NetworkState? state) {
      if (state != null) {
        handleNetworkConnection(state);
      }
    });

    authenticationBloc = AuthenticationBlocController().authenticationBloc;

    if (widget.isHalfAgentFlow != true) {
      authenticationBloc.add(CheckForUpdate());
    }

    // ============ NOTIFICATION INITIALIZATION ============

    // Configure Android notification icon and settings
    AndroidInitializationSettings initializationSettingsAndroid =
        new AndroidInitializationSettings(
            '@drawable/wealthy_push_notification'); // Custom notification icon

    // Configure iOS notification settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false, // We'll request permissions separately
      requestBadgePermission: false, // We'll request permissions separately
      requestAlertPermission: false, // We'll request permissions separately
    );

    // Initialize the local notifications plugin
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    InitializationSettings initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Set up notification tap handling
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onSelectNotification, // Handle notification taps
    );

    // ============ FIREBASE MESSAGING SETUP ============

    // Handle notifications when app is in FOREGROUND
    // When app is active and visible, Firebase notifications don't show automatically
    // We manually display them using local notifications for consistent UX
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      LogUtil.printLog("onMessage: $message");

      if (message.notification != null) {
        LogUtil.printLog(message.notification?.title);

        // Show local notification since Firebase won't display it automatically
        // when app is in foreground
        _showNotification(
          100, // Notification ID
          message.notification?.title,
          message.notification?.body,
          json.encode(
              message.data), // Convert data to JSON for local notification
        );
      }

      // Always check for Freshchat notifications
      await handleFreshchatNotification(message.data);
    });

    // Set up background message handler for when app is terminated
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    // Handle notifications when app is in BACKGROUND and user taps notification
    // This listener triggers when app is backgrounded (not terminated) and notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _firebaseMessaging.getInitialMessage().then((_) async {
        // Prevent duplicate processing - see explanation below for why this is needed
        if (!hasProcessedInitialNotification) {
          hasProcessedInitialNotification = true;
          takeActionOnNotifications(message, viaLaunch: isAppLocked);
        }
      });
    });

    // ============ FCM TOKEN AND FRESHCHAT SETUP ============

    // Listen for FCM token refresh (happens when app is restored, token expires, etc.)
    _firebaseMessaging.onTokenRefresh.listen((token) {
      if (Platform.isAndroid) {
        // Update Freshchat with new FCM token for Android
        fc.Freshchat.setPushRegistrationToken(token);
      }
    });

    // Configure Freshchat notification settings
    fc.Freshchat.setNotificationConfig(
      notificationInterceptionEnabled: true, // Allow intercepting notifications
      priority: fc.Priority.PRIORITY_MAX,
      importance: fc.Importance.IMPORTANCE_MAX,
    );

    // Handle Freshchat notification interception
    // This allows custom handling of Freshchat notifications
    final notificationInterceptStream = fc.Freshchat.onNotificationIntercept;
    notificationInterceptStream.listen((dynamic event) {
      LogUtil.printLog("Freshchat Notification Intercept detected");
      // Open Freshchat deeplink when notification is intercepted
      fc.Freshchat.openFreshchatDeeplink(event["url"] as String);
    });

    // ============ HANDLE APP LAUNCH FROM NOTIFICATION ============

    // This section handles the complex case when app is TERMINATED and launched via notification
    // Firebase has two different ways to detect this, which can cause duplicate processing:
    // 1. getInitialMessage() - returns the notification that launched the app
    // 2. onMessageOpenedApp - also triggers for app launch from notification
    // We use hasProcessedInitialNotification flag to prevent duplicate handling

    if (widget.isInitialAppStart) {
      _firebaseMessaging.getInitialMessage().then(
        (RemoteMessage? message) async {
          if (message != null && !hasProcessedInitialNotification) {
            LogUtil.printLog('calling take action');
            hasProcessedInitialNotification = true;
            takeActionOnNotifications(message, viaLaunch: true);
          } else {
            // FALLBACK MECHANISM:
            // Sometimes Firebase getInitialMessage() returns null even when app was launched
            // by notification. This happens when:
            // - A notification was shown while app was in foreground
            // - User killed the app without tapping notification
            // - Later, user taps the notification from notification tray
            //
            // In this case, we use local notification plugin to retrieve the launch data
            try {
              final NotificationAppLaunchDetails? notificationAppLaunchDetails =
                  await flutterLocalNotificationsPlugin
                      .getNotificationAppLaunchDetails();

              // Check if app was actually launched by a local notification
              if (widget.isInitialAppStart &&
                  notificationAppLaunchDetails != null &&
                  notificationAppLaunchDetails.didNotificationLaunchApp &&
                  !hasProcessedInitialNotification) {
                String? payload =
                    notificationAppLaunchDetails.notificationResponse?.payload;
                if (payload != null) {
                  // Convert local notification payload back to RemoteMessage format
                  Map<String, dynamic>? data = jsonDecode(payload);
                  RemoteMessage message = RemoteMessage.fromMap({"data": data});

                  hasProcessedInitialNotification = true;
                  takeActionOnNotifications(message, viaLaunch: true);
                }
              }
            } catch (error) {
              LogUtil.printLog(error);
            }
          }
        },
      );
    }

    // ============ REQUEST NOTIFICATION PERMISSIONS AND GET FCM TOKEN ============

    // Request notification permissions from user and get FCM token
    _firebaseMessaging.requestPermission().then((value) {
      _firebaseMessaging.getToken().then((String? token) {
        assert(token != null);
        LogUtil.printLog("Push Messaging token: $token");

        if (Platform.isAndroid) {
          // Register FCM token with Freshchat for Android
          // This allows Freshchat to send notifications to this device
          //
          // Setup Requirements:
          // Android: Add FCM server key to Freshchat web portal (Admin -> Mobile SDK)
          // iOS: Upload .p12 certificate to Freshchat
          fc.Freshchat.setPushRegistrationToken(token ?? '');
        }
      });
    });

    //add an observer to monitor the widget lyfecycle changes
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      //  app went to the background and is back to the foreground
      // popForced not working if app is in the background
      if (isPageAtTopStack(context, NetworkOfflineRoute.name) &&
          !isNetworkOffline) {
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            AutoRouter.of(context).popUntil((route) =>
                !ModalRoute.withName(NetworkOfflineRoute.name)(route));
          },
        );
      }
    }
    _lastState = state;
  }

  void handleNetworkConnection(NetworkState state) {
    if (mounted) {
      if (state == NetworkState.error) {
        LogUtil.printLog("Unable to connect. Please Check Internet Connection");
        isNetworkOffline = true;
        if (!isPageAtTopStack(context, NetworkOfflineRoute.name)) {
          AutoRouter.of(context).push(NetworkOfflineRoute());
        }
      } else {
        //due to will-popForced-scope used popForced
        if (isNetworkOffline && state == NetworkState.loaded) {
          if (isPageAtTopStack(context, NetworkOfflineRoute.name)) {
            AutoRouter.of(context).popUntil((route) =>
                !ModalRoute.withName(NetworkOfflineRoute.name)(route));
          }
          //popForced no internet page
          isNetworkOffline = false;
        }
      }
    }
  }

  Future<void> onUnlockScreen() async {
    isAppLocked = false;
    AutoRouter.of(context).push(BaseRoute());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.primaryAppColor,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        bloc: authenticationBloc,
        listener: (BuildContext context, AuthenticationState state) async {
          final SharedPreferences sharedPreferences = await prefs;

          if (state is AuthenticationLoading) {
            isAppLocked = true;
          }

          if (state is HalfAgentAuthenticated) {
            AutoRouter.of(context).push(BaseRoute());
          }

          if (state is AppUpdateAvailableState) {
            if (state.shouldForceUpdate ?? false) {
              AutoRouter.of(context)
                  .push(AppUpdateRoute(releaseNotes: state.releaseNotes));
            } else {
              navigationController.showAppUpdateDialog = true;
              authenticationBloc.add(AppLoadedup());
            }
          }

          if (state is AppUpdateNotAvailableState) {
            navigationController.showAppUpdateDialog = false;
            bool hasAnimationViewed =
                sharedPreferences.getBool("splash_animation_viewed") ?? false;
            if ((authenticationBloc.showFestiveAssets == true) &&
                !hasAnimationViewed) {
            } else {
              authenticationBloc.add(AppLoadedup());
            }
          }

          if (state is AppAutheticated) {
            isAppLocked = true;
            bool shouldDisablePasscode = sharedPreferences
                    .getBool(SharedPreferencesKeys.shouldDisablePasscode) ??
                false;

            if (shouldDisablePasscode) {
              AutoRouter.of(context).push(BaseRoute());
              isAppLocked = false;
            } else {
              sharedPreferences.getString('passcode') == null
                  ? showConfirmPasscode(
                      context: context,
                      backgroundColorOpacity: 1,
                      backgroundColor: Colors.white,
                      confirmTitle: 'Confirm New Passcode',
                      onCompleted: (context, verifyCode) async {
                        await sharedPreferences.setString(
                            'passcode', verifyCode);
                      },
                      canBiometric: true,
                      showBiometricFirst: true,
                      biometricAuthenticate: biometricAuthentication,
                      onUnlocked: onUnlockScreen,
                    )
                  : authenticationBloc.add(
                      UserLocalAuth(
                        passcode: sharedPreferences.getString('passcode')!,
                      ),
                    );
            }
          }
          if (state is UserLocalAuthState) {
            isAppLocked = true;
            showLockScreen(
              context: context,
              backgroundColorOpacity: 1,
              correctString: state.passcode,
              canBiometric: true,
              showBiometricFirst: true,
              biometricAuthenticate: biometricAuthentication,
              onUnlocked: onUnlockScreen,
            );
          }

          if (state is AuthenticationStart) {
            isAppLocked = false;
            // AutoRouter.of(context).push(AuthenticationRoute());
            AutoRouter.of(context).push(GetStartedRoute());
          }

          if (state is OnboardingPending) {
            isAppLocked = false;
            AutoRouter.of(context).push(OnboardingQuestionsRoute());
          }
          if (state is UserLogoutState) {
            try {
              await flutterLocalNotificationsPlugin.cancelAll();
            } catch (error) {
              LogUtil.printLog(error);
            }

            try {
              final cookieManager = WebViewCookieManager();
              cookieManager.clearCookies();
            } catch (error) {
              LogUtil.printLog(error);
            }

            FreshchatService().resetUser();

            Get.deleteAll(force: true);

            AutoRouter.of(context).pushAndPopUntil(
              SplashRoute(
                showLogoutMessage: state.showLogoutMessage,
                isInitialAppStart: false,
                isHalfAgentFlow: state.isLogggingOutForHalfAgent,
              ),
              predicate: (Route<dynamic> route) => false,
            );
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            // // maybe not reqd
            // if (authenticationBloc.showFestiveAssets == null) {
            //   return SizedBox();
            // }

            if (authenticationBloc.showFestiveAssets == true) {
              if (!authenticationBloc.hasSplashAnimationViewed) {
                return SplashScreenAnimation(
                  authenticationBloc: authenticationBloc,
                );
              } else {
                return SvgPicture.asset(AllImages().splashScreenDiwali);
              }
            } else {
              return Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AllImages().splashScreenIcon,
                      height: 90.toHeight,
                      width: 160.toWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.0.toHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  AllImages().splashScreenIconThree,
                                  width: 60,
                                  height: 60,
                                ),
                                SvgPicture.asset(
                                  AllImages().splashScreenIconTwo,
                                  width: 70,
                                  height: 51,
                                ),
                                SvgPicture.asset(
                                  AllImages().splashScreenIconOne,
                                  width: 47,
                                  height: 55,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Think Wealth Get Wealthy',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
