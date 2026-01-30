import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';

class BrokingAPI {
  static getBrokingActivity(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getBrokingActivity(payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getBrokingOnboardingClients(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getBrokingOnboardingClients(payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static generateBrokingKycUrl(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.generateBrokingKycUrl(payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getBrokingDetails(
      String apiKey, List<String> agentExternalIdList, String date) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getBrokingDetails(agentExternalIdList, date);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getBrokingPlans(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getBrokingPlans();

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerApStatus(String apiKey, String agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getPartnerApStatus(agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static updateDefaultBrokingPlan(
      String apiKey, String agentId, String planCode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.updateDefaultBrokingPlan(agentId, planCode);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static updateUserBrokeragePlan(
      String apiKey, String userId, String planCode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['x-w-client-id'] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.updateUserBrokeragePlan(planCode);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
