import 'package:api_sdk/api_collection/broking_api.dart';
import 'package:api_sdk/log_util.dart';

class BrokingRepository {
  Future<dynamic> getBrokingActivity(
    String apiKey,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await BrokingAPI.getBrokingActivity(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getBrokingOnboardingClients(
    String apiKey,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response =
          await BrokingAPI.getBrokingOnboardingClients(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> generateBrokingKycUrl(
    String apiKey,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await BrokingAPI.generateBrokingKycUrl(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getBrokingDetails(
      String apiKey, List<String> agentExternalIdList, String date) async {
    try {
      final response = await BrokingAPI.getBrokingDetails(
        apiKey,
        agentExternalIdList,
        date,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getBrokingPlans(String apiKey) async {
    try {
      final response = await BrokingAPI.getBrokingPlans(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerApStatus(String apiKey, String agentId) async {
    try {
      final response = await BrokingAPI.getPartnerApStatus(apiKey, agentId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateDefaultBrokingPlan(
      {required String apiKey,
      required String agentId,
      required String planCode}) async {
    try {
      final response =
          await BrokingAPI.updateDefaultBrokingPlan(apiKey, agentId, planCode);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateUserBrokeragePlan(
      {required String apiKey,
      required String userId,
      required String planCode}) async {
    try {
      final response =
          await BrokingAPI.updateUserBrokeragePlan(apiKey, userId, planCode);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
