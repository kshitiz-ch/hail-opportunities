import 'dart:io';

import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> init() async {
    String? token;
    try {
      // For iOS request permission first.
      if (Platform.isIOS) await _firebaseMessaging.requestPermission();

      // For testing purposes print the Firebase Messaging token
      token = await _firebaseMessaging.getToken();
      LogUtil.printLog("FirebaseMessaging token: $token");
    } catch (error) {
      LogUtil.printLog(error);
    }

    return token;
  }

  void trackNotificationCall(String? trackingUrl) {
    CommonAPI.trackNotification(trackingUrl);
  }
}
