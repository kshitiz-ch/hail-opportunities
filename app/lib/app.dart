import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/global_keys.dart';
import 'package:app/src/config/constants/theme_data.dart';
import 'package:app/src/config/routes/router.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:core/main.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavors.dart';

final _kTestingCrashlytics = false;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final RootRouter _rootRouter = RootRouter(GlobalKeys.navigatorKey);

  Future<void> _initializeFlutterFire() async {
    await Firebase.initializeApp();
    LogUtil.printLog('firebase init');
    if (_kTestingCrashlytics) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
    Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      originalOnError!(errorDetails);
    };
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      resetInitialUriHandled();
    });

    _initializeFlutterFire();

    // Show tracking authorization dialog and ask for permission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackingTransparencyRequest();
    });
  }

  Future<String?> _trackingTransparencyRequest() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    LogUtil.printLog('status ==> ' + status.name);
    if (status == TrackingStatus.authorized) {
      final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
      return uuid;
    } else if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
      final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
      return uuid;
    }

    return null;
  }

  void resetInitialUriHandled() async {
    try {
      final SharedPreferences sharedPreferences = await prefs;
      await sharedPreferences.setBool("isInitialUriHandled", false);
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp.router(
          localizationsDelegates: [
            CountryLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: F.appFlavor == Flavor.PROD ? false : true,
          title: F.title,
          theme: ThemeConfig.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: _rootRouter.config(),
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                textScaler: data.textScaler
                    .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1),
              ),
              child: ResponsiveBreakpoints.builder(
                child:
                    BouncingScrollWrapper.builder(context, child ?? SizedBox()),
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                      start: 1921, end: double.infinity, name: '4K')
                ],
              ),
            );
          },

          // routerDelegate: _rootRouter.delegate(),
          // builder: (BuildContext context, Widget widget) {
          //   Widget error = Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 20),
          //     child: Text(
          //       'Failed to fetch data',
          //       style: TextStyle(
          //         fontSize: 22,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   );
          //   if (widget is Scaffold || widget is Navigator) {
          //     error = Scaffold(body: Center(child: error));
          //   }
          //   ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          //     // errorDetails.
          //     FirebaseCrashlytics.instance
          //         .recordError(errorDetails.exception, errorDetails.stack);
          //     return error;
          //   };
          //   return widget;
          // },

          // Not required in flutter 3.24.0
          // routerDelegate: _rootRouter.delegate(
          //   navigatorObservers: () => [AutoRouteObserver()],
          // ),
          // routeInformationProvider: _rootRouter.routeInfoProvider(),
          // routeInformationParser: _rootRouter.defaultRouteParser(),
        ),
      );
    });
  }
}
