import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:core/main.dart';
import 'package:core/modules/notifications/resources/notification_repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void handleTokenExpiry(data) {
  try {
    var message = jsonDecode(data['response']['message']);

    if (message['error_code'] == "AUTH002") {
      AuthenticationBlocController()
          .authenticationBloc
          .add(UserLogOut(showLogoutMessage: true));
    }
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
}

Future<void> handleGraphqlTokenExpiry() async {
  try {
    final SharedPreferences sharedPreferences = await prefs;
    var data = await NotificationsRepository()
        .getNotificationsCount(sharedPreferences.getString('apiKey')!);
    handleTokenExpiry(data);
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
}

String getFormattedDate(DateTime? date) {
  try {
    if (date == null) {
      return '-';
    }
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  } catch (error) {
    LogUtil.printLog('error==>$error');
    return '-';
  }
}
