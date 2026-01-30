import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class MutualFundAPI {
  static getMfGoalSubtype(int subType, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.mutualFunds(subType);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getUserSipMeta(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('get-user-sip-meta'), body, headers);

    return response;
  }
}
