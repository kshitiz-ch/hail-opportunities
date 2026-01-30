import 'package:api_sdk/log_util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseEventService {
  static final FirebaseEventService _instance =
      FirebaseEventService._internal();

  factory FirebaseEventService() {
    return _instance;
  }

  FirebaseEventService._internal();

  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  static Future<void> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      LogUtil.printLog('logging firebase event: $name');

      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      LogUtil.printLog('Error logging firebase event: $e');
    }
  }
}
