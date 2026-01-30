import 'package:api_sdk/api_collection/wealthcase_api.dart';
import 'package:api_sdk/log_util.dart';

class WealthcaseRepository {
  Future<dynamic> getWealthcaseList(String apiKey) async {
    try {
      final response = await WealthcaseAPI.getWealthcaseList(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog('getWealthcaseList repository error: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> getWealthcaseBasketDetail(
      String apiKey, String basketId) async {
    try {
      final response =
          await WealthcaseAPI.getWealthCaseBasketDetail(apiKey, basketId);
      return response;
    } catch (e) {
      LogUtil.printLog(
          'getWealthcaseBasketDetail repository error: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> createWealthCaseProposal(
    String apiKey,
    Map<String, dynamic> proposalData,
  ) async {
    try {
      final response =
          await WealthcaseAPI.createWealthCaseProposal(apiKey, proposalData);
      return response;
    } catch (e) {
      LogUtil.printLog(
          'createWealthCaseProposal repository error: ${e.toString()}');
      rethrow;
    }
  }
}
