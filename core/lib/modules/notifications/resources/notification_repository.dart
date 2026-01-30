import 'package:api_sdk/api_collection/notification_api.dart';
import 'package:api_sdk/log_util.dart';

class NotificationsRepository {
  Future<dynamic> getNotifications(String userToken,
      {required String screenLocation, int limit = 10, int offset = 0}) async {
    try {
      final response = await NotificationAPI.getNotifications(
        userToken,
        screenLocation: screenLocation,
        limit: limit,
        offset: offset,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> dismissNotification(String notificationToken) async {
    try {
      final response =
          await NotificationAPI.dismissNotification(notificationToken);

      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> markNotificationRead(String notificationToken) async {
    try {
      final response =
          await NotificationAPI.markNotificationRead(notificationToken);

      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getNotificationUnReadCount(
      String userToken, String screenLocation) async {
    try {
      final response = await NotificationAPI.getNotificationUnReadCount(
          userToken, screenLocation);

      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> resetNotificationUnReadCount(
      String userToken, String screenLocation) async {
    try {
      final response = await NotificationAPI.resetNotificationUnReadCount(
          userToken, screenLocation);

      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getNotificationDescriptionHtml(
      String descriptionHtmlId) async {
    try {
      final response = await NotificationAPI.getNotificationDescriptionHtml(
          descriptionHtmlId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getNotificationsCount(String apiKey) async {
    try {
      final response = await NotificationAPI.getNotificationCount(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> resetNotificationsCount(String apiKey) async {
    try {
      final response = await NotificationAPI.resetNotificationCount(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getDeeplinkData(String ntype, String aggregateId) async {
    try {
      final response =
          await NotificationAPI.getDeeplinkData(ntype, aggregateId);

      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
