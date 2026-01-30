import 'package:api_sdk/api_collection/client_api.dart';
import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/log_util.dart';

class ClientProfileRepository {
  Future<dynamic> createMfProfile(
      String apiKey, String clientId, Map<String, dynamic> body) async {
    try {
      final response = await ClientAPI.createMfProfile(apiKey, clientId, body);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> deleteClient(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.deleteClient(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createUserNominee(
      String apiKey, String clientId, Map<String, dynamic> body) async {
    try {
      final response =
          await ClientAPI.createUserNominee(apiKey, body, clientId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateUserNominee(String apiKey, Map<String, dynamic> body,
      {required String clientId, required String nomineeId}) async {
    try {
      final response = await ClientAPI.updateUserNominee(apiKey, body,
          nomineeId: nomineeId, clientId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createMfNominees(
      String apiKey, String clientId, List<Map<String, dynamic>> body) async {
    try {
      final response =
          await ClientAPI.createMfNominees(apiKey, body, clientId: clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getMandates(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.getMandates(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getUserMandateMeta(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.getUserMandateMeta(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientKraStatusCheck(
      String apiKey, String clientId) async {
    try {
      final response =
          await ClientAPI.getClientKraStatusCheck(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> setDefaultBankAccount(String apiKey,
      {required String clientId, required String bankId}) async {
    try {
      final response = await ClientAPI.setDefaultBankAccount(apiKey,
          clientId: clientId, bankId: bankId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientNominees(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.getClientNominees(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientBankAccounts(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.getClientBankAccounts(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientBrokingBankAccounts(
      String apiKey, String clientId) async {
    try {
      final response =
          await ClientAPI.getClientBrokingBankAccounts(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientInvestmentStatus(
      {required String apiKey, required String clientId}) async {
    try {
      final response =
          await ClientAPI.getClientInvestmentStatus(apiKey, clientId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAddressFromPin(String pin) async {
    try {
      final response = await CommonAPI.getAddressFromPin(pin);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getClientWealthyDematDetail(
      String apiKey, String clientID) async {
    try {
      final response =
          await ClientAPI.getClientWealthyDematDetail(apiKey, clientID);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientAddressDetail(String apiKey, String clientID,
      {String? addressId}) async {
    try {
      final response = await ClientAPI.getClientAddressDetail(apiKey, clientID,
          addressId: addressId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> addClientAddress(
    String apiKey,
    String clientID,
    Map<dynamic, dynamic> body,
  ) async {
    try {
      final response = await ClientAPI.addClientAddress(apiKey, clientID, body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateClientAddress(
    String apiKey,
    String clientID,
    Map<dynamic, dynamic> body,
  ) async {
    try {
      final response =
          await ClientAPI.updateClientAddress(apiKey, clientID, body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> deleteClientAddress(
    String apiKey,
    String clientID,
    String id,
  ) async {
    try {
      final response =
          await ClientAPI.deleteClientAddress(apiKey, clientID, id);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getDematAccounts(String userId, String apiKey) async {
    try {
      final response = await CommonAPI.getDematAccounts(userId, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createDematAccount(
      String userId, Map body, String apiKey) async {
    try {
      final response = await CommonAPI.createDematAccount(userId, body, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> editDematAccount(
      String userId, Map body, String apiKey) async {
    try {
      final response = await ClientAPI.editDematAccount(userId, body, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientMandates({
    required String apiKey,
    required String userId,
    String sipMetaExternalId = '',
    bool fetchConfirmedOnly = false,
  }) async {
    try {
      final response = await ClientAPI.getClientMandates(
        apiKey: apiKey,
        userId: userId,
        sipMetaExternalId: sipMetaExternalId,
        fetchConfirmedOnly: fetchConfirmedOnly,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> shareMandateProposal(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await ClientAPI.shareMandateProposal(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getMandateOptions(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await ClientAPI.getMandateOptions(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getUserProfileViewData(String apiKey, String clientId) async {
    try {
      final response = await ClientAPI.getUserProfileViewData(apiKey, clientId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientOnboardingDetails(
    String apiKey,
    String clientId,
    String onboardingProduct,
  ) async {
    try {
      final response = await ClientAPI.getClientOnboardingDetails(
        apiKey,
        clientId,
        onboardingProduct,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> requestProfileUpdate(
    String apiKey,
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response =
          await ClientAPI.requestProfileUpdate(apiKey, clientId, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> requestVerifiedProfileUpdate(
      String apiKey, String clientId) async {
    try {
      final response =
          await ClientAPI.requestVerifiedProfileUpdate(apiKey, clientId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSyncedPans(String apiKey, String clientId) async {
    try {
      final response =
          await ClientAPI.getSyncedPans(apiKey: apiKey, userId: clientId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
