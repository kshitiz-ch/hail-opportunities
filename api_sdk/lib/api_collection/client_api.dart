import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class ClientAPI {
  static queryClientList(String agentId, bool isPrivileged, bool recentLeads,
      String apiKey, String? query,
      {limit, offset, String? requestAgentId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler queryClientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await queryClientList.getClientList(
          agentId, isPrivileged, recentLeads, query,
          limit: limit, offset: offset, requestAgentId: requestAgentId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientLoginDetails({String? userId, String? apiKey}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['x-w-client-id'] = userId;

    try {
      final GraphqlQlHandler queryClientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await queryClientList.getClientLoginDetails(userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientsCount(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler queryClientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await queryClientList.getClientsCount();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getEmployeesClientCount(String apiKey, String agentExternalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler queryClientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await queryClientList.getEmployeesClientCount(agentExternalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientDetails({String? clientId, String? apiKey}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final GraphqlQlHandler clientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientList.getClientDetails(clientId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientDetailsByTaxyId(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler clientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientList.getClientDetailsByTaxyId(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static addClient(
    String apiKey,
    String email,
    bool isEmailUnknown,
    String name,
    String phoneNumber,
    String source,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler githubRepository =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await githubRepository.addClient(
          email, isEmailUnknown, name, phoneNumber, source);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientInvestments(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler clientInvestments =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientInvestments.getClientInvestments(userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientMfTransactions(
      {required String apiKey,
      required String userId,
      String? goalId,
      int limit = 20,
      int offset = 0}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler clientInvestments =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientInvestments.getClientMfTransactions(userId,
          goalId: goalId, limit: limit, offset: offset);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientTrackerValue(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler clientTrackerValue =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientTrackerValue.getClientTrackerValue(userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static updateClientPhone(apiKey, userId, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('update-client-details')}user-phone-number/',
        jsonEncode(body),
        headers);

    return response;
  }

  static updateClientEmail(apiKey, userId, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('update-client-details')}user-email/',
        jsonEncode(body),
        headers);

    return response;
  }

  static updateClientName(apiKey, userId, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('update-client-details')}user-name/',
        jsonEncode(body),
        headers);

    return response;
  }

  static generateClientUpdateLink(apiKey, userId, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('update-client-details')}generate-update-link/',
        jsonEncode(body),
        headers);

    return response;
  }

  static sendClientEmailVerificationLink(apiKey, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('initialize-email-verification')}',
        jsonEncode(body),
        headers);

    return response;
  }

  static sendPartnerVerificationOtp(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
      ApiConstants().getRestApiUrl('send-pv-otp'),
      jsonEncode(body),
      headers,
    );

    return response;
  }

  static reSendPartnerVerificationOtp(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('resend-pv-otp'),
        jsonEncode(body),
        headers);

    return response;
  }

  static verifyPartnerVerificationOtp(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
      ApiConstants().getRestApiUrl('verify-pv-otp'),
      jsonEncode(body),
      headers,
    );

    return response;
  }

  static getClientProposals(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('proposals')}?user_id=$userId',
        headers);
    return response;
  }

  static getClientInvestmentDetails(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('client-investment-data');
    headers['x-w-client-id'] = userId;
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getProductInvestmentDetails(
    String apiKey,
    String userId, {
    bool showZeroFolios = false,
    required ClientInvestmentProductType type,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    try {
      final GraphqlQlHandler clientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await clientList.getProductInvestmentDetails(type, showZeroFolios);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getUserPortfolioOverview(String apiKey, String memberUserId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = memberUserId;

    try {
      final GraphqlQlHandler clientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientList.getUserPortfolioOverview(memberUserId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientList(
    String agentId,
    bool isPrivileged,
    bool recentLeads,
    String apiKey, {
    limit,
    offset,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final GraphqlQlHandler clientList =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientList.getClientList(
          agentId, isPrivileged, recentLeads, null,
          limit: limit, offset: offset);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // New Client Family addition api

  static fetchFamilyMembers(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.fetchfamilyMembers(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("fetchFamilyMembers error ==> ${e.toString()}");
    }
  }

  static fetchClientFamily(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.fetchClientFamily();

      return response;
    } catch (e) {
      LogUtil.printLog("fetchClientFamily error ==> ${e.toString()}");
    }
  }

  static createFamilyMembers(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.createFamilyMembers(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("createFamilyMembers error ==> ${e.toString()}");
    }
  }

  static verifyFamilyMember(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.verifyFamilyMember(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("verifyFamilyMember error ==> ${e.toString()}");
    }
  }

  static resendFamilyVerificationOtp(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.resendFamilyVerificationOtp(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("resendOtp error ==> ${e.toString()}");
    }
  }

  static kickFamilyMember(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.kickFamilyMember(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("kickFamilyMember error ==> ${e.toString()}");
    }
  }

  static leaveFamily(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.leaveFamily(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("leaveFamily error ==> ${e.toString()}");
    }
  }

  static getSIPList(
    String apiKey,
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSIPList(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getSIPList error ==> ${e.toString()}");
    }
  }

  static getSIPDetails(
    String apiKey,
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSIPDetails(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getSIPDetails error ==> ${e.toString()}");
    }
  }

  static getSIPOrders(
    String apiKey,
    String clientId,
    String goalId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final payload = <String, dynamic>{
      'userId': clientId,
      'goalId': goalId,
    };
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSIPOrders(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getSIPOrders error ==> ${e.toString()}");
    }
  }

  static getSIPDetailsV2(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSIPDetailsV2(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getSIPDetailsV2 error ==> ${e.toString()}");
    }
  }

  static updateSipProposal(String apiKey, Map<String, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('sip-edit-proposal');
    final payload = jsonEncode(body);

    final response = await RestApiHandlerData.postData(
      url,
      payload,
      headers,
    );

    return response;
  }

  static getStpList(String apiKey, String clientId, String goalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getStpList(clientId, goalId);

      return response;
    } catch (e) {
      LogUtil.printLog("getSTPList error ==> ${e.toString()}");
    }
  }

  static getStpOrders(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getStpOrders(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getStpOrders error ==> ${e.toString()}");
    }
  }

  static getClientAllocationDetails(
      String apiKey, String clientId, String panNumber) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientAllocationDetails(
        userId: clientId,
        panNumber: panNumber,
      );

      return response;
    } catch (e) {
      LogUtil.printLog("getClientAllocationDetails error ==> ${e.toString()}");
    }
  }

  static getClientHoldingDetails(
      String apiKey, String clientId, String panNumber) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientHoldingDetails(
        userId: clientId,
        panNumber: panNumber,
      );

      return response;
    } catch (e) {
      LogUtil.printLog("getClientHoldingDetails error ==> ${e.toString()}");
    }
  }

  static getClientDetailChangeRequestData(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('client-detail-change-request');

    headers['content-type'] = 'application/json';

    final response =
        await RestApiHandlerData.postData(url, jsonEncode(body), headers);

    return response;
  }

  static getClientProfileDetails(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientProfileDetails(userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientMandates({
    required String apiKey,
    required String userId,
    String sipMetaExternalId = '',
    bool fetchConfirmedOnly = false,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientMandates(
        userId: userId,
        sipMetaExternalId: sipMetaExternalId,
        fetchConfirmedOnly: fetchConfirmedOnly,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static shareMandateProposal(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = 'application/json';

    final url = ApiConstants().getRestApiUrl('mandate-proposal');
    // headers['x-w-client-id'] = userId;

    final response =
        await RestApiHandlerData.postData(url, jsonEncode(payload), headers);

    return response;
  }

  static getMandateOptions(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = 'application/json';

    final url = ApiConstants().getRestApiUrl('mandate-options');
    // headers['x-w-client-id'] = userId;

    final response =
        await RestApiHandlerData.postData(url, jsonEncode(payload), headers);
    return response;
  }

  static getClientTickets(String apiKey, String clientId, int offset) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientTickets(
        userId: clientId,
        offset: offset,
      );

      return response;
    } catch (e) {
      LogUtil.printLog("getClientTickets error ==> ${e.toString()}");
    }
  }

  static getClientReportTemplates(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getClientReportTemplates(userId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientReportTemplates error ==> ${e.toString()}");
    }
  }

  static getMandates(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getMandates(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getMandates error ==> ${e.toString()}");
    }
  }

  static getUserMandateMeta(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getUserMandateMeta(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getUserMandateMeta error ==> ${e.toString()}");
    }
  }

  static getClientNominees(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getClientNominees(userId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientNominees error ==> ${e.toString()}");
    }
  }

  static getClientBankAccounts(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.getClientBankAccounts(userId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientBankAccounts error ==> ${e.toString()}");
    }
  }

  static getClientBrokingBankAccounts(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.getClientBrokingBankAccounts(userId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(
          "getClientBrokingBankAccounts error ==> ${e.toString()}");
    }
  }

  static getClientWealthyDematDetail(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getClientWealthyDematDetail(userId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientWealthyDematDetail error ==> ${e.toString()}");
    }
  }

  static getClientAddressDetail(String apiKey, String clientId,
      {String? addressId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientAddressDetail(
          userId: clientId, addressId: addressId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientAddressDetail error ==> ${e.toString()}");
    }
  }

  static createMfProfile(
      String apiKey, String clientId, Map<String, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.createMfProfile(body);

      return response;
    } catch (e) {
      LogUtil.printLog("createMfProfile error ==> ${e.toString()}");
    }
  }

  static addClientAddress(
      String apiKey, String clientId, Map<dynamic, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.addClientAddress(body);

      return response;
    } catch (e) {
      LogUtil.printLog("addClientAddress error ==> ${e.toString()}");
    }
  }

  static updateClientAddress(
      String apiKey, String clientId, Map<dynamic, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.updateClientAddress(body);

      return response;
    } catch (e) {
      LogUtil.printLog("updateClientAddress error ==> ${e.toString()}");
    }
  }

  static deleteClientAddress(String apiKey, String clientId, String id) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.deleteClientAddress(id);

      return response;
    } catch (e) {
      LogUtil.printLog("deleteClientAddress error ==> ${e.toString()}");
    }
  }

  static setDefaultBankAccount(String apiKey,
      {required String clientId, required String bankId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.setDefaultBankAccount(bankId);

      return response;
    } catch (e) {
      LogUtil.printLog("setDefaultBankAccount error ==> ${e.toString()}");
    }
  }

  static deleteClient(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.deleteClient(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("deleteClient error ==> ${e.toString()}");
    }
  }

  static createUserNominee(String apiKey, Map<String, dynamic> body,
      {required String clientId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.createUserNominee(body);

      return response;
    } catch (e) {
      LogUtil.printLog("createUserNominee error ==> ${e.toString()}");
    }
  }

  static updateUserNominee(String apiKey, Map<String, dynamic> body,
      {required String clientId, required String nomineeId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.updateUserNominee(nomineeId, body);

      return response;
    } catch (e) {
      LogUtil.printLog("updateUserNominee error ==> ${e.toString()}");
    }
  }

  static createMfNominees(String apiKey, List<Map<String, dynamic>> body,
      {required String clientId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.createMfNominees(body);

      return response;
    } catch (e) {
      LogUtil.printLog("createMfNominees error ==> ${e.toString()}");
    }
  }

  static editDematAccount(String userId, Map body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.editDematAccount(body);

      return response;
    } catch (e) {
      LogUtil.printLog('editDematAccount error ==>${e.toString()}');
    }
  }

  static sendTrackerSwitchProposal(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('tracker-switch-proposal');
    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
      url,
      jsonEncode(body),
      headers,
    );

    return response;
  }

  static getClientInvestmentStatus(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientInvestmentStatus(clientId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientReportList error ==> ${e.toString()}");
    }
  }

  static getClientReportList({
    required String apiKey,
    required String clientId,
    required Map<String, dynamic> payload,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getClientReportList(payload: payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientReportList error ==> ${e.toString()}");
    }
  }

  static getClientReport({
    required String apiKey,
    required String clientId,
    required Map<String, dynamic> payload,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientReport(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientReport error ==> ${e.toString()}");
    }
  }

  static createClientReport({
    required String apiKey,
    required String clientId,
    required Map<String, dynamic> payload,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.createClientReport(payload: payload);

      return response;
    } catch (e) {
      LogUtil.printLog("createClientReport error ==> ${e.toString()}");
    }
  }

  static refreshReportLink({
    required String apiKey,
    required String clientId,
    required Map<String, dynamic> payload,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.refreshReportLink(payload: payload);

      return response;
    } catch (e) {
      LogUtil.printLog("refreshReportLink error ==> ${e.toString()}");
    }
  }

  static createGoalOrder(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.createGoalOrder(payload: payload);

      return response;
    } catch (e) {
      LogUtil.printLog("createGoalOrder error ==> ${e.toString()}");
    }
  }

  static createSwitchOrder(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url =
          "${ApiConstants().getRestApiUrl('order-proposal')}create-switch-order/";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createSwitchOrder error ==> ${e.toString()}");
    }
  }

  static createWithdrawalOrder(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url =
          "${ApiConstants().getRestApiUrl('order-proposal')}create-withdrawal-order/";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createWithdrawalOrder error ==> ${e.toString()}");
    }
  }

  static createStp(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url = "${ApiConstants().getRestApiUrl('stp-proposal')}create-stp";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createSwp error ==> ${e.toString()}");
    }
  }

  static editStp(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url = "${ApiConstants().getRestApiUrl('stp-proposal')}edit-stp";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createSwp error ==> ${e.toString()}");
    }
  }

  static createSwp(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url = "${ApiConstants().getRestApiUrl('swp-proposal')}create-swp";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createSwp error ==> ${e.toString()}");
    }
  }

  static editSwp(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;
    headers['content-type'] = 'application/json';

    try {
      final url = "${ApiConstants().getRestApiUrl('swp-proposal')}edit-swp";

      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog("createSwp error ==> ${e.toString()}");
    }
  }

  static markGoalAsCustom(String apiKey, String userId, String goalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.markGoalAsCustom(goalId: goalId);

      return response;
    } catch (e) {
      LogUtil.printLog("markGoalAsCustom error ==> ${e.toString()}");
    }
  }

  static updateGoal(
      String apiKey, String userId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.updateGoal(payload: payload);

      return response;
    } catch (e) {
      LogUtil.printLog("updateGoal error ==> ${e.toString()}");
    }
  }

  static getClientKraStatusCheck(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientKraStatusCheck(userId);

      return response;
    } catch (e) {
      LogUtil.printLog("getClientKraStatusCheck error ==> ${e.toString()}");
    }
  }

  static getSwpList(String apiKey, String userId, String goalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = userId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getSwpList(goalId: goalId, userId: userId);

      return response;
    } catch (e) {
      LogUtil.printLog("getSwpList error ==> ${e.toString()}");
    }
  }

  static getSWPDetails(
    String apiKey,
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSWPDetails(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("getSWPDetails error ==> ${e.toString()}");
    }
  }

  static getUserProfileViewData(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getUserProfileViewData();

      return response;
    } catch (e) {
      LogUtil.printLog("getUserProfileViewData error ==> ${e.toString()}");
    }
  }

  static getClientOnboardingDetails(
    String apiKey,
    String clientId,
    String onboardingProduct,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getClientOnboardingDetails(
        clientId,
        onboardingProduct,
      );

      return response;
    } catch (e) {
      LogUtil.printLog("getClientOnboardingDetails error ==> ${e.toString()}");
    }
  }

  static requestProfileUpdate(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.requestProfileUpdate(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("requestProfileUpdate error ==> ${e.toString()}");
    }
  }

  static requestVerifiedProfileUpdate(String apiKey, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers["x-w-client-id"] = clientId;

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.requestVerifiedProfileUpdate();

      return response;
    } catch (e) {
      LogUtil.printLog(
          "requestVerifiedProfileUpdate error ==> ${e.toString()}");
    }
  }

  static getSyncedPanInfo(String userId, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getSyncedPanInfo(userId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getFilterMapping(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final apiUrl = ApiConstants().getRestApiUrl('client-filters-field');

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
    );
    return response;
  }

  /// Get synchronized PAN information for a specific user
  ///
  /// [apiKey] - API key for authentication
  /// [userId] - User ID to fetch synced PANs for
  ///
  /// Returns the API response containing synced PAN data
  static getSyncedPans({
    required String apiKey,
    required String userId,
  }) async {
    try {
      final dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['x-w-client-id'] = userId;

      final String url =
          '${ApiConstants().getRestApiUrl('portfolio-synced-pans')}?user_id=$userId';

      LogUtil.printLog('Fetching synced PANs for user: $userId');

      final response = await RestApiHandlerData.getData(url, headers);

      LogUtil.printLog('Synced PANs response received');
      return response;
    } catch (e) {
      LogUtil.printLog('Error fetching synced PANs: ${e.toString()}');
      rethrow;
    }
  }
}
