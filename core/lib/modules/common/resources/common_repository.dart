import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/log_util.dart';

class CommonRepository {
  Future<dynamic> universalSearch(
      String apiKey, Map<String, String> queryParamMap) async {
    try {
      final response = await CommonAPI.universalSearch(apiKey, queryParamMap);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentReferralData(String apiKey) async {
    try {
      final response = await CommonAPI.getAgentReferralData(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  /// Checks if a feature flag is enabled based on provided feature name and user data
  Future<dynamic> checkFeatureAccess(
    String featureName,
    String agentId,
    Map<String, dynamic> customData,
  ) async {
    try {
      final response = await CommonAPI.checkFeatureAccess(
        featureName,
        agentId,
        customData,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(
          'checkFeatureAccess repository error ==> ${e.toString()}');
      return null;
    }
  }
}
