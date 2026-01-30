import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/firebase/firebase_event_service.dart';
import 'package:app/src/config/freshchat/freshchat_service.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:blitzllama_flutter/blitzllama_flutter.dart';
import 'package:core/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'app.dart';
import 'flavors.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Plugin must be initialized before using
    FlutterDownloader.initialize(debug: true);
    F.appFlavor = Flavor.PROD;
    await Firebase.initializeApp();
    await FirebaseEventService.init();

    BlitzllamaFlutter.init("key_BIyVeSujI0zyhA1");
    await MixPanelAnalytics.init();

    getURLFlavourConstants(
      url: F.url,
      graphqlUrl: F.graphqlUrl,
      taxyUrl: F.urlTaxy,
      quinjetUrl: F.quinjetBaseUrl,
      fundsApiUrl: F.fundsApiBaseUrl,
      certifiedBaseUrl: F.certificateEnabledUrl,
      apiClientCertificate: F.clientCertificate,
      apiClientCertificateKey: F.clientCertificateKey,
      isProd: true,
    );
    SystemChrome.setSystemUIOverlayStyle(getDarkStatusBar());
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance
          .recordError(details.exception, details.stack);
      //make our application quit immediately any time an error is caught by Flutter in release mode
      // exit(1);
    };
    await FreshchatService().initializeFreshchat();
    runApp(App());
  }, (error, stackTrace) {
    LogUtil.printLog(
        'runZonedGuarded: Caught error in my root zone. Error: $error');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
