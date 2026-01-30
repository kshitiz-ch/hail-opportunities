import 'package:api_sdk/api_collection/my_team_api.dart';

class MyTeamRepository {
  Future<dynamic> createPartnerOffice({String? name, String? apiKey}) async {
    final response =
        await MyTeamAPI.createPartnerOffice(name: name, apiKey: apiKey);

    return response;
  }

  Future<dynamic> getEmployees(
      {String? search,
      String? designation,
      String? apiKey,
      required int limit,
      required int offset}) async {
    final response = await MyTeamAPI.getEmployees(
      search: search,
      designation: designation,
      limit: limit,
      offset: offset,
      apiKey: apiKey,
    );

    return response;
  }

  Future<dynamic> getPartnersDailyMetric(
      {List<String>? agentExternalIdList,
      required String date,
      String? apiKey}) async {
    final response = await MyTeamAPI.getPartnersDailyMetric(
      agentExternalIdList: agentExternalIdList,
      date: date,
      apiKey: apiKey,
    );

    return response;
  }

  Future<dynamic> addExistingAgentPartnerOfficeEmployee(
      {String? phoneNumber,
      String? designation,
      required String apiKey}) async {
    Map<String, dynamic> payload = {
      "designation": designation,
      "phoneNumber": phoneNumber
    };
    final response =
        await MyTeamAPI.addExistingAgentPartnerOfficeEmployee(payload, apiKey);

    return response;
  }

  Future<dynamic> addPartnerOfficeEmployee(
      {String? email,
      String? firstName,
      String? lastName,
      String? phoneNumber,
      String? designation,
      required String apiKey}) async {
    Map<String, dynamic> payload = {
      "designation": designation,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber
    };

    final response = await MyTeamAPI.addPartnerOfficeEmployee(payload, apiKey);

    return response;
  }

  Future<dynamic> assignUnassignClient({
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    final response = await MyTeamAPI.assignUnassignClient(payload, apiKey);
    return response;
  }

  Future<dynamic> renameOffice({
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    final response = await MyTeamAPI.renameOffice(payload, apiKey);
    return response;
  }

  Future<dynamic> removeEmployee({
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    final response = await MyTeamAPI.removeEmployee(payload, apiKey);
    return response;
  }

  Future<dynamic> verifyNewAgentLeadOtp(
      {String? leadId,
      String? otp,
      String? ownerAgentId,
      String? designation,
      required String apiKey}) async {
    Map<String, dynamic> payload = {
      "otp": otp,
      "lead_id": leadId,
      "designation": designation?.toLowerCase(),
      "owner_agent_id": ownerAgentId,
    };

    final response = await MyTeamAPI.verifyNewAgentLeadOtp(payload, apiKey);

    return response;
  }

  Future<dynamic> resendAgentLeadOtp(
      {String? leadId, required String apiKey}) async {
    Map<String, dynamic> payload = {
      "lead_id": leadId,
    };

    final response = await MyTeamAPI.resendAgentLeadOtp(payload, apiKey);

    return response;
  }

  Future<dynamic> validateAndAddEmployee({
    String? otp,
    String? ownerAgentId,
    String? phoneNumber,
    required String apiKey,
  }) async {
    Map<String, dynamic> payload = {
      "otp": otp,
      "owner_agent_id": ownerAgentId,
      "phone_number": phoneNumber
    };

    final response = await MyTeamAPI.validateAndAddEmployee(payload, apiKey);

    return response;
  }

  Future<dynamic> validateAndAddAssociate({
    String? otp,
    String? ownerAgentId,
    String? phoneNumber,
    required String apiKey,
  }) async {
    Map<String, dynamic> payload = {
      "otp": otp,
      "owner_agent_id": ownerAgentId,
      "phone_number": phoneNumber
    };

    final response = await MyTeamAPI.validateAndAddAssociate(payload, apiKey);

    return response;
  }
}
