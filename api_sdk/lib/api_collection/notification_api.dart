import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class NotificationAPI {
  static getNotifications(String userToken,
      {required String screenLocation, int limit = 10, int offset = 0}) async {
    // {{domain}}/skynet/v1/dn/notifications/?screen_location=bell-icon&limit=10&offset=0
    dynamic headers = await ApiSdk.getHeaderInfo(userToken);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}dn/notifications/?screen_location=$screenLocation&limit=$limit&offset=$offset";
    print('ping- $url');
    print(headers);
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
    // dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    // print('ping-${ApiConstants().getRestApiUrl('notification')}');
    // print(headers);
    // final response = await RestApiHandlerData.getData(
    //     ApiConstants().getRestApiUrl('notification'), headers);
    // return response;
  }

  static dismissNotification(String notificationToken) async {
    dynamic headers = await ApiSdk.getHeaderInfo(notificationToken);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}dn/notifications/dismiss/";
    print('ping- $url');
    print(headers);

    Map<String, dynamic> body = {"user_token": notificationToken};
    final response = await RestApiHandlerData.postData(url, body, headers);
    return response;
  }

  static markNotificationRead(String notificationToken) async {
    dynamic headers = await ApiSdk.getHeaderInfo(notificationToken);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}dn/notifications/mark-read/";
    print('ping- $url');
    print(headers);

    Map<String, dynamic> body = {"user_token": notificationToken};
    final response = await RestApiHandlerData.postData(url, body, headers);
    return response;
  }

  static getNotificationUnReadCount(
      String userToken, String screenLocation) async {
    dynamic headers = await ApiSdk.getHeaderInfo(userToken);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}dn/notifications/unread-count/?screen_location=$screenLocation";
    print('ping- $url');
    print(headers);

    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static resetNotificationUnReadCount(
      String userToken, String screenLocation) async {
    dynamic headers = await ApiSdk.getHeaderInfo(userToken);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}dn/notifications/unread-count/?screen_location=$screenLocation";
    print('ping- $url');
    print(headers);

    Map<String, dynamic> payload = {
      "delta": 0,
      "screen_location": screenLocation
    };

    final response = await RestApiHandlerData.postData(url, payload, headers);
    return response;
  }

  static getNotificationDescriptionHtml(String descriptionHtmlId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    String url =
        "${ApiConstants().getRestApiUrl('skynet-v1')}campaign/template/html/$descriptionHtmlId/";
    print('ping- $url');
    print(headers);

    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getNotificationCount(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        ApiConstants().getRestApiUrl('notification-count'), headers);
    return response;
  }

  static resetNotificationCount(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('notification-reset-count'), {}, headers);
    return response;
  }

  static getDeeplinkData(String ntype, String aggregateId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final url =
          "${ApiConstants().getRestApiUrl('skynet-v1')}tenant/deeplink/advisors/$ntype/$aggregateId/";
      final response = await RestApiHandlerData.getData(url, headers);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
