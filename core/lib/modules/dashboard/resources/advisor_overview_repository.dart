import 'dart:convert';

import 'package:api_sdk/api_collection/advisor_overview_api.dart';
import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:core/modules/dashboard/models/kyc/initiate_partner_kyc_model.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';

class AdvisorOverviewRepository {
  Future<dynamic> getAdvisorOverview(int month, int year, String apiKey) async {
    try {
      final response =
          await AdvisorOverviewAPI.getAdvisorOverview(year, month, apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerAumOverview(String apiKey,
      {String agentExternalId = '',
      List<String> agentExternalIdList = const []}) async {
    try {
      final response = await AdvisorOverviewAPI.getPartnerAumOverview(apiKey,
          agentExternalId: agentExternalId,
          agentExternalIdList: agentExternalIdList);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerAumAggregate(String apiKey,
      {String agentExternalId = '',
      List<String> agentExternalIdList = const []}) async {
    try {
      final response = await AdvisorOverviewAPI.getPartnerAumAggregate(apiKey,
          agentExternalId: agentExternalId,
          agentExternalIdList: agentExternalIdList);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentDesignation(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.getAgentDesignation(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRevenueData(
      {String? apiKey, int? agentId, int? month, int? year}) async {
    final response = await AdvisorOverviewAPI.getRevenueData(
      apiKey: apiKey,
      agentId: agentId,
      year: year,
      month: month,
    );

    return response;
  }

  Future<dynamic> verifyGst(String apiKey, Map<String, dynamic> payload) async {
    final response = await AdvisorOverviewAPI.verifyGst(apiKey, payload);

    return response;
  }

  Future<dynamic> saveGst(String apiKey, Map<String, dynamic> payload) async {
    final response = await AdvisorOverviewAPI.saveGst(apiKey, payload);

    return response;
  }

  Future<dynamic> updatePartnerDetails(
      String apiKey, String updateField) async {
    try {
      final response =
          await AdvisorOverviewAPI.updatePartnerDetails(apiKey, updateField);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getActiveSipCount(
      String apiKey, List<String> agentExternalIdList) async {
    try {
      final response = await AdvisorOverviewAPI.getActiveSipCount(
          apiKey, agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentSegment(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.getAgentSegment(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> initiateKyc(String apiKey, String pan, String email,
      bool isAadharLinked, String dob, String panUsageType) async {
    try {
      final response = await AdvisorOverviewAPI.initiateKyc(
        apiKey,
        pan,
        email,
        isAadharLinked,
        dob,
        panUsageType,
      );
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        return response.exception.graphqlErrors[0]?.message ??
            "Something went wrong";
      } else {
        final result = InitiatePartnerKycModel.fromJson(
            json.decode(jsonEncode(response.data['initiatePartnerKyc'])));
        return result;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> checkARNStatus(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.checkPartnerARN(apiKey);
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        return response.exception.graphqlErrors[0]?.message ??
            "Something went wrong";
      } else {
        final result = PartnerArnModel.fromJson(
            json.decode(jsonEncode(response.data['hydra']['partnerArn'])));
        return result;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> attachEUIN(
      String apiKey, String externalId, String euin) async {
    try {
      final response =
          await AdvisorOverviewAPI.attachEUIN(apiKey, externalId, euin);
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        return response.exception.graphqlErrors[0]?.message ??
            "Something went wrong";
      } else {
        final result = PartnerArnModel.fromJson(json.decode(jsonEncode(
            response.data['partnerArnSelection']['partnerArnNode'])));
        return result;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getAdvisorContent() async {
    try {
      final response = await AdvisorOverviewAPI.getAdvisorContent();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getDashboardContent() async {
    try {
      final response = await AdvisorOverviewAPI.getDashboardContent();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getAdvisorVideos({String? playlistId}) async {
    try {
      final response = await AdvisorOverviewAPI.getAdvisorVideos(playlistId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getStories() async {
    try {
      final response = await AdvisorOverviewAPI.getStories();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getHomeProducts() async {
    try {
      final response = await AdvisorOverviewAPI.getHomeProducts();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> searchParnterArn(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.searchPartnerArn(apiKey);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> getAgentEmpanelmentDetails(String apiKey) async {
    try {
      final response =
          await AdvisorOverviewAPI.getAgentEmpanelmentDetails(apiKey);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> getAgentEmpanelmentAddress(String apiKey) async {
    try {
      final response =
          await AdvisorOverviewAPI.getAgentEmpanelmentAddress(apiKey);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> storeEmpanelmentAddress(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response =
          await AdvisorOverviewAPI.storeEmpanelmentAddress(apiKey, payload);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> validateEmpanelment(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response =
          await AdvisorOverviewAPI.validateEmpanelment(apiKey, payload);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> payEmpanelmentFee(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.payEmpanelmentFee(apiKey);

      return response;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<dynamic> triggerDigioWebhook(body) async {
    try {
      final response = await AdvisorOverviewAPI.triggerDigioWebhook(body);
      return response;
    } catch (error) {
      return 'Something went wrong';
    }
  }

  Future<dynamic> deletePartnerRequest(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.deletePartnerRequest(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getDeletePartnerDetails(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.getDeletePartnerDetails(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> cancelDeletePartnerRequest(
      String apiKey, String externalId) async {
    try {
      final response = await AdvisorOverviewAPI.cancelDeletePartnerRequest(
          apiKey, externalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getProductVideos(String product) async {
    try {
      final response = await CommonAPI.getProductVideos(product);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getDataUpdatedAt(String content) async {
    try {
      final response = await CommonAPI.getDataUpdatedAt(content);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getVisitingCardBrochure(
      {required String apiKey,
      required String agentExternalId,
      required String templateName}) async {
    try {
      final response = await AdvisorOverviewAPI.getVisitingCardBrochure(
          apiKey, agentExternalId, templateName);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> initiateKycSubFlow(String apiKey, String subFlowType) async {
    try {
      final response =
          await AdvisorOverviewAPI.initiateKycSubFlow(apiKey, subFlowType);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getProfilePhoto(String apiKey) async {
    try {
      final response = await AdvisorOverviewAPI.getProfilePhoto(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> uploadProfilePhoto(String apiKey, String filePath) async {
    try {
      final response = await AdvisorOverviewAPI.uploadProfilePhoto(
        apiKey,
        filePath,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
