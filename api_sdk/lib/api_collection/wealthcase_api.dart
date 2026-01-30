import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class WealthcaseAPI {
  static Future<dynamic> getWealthcaseList(String apiKey) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = "application/json";

      final response = await RestApiHandlerData.getData(
        ApiConstants().getRestApiUrl('wealthcase-baskets'),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('getWealthcaseList API error: ${e.toString()}');
      rethrow;
    }
  }

  static Future<dynamic> getWealthCaseBasketDetail(
      String apiKey, String basketId) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = "application/json";

      final response = await RestApiHandlerData.getData(
        ApiConstants().getRestApiUrl('wealthcase-basket-detail') + '$basketId/',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('getWealthCaseBasketDetail API error: ${e.toString()}');
      rethrow;
    }
  }

  static Future<dynamic> createWealthCaseProposal(
    String apiKey,
    Map<String, dynamic> proposalData,
  ) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = "application/json";

      String url = ApiConstants().getRestApiUrl('quinjet-proposals');
      url += 'v0/wealthcase/';

      final response = await RestApiHandlerData.postData(
        url,
        proposalData,
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('createWealthCaseProposal API error: ${e.toString()}');
      rethrow;
    }
  }
}
