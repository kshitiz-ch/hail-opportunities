import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class WealthAcademyAPI {
  static getEventSchedules(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('events')}event_schedules',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getEventScheduleDetails(String apiKey, String eventId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('events')}event_schedules?event_schedule_id=$eventId',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static subscribeEvent(String eventId, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final response = await RestApiHandlerData.postData(
          '${ApiConstants().getRestApiUrl('events')}events/$eventId/subscribe/',
          {},
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getSalesPlanCreatives(String salesPlanId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      String queryParams = '';

      if (salesPlanId.isNotEmpty) {
        queryParams = '?id=$salesPlanId';
      } else {
        return null;
      }

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/sales-plan-creatives$queryParams',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
