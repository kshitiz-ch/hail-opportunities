import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class MyTeamAPI {
  static createPartnerOffice({String? name, String? apiKey}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.createPartnerOffice(name);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getEmployees({
    String? search,
    String? designation,
    String? apiKey,
    int limit = 0,
    int offset = 0,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getEmployees(
          search: search,
          designation: designation,
          limit: limit,
          offset: offset);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnersDailyMetric(
      {List<String>? agentExternalIdList,
      String date = '',
      String? apiKey}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getPartnersDailyMetric(
          agentExternalIdList: agentExternalIdList, date: date);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static addExistingAgentPartnerOfficeEmployee(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.addExistingAgentPartnerOfficeEmployee(
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static addPartnerOfficeEmployee(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.addPartnerOfficeEmployee(
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static assignUnassignClient(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.assignUnassignClient(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static renameOffice(Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.renameOffice(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static removeEmployee(Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.removeEmployee(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static verifyNewAgentLeadOtp(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('validate-team-agent-lead-otp'),
        jsonEncode(payload),
        headers);
    return response;
  }

  static resendAgentLeadOtp(Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('resend-team-agent-lead-otp'),
        jsonEncode(payload),
        headers);
    return response;
  }

  static validateAndAddEmployee(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('validate-and-add-employee'),
        jsonEncode(payload),
        headers);
    return response;
  }

  static validateAndAddAssociate(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('validate-and-add-associate'),
        jsonEncode(payload),
        headers);
    return response;
  }
}
