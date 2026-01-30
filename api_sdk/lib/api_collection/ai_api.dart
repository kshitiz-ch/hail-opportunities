import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class AIAPI {
  static getWealthyAiUrl(String apiKey, {String? question}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getWealthyAiUrl(question);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getWealthyAiAccessToken(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getWealthyAiAccessToken();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAiResponse(dynamic body) async {
    try {
      final url = ApiConstants().getRestApiUrl('ai-response-api');
      final xThreadId = ApiConstants().xThreadId;
      final xAccessToken = ApiConstants().xAccessToken;

      final urlWithAssistantKey = url + '/$xThreadId/run-chat/';

      dynamic headers = await ApiSdk.getHeaderInfo('Bearer $xAccessToken');

      headers['Content-Type'] = 'application/json';

      final response = await RestApiHandlerData.postData(
        urlWithAssistantKey,
        jsonEncode(body),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static endSession() async {
    try {
      final url = ApiConstants().getRestApiUrl('ai-response-api');
      final xThreadId = ApiConstants().xThreadId;
      final xAccessToken = ApiConstants().xAccessToken;

      final urlWithThreadId = url + '/$xThreadId/end-session/';

      dynamic headers = await ApiSdk.getHeaderInfo('Bearer $xAccessToken');

      headers['Content-Type'] = 'application/json';

      final response =
          await RestApiHandlerData.postData(urlWithThreadId, '', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
