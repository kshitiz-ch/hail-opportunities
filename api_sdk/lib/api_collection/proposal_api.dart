import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';
import 'package:dio/dio.dart';

class ProposalAPI {
  static getProposalsListv2(
    String apiKey,
    int agentId,
    Map<String, dynamic> payload, {
    CancelToken? cancelToken,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-agent-id'] = agentId.toString();

    String apiUrl = "${ApiConstants().getRestApiUrl('proposals-v2')}";

    final response = await RestApiHandlerData.postData(
      '$apiUrl',
      jsonEncode(payload),
      headers,
      cancelToken: cancelToken,
    );

    return response;
  }

  static getProposal(String apiKey, String proposalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('proposals')}$proposalId/';
    final response = await RestApiHandlerData.getData('$apiUrl', headers);
    return response;
  }

  static markProposalFailurev2({
    required String apiKey,
    required String proposalId,
    required Map<String, String> body,
    required String agentId,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-agent-id'] = agentId;
    final response = await RestApiHandlerData.postData(
      '${ApiConstants().getRestApiUrl('proposals-v2')}$proposalId/mark-status-failure/',
      body,
      headers,
    );
    return response;
  }

  static markProposalFailure(
      String apiKey, String proposalId, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('proposals')}$proposalId/mark-status-failure/',
        body,
        headers);
    return response;
  }

  static getProposalEditUrl(String apiKey, proposalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('proposals')}$proposalId/get-edit-url/',
        headers);
    return response;
  }

  static getProposalCount(String apiKey, String? userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlQlHandler.getProposalCount(userId ?? '');
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getSchemeOrderStatus(String apiKey,
      {required String proposalId, required String userId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlQlHandler.getSchemeOrderStatus(
          proposalId: proposalId, userId: userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
