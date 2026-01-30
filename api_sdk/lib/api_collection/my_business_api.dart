import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';

class MyBusinessAPI {
  static getPartnerTotalAum(
      String apiKey, List<String> agentExternalIdList) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getPartnerTotalAum(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerMfMetrics(
    String apiKey,
    List<String> agentExternalIdList,
    String date,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getPartnerMfMetrics(
        agentExternalIdList,
        date,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerClientMetrics(
    String apiKey,
    List<String> agentExternalIdList,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getPartnerClientMetrics(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
