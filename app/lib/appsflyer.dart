// import 'dart:io';

// import 'package:app/src/config/constants/util_constants.dart';
// import 'package:appsflyer_sdk/appsflyer_sdk.dart';

// class AppsflyerSDK {
//   static final String _key = 'VhZwWToyyES7JAtGSAaPs5';
//   static final String _appId =
//       Platform.isIOS ? '1585943279' : '794626151162234';
//   static final AppsFlyerOptions _options = AppsFlyerOptions(
//       afDevKey: _key,
//       appId: _appId,
//       showDebug: true,
//       appInviteOneLink: 'https://mylinks.wealthy.in/k8y4/joinus');
//   static AppsflyerSdk? _appsflyerSdk;
//   static Future<AppsflyerSdk?> get instance async {
//     if (_appsflyerSdk != null) return _appsflyerSdk;
//     _appsflyerSdk = await init();
//     return _appsflyerSdk;
//   }

//   static Future<AppsflyerSdk?> init() async {
//     _appsflyerSdk = AppsflyerSdk(_options);
//     _appsflyerSdk!.waitForCustomerUserId(true);
//     await _appsflyerSdk!.initSdk(
//       registerConversionDataCallback: true,
//       registerOnAppOpenAttributionCallback: true,
//       registerOnDeepLinkingCallback: true,
//     );
//     _appsflyerSdk!.onInstallConversionData(_onInstallConversionData);
//     return _appsflyerSdk;
//   }

//   static void setUninstallToken(String? fcmToken) async {
//     // await instance.then((_) => _!.updateServerUninstallToken(fcmToken!));
//   }

//   static void setCustomerUserId(String? externalId) async {
//     // await instance.then((_) => _!.setCustomerUserId(externalId!));
//   }

//   static void logEvent(String eventName,
//       {Map<String, dynamic>? eventValues}) async {
//     // if (eventValues == null) {
//     //   eventValues = Map<String, dynamic>();
//     // }

//     // int? agentId = await getAgentId();
//     // eventValues["userId"] = 'agent-$agentId';

//     // await instance.then((_) {
//     //   _!.logEvent(eventName, eventValues);
//     // });
//   }

//   static _onInstallConversionData(res) {}
// }
