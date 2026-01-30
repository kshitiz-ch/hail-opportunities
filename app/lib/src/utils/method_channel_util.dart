import 'package:api_sdk/log_util.dart';
import 'package:flutter/services.dart';

class MethodChannelUtil {
  static const platform = const MethodChannel('in.wealthy.advisor');

  /// Gets phone number hint using Android's Phone Number Hint API
  /// This uses Google Play Services to show a phone number picker dialog
  /// Returns selected phone number or empty string if cancelled/not available
  static Future<String?> getPhoneNumberHint() async {
    try {
      final String? phoneNumber =
          await platform.invokeMethod('getPhoneNumberHint');
      LogUtil.printLog('Phone hint received: $phoneNumber');
      return phoneNumber;
    } catch (e) {
      LogUtil.printLog('Error getting phone hint: $e');
      return null;
    }
  }
}
