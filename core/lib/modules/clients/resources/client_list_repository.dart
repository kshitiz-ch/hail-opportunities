import 'dart:convert';

import 'package:api_sdk/api_collection/client_api.dart';
import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';

class ClientListRepository {
  Future<dynamic> queryClientData(
      String agentId, bool isPrivileged, bool recentLeads, String apiKey,
      {String? query, int? limit, int? offset, String? requestAgentId}) async {
    try {
      final response = await ClientAPI.queryClientList(
          agentId, isPrivileged, recentLeads, apiKey, query,
          limit: limit, offset: offset, requestAgentId: requestAgentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientLoginDetails(String? userId, String? apiKey) async {
    try {
      final response =
          await ClientAPI.getClientLoginDetails(userId: userId, apiKey: apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientsCount(
    String apiKey,
  ) async {
    try {
      final response = await ClientAPI.getClientsCount(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getEmployeesClientCount(
      String apiKey, String agentExternalId) async {
    try {
      final response =
          await ClientAPI.getEmployeesClientCount(apiKey, agentExternalId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientDetailsByTaxyId(
      String apiKey, String clientId) async {
    try {
      final response =
          await ClientAPI.getClientDetailsByTaxyId(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientDetails({String? clientId, String? apiKey}) async {
    try {
      final response =
          await ClientAPI.getClientDetails(clientId: clientId, apiKey: apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> addClient(
    String apiKey,
    String email,
    bool isEmailUnknown,
    String name,
    String phoneNumber,
    String source,
  ) async {
    try {
      final response = await ClientAPI.addClient(
          apiKey, email, isEmailUnknown, name, phoneNumber, source);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientInvestmentDetails(
      String apiKey, String userId) async {
    try {
      final response =
          await ClientAPI.getClientInvestmentDetails(apiKey, userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getProductInvestmentDetails(
    String apiKey,
    String userId, {
    bool showZeroFolios = false,
    required ClientInvestmentProductType type,
  }) async {
    try {
      final response = await ClientAPI.getProductInvestmentDetails(
          apiKey, userId,
          showZeroFolios: showZeroFolios, type: type);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getClientTrackerValue(String apiKey, String userId) async {
    try {
      final response = await ClientAPI.getClientTrackerValue(apiKey, userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getClientAccountDetails(String apiKey, String userId) async {
    try {
      final response = await CommonAPI.getAccountDetails(apiKey, userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> updateClientPhone(
      String apiKey, String userId, String phoneNumber) async {
    try {
      Map body = {
        "phone_number": phoneNumber,
        "request_type": "CHANGE-LOGIN-PHONE-NUMBER"
      };
      final response = await ClientAPI.updateClientPhone(apiKey, userId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateClientEmail(
      String apiKey, String userId, String email) async {
    try {
      Map body = {"email": email, "request_type": "CHANGE-LOGIN-EMAIL"};
      final response = await ClientAPI.updateClientEmail(apiKey, userId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateClientName(
      String apiKey, String userId, String firstName, String lastName) async {
    try {
      Map body = {"first_name": firstName, "last_name": lastName};
      final response = await ClientAPI.updateClientName(apiKey, userId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateClientMfEmail(
      String apiKey, String userId, String email) async {
    try {
      Map body = {"email": email, "request_type": "CHANGE-MF-EMAIL"};
      final response = await ClientAPI.updateClientEmail(apiKey, userId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> generateClientUpdateLink(
      String apiKey, String userId, String requestType) async {
    try {
      Map body = {"request_type": requestType};
      final response =
          await ClientAPI.generateClientUpdateLink(apiKey, userId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> sendClientEmailVerificationLink(
      String apiKey, String userId) async {
    try {
      Map payload = {
        "data": {
          "user_id": userId,
          "via_link": true,
          "via_otp": false,
        }
      };

      final response =
          await ClientAPI.sendClientEmailVerificationLink(apiKey, payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createBankAccount(
    String apiKey,
    Map body,
    String userID,
  ) async {
    try {
      final response = await CommonAPI.createBankAccount(apiKey, body, userID);

      LogUtil.printPrettyJsonString(
          tag: 'DataUpdateBank/', jsonString: jsonEncode(response.data));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateBankAccount(
    String apiKey,
    Map body,
    String userID,
  ) async {
    try {
      final response = await CommonAPI.updateBankAccount(apiKey, body, userID);

      LogUtil.printPrettyJsonString(
          tag: 'DataBankUpdate/', jsonString: jsonEncode(response.data));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // New family addition feature api
  Future<dynamic> fetchFamilyMembers(String apiKey, String clientID) async {
    try {
      final response = await ClientAPI.fetchFamilyMembers(apiKey, clientID);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // New family addition feature api
  Future<dynamic> fetchClientFamily(String apiKey, String clientID) async {
    try {
      final response = await ClientAPI.fetchClientFamily(apiKey, clientID);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createFamilyMembers(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response =
          await ClientAPI.createFamilyMembers(apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> verifyFamilyMember(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response =
          await ClientAPI.verifyFamilyMember(apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> resendFamilyVerificationOtp(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response = await ClientAPI.resendFamilyVerificationOtp(
          apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> kickFamilyMember(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response =
          await ClientAPI.kickFamilyMember(apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> leaveFamily(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response = await ClientAPI.leaveFamily(apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSIPList(
    String apiKey,
    String clientID,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.getSIPList(
        apiKey,
        clientID,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSIPDetails(
    String apiKey,
    String clientID,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.getSIPDetails(
        apiKey,
        clientID,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSIPOrders(
    String apiKey,
    String clientId,
    String goalId,
  ) async {
    try {
      final response = await ClientAPI.getSIPOrders(apiKey, clientId, goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSIPDetailsV2(
      String apiKey, String clientID, Map<String, dynamic> payload) async {
    try {
      final response =
          await ClientAPI.getSIPDetailsV2(apiKey, clientID, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateSipProposal(
      String apiKey, Map<String, dynamic> body) async {
    try {
      final response = await ClientAPI.updateSipProposal(apiKey, body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientAllocationDetails(
      String apiKey, String clientID, String panNumber) async {
    try {
      final response = await ClientAPI.getClientAllocationDetails(
        apiKey,
        clientID,
        panNumber,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientHoldingDetails(
      String apiKey, String clientID, String panNumber) async {
    try {
      final response = await ClientAPI.getClientHoldingDetails(
        apiKey,
        clientID,
        panNumber,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getUserPortfolioOverview(
      String apiKey, String memberUserId) async {
    try {
      final response =
          await ClientAPI.getUserPortfolioOverview(apiKey, memberUserId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientDetailChangeRequestData(
      String apiKey, Map<dynamic, dynamic> body) async {
    try {
      final response =
          await ClientAPI.getClientDetailChangeRequestData(apiKey, body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientProfileDetails(String apiKey, String userId) async {
    try {
      final response = await ClientAPI.getClientProfileDetails(apiKey, userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientMfTransactions(
      {required String apiKey,
      required String userId,
      String? goalId,
      int limit = 20,
      int offset = 0}) async {
    try {
      final response = await ClientAPI.getClientMfTransactions(
          apiKey: apiKey,
          userId: userId,
          goalId: goalId,
          limit: limit,
          offset: offset);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSchemeCodeMapping() async {
    try {
      final response = await CommonAPI.getSchemeCodeMapping();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getClientTickets(
      String apiKey, String clientID, int offset) async {
    try {
      final response = await ClientAPI.getClientTickets(
        apiKey,
        clientID,
        offset,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientReportTemplates(
      String apiKey, String clientID) async {
    try {
      final response =
          await ClientAPI.getClientReportTemplates(apiKey, clientID);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> sendTrackerSwitchProposal(
      String apiKey, Map<dynamic, dynamic> body) async {
    try {
      final response = await ClientAPI.sendTrackerSwitchProposal(apiKey, body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientReportList({
    required String apiKey,
    required String clientID,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ClientAPI.getClientReportList(
        apiKey: apiKey,
        clientId: clientID,
        payload: payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientReport({
    required String apiKey,
    required String clientID,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ClientAPI.getClientReport(
        apiKey: apiKey,
        clientId: clientID,
        payload: payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createClientReport({
    required String apiKey,
    required String clientID,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ClientAPI.createClientReport(
        apiKey: apiKey,
        clientId: clientID,
        payload: payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> refreshReportLink({
    required String apiKey,
    required String clientID,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ClientAPI.refreshReportLink(
        apiKey: apiKey,
        clientId: clientID,
        payload: payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getStpList(
      String apiKey, String clientId, String goalId) async {
    try {
      final response = await ClientAPI.getStpList(apiKey, clientId, goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSyncedPanInfo(String userId, String apiKey) async {
    try {
      final response = await ClientAPI.getSyncedPanInfo(userId, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getFilterMapping(String apiKey) async {
    try {
      final response = await ClientAPI.getFilterMapping(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
