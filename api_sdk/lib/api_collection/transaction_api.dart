import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';

class TransactionAPI {
  static getTransactions(
    String? apiKey,
    Map<String, dynamic> payload,
    String type,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlQlHandler.getTransactions(payload, type);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
