import 'package:api_sdk/api_collection/advisor_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:dio/dio.dart';

class AdvisorRepository {
  Future<dynamic> getSipMetrics(
      String apiKey, List<String> agentExternalIdList) async {
    try {
      final response =
          await AdvisorAPI.getSipMetrics(apiKey, agentExternalIdList);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPayouts(
    String apiKey, {
    bool isBrokingPayout = false,
  }) async {
    try {
      final response = await AdvisorAPI.getPayouts(
        apiKey,
        isBrokingPayout: isBrokingPayout,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPayoutProductBreakup(
    String apiKey,
    String payoutId, {
    bool isBrokingPayout = false,
  }) async {
    try {
      final response = await AdvisorAPI.getPayoutProductBreakup(
        apiKey,
        payoutId,
        isBrokingPayout: isBrokingPayout,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSipGraphData(
      String apiKey, List<String> agentExternalIdList) async {
    try {
      final response =
          await AdvisorAPI.getSipGraphData(apiKey, agentExternalIdList);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getDailySipCount(
      String apiKey, List<String> agentExternalIdList) async {
    try {
      final response =
          await AdvisorAPI.getDailySipCount(apiKey, agentExternalIdList);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSipUserData(
    String apiKey, {
    required List<String> agentExternalIdList,
    int limit = 20,
    int offset = 0,
    List<String>? userIds,
    bool useSipDataV2Api = false,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await AdvisorAPI.getSipUserData(
        apiKey,
        agentExternalIdList: agentExternalIdList,
        limit: limit,
        offset: offset,
        userIds: userIds,
        useSipDataV2Api: useSipDataV2Api,
        filters: filters,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getOfflineSipData(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.getOfflineSipData(apiKey, payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerNominee(String apiKey) async {
    try {
      final response = await AdvisorAPI.getPartnerNominee(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> changePartnerDisplayName(
      String apiKey, String agentId, String displayName) async {
    try {
      final response = await AdvisorAPI.changePartnerDisplayName(
          apiKey, agentId, displayName);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> changeReferralCode(
      String apiKey, String agentId, String referralCode) async {
    try {
      final response =
          await AdvisorAPI.changeReferralCode(apiKey, agentId, referralCode);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createPartnerNominee(
      String apiKey, Map<String, dynamic> payload, String agentId) async {
    try {
      final response =
          await AdvisorAPI.createPartnerNominee(apiKey, payload, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createAgentReport(
      String apiKey, Map<String, dynamic> variables) async {
    try {
      final response = await AdvisorAPI.createAgentReport(apiKey, variables);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> refreshAgentReportLink({
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await AdvisorAPI.refreshAgentReportLink(
        apiKey: apiKey,
        payload: payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> downloadAgentReport(String apiKey, String reportUrl) async {
    try {
      final response = await AdvisorAPI.downloadAgentReport(apiKey, reportUrl);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentReport(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.getAgentReport(apiKey, payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentReportTemplates(String apiKey) async {
    try {
      final response = await AdvisorAPI.getAgentReportTemplates(apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRevenueSheetOverview(
      String apiKey, String queryParam) async {
    try {
      final response =
          await AdvisorAPI.getRevenueSheetOverview(apiKey, queryParam);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientWiseRevenue(String apiKey, String queryParam) async {
    try {
      final response =
          await AdvisorAPI.getClientWiseRevenue(apiKey, queryParam);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getProductWiseRevenue(
      String apiKey, String queryParam) async {
    try {
      final response =
          await AdvisorAPI.getProductWiseRevenue(apiKey, queryParam);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientRevenueDetail(
      String apiKey, String queryParam, bool usePartnerOfficeApi) async {
    try {
      final response = await AdvisorAPI.getClientRevenueDetail(
        apiKey,
        queryParam,
        usePartnerOfficeApi,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getProductTypes(String apiKey) async {
    try {
      final response = await AdvisorAPI.getProductTypes(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentsWithAssoicateAccess() async {
    try {
      final response = await AdvisorAPI.getAgentsWithAssoicateAccess();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAgentsWithLimitedAccess() async {
    try {
      final response = await AdvisorAPI.getAgentsWithLimitedAccess();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAmcSoaList(String apiKey) async {
    try {
      final response = await AdvisorAPI.getAmcSoaList(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSoaFolioList(
    String apiKey,
    String userId,
  ) async {
    try {
      final response = await AdvisorAPI.getSoaFolioList(apiKey, userId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateQuickActions(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.updateQuickActions(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getQuickActions(String apiKey) async {
    try {
      final response = await AdvisorAPI.getQuickActions(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getTicobTransactions(
    Map<String, dynamic> payload,
    String apiKey,
  ) async {
    try {
      final response = await AdvisorAPI.getTicobTransactions(payload, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getTicobOpportunities(
    Map<String, dynamic> payload,
    String apiKey,
  ) async {
    try {
      final response = await AdvisorAPI.getTicobOpportunities(payload, apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getTicobFolioList({
    required String userId,
    required String panNumber,
    required String apiKey,
  }) async {
    try {
      final response = await AdvisorAPI.getTicobFolioList(
        userId: userId,
        panNumber: panNumber,
        apiKey: apiKey,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> generateTicobForm(
    Map<String, dynamic> payload,
    String apiKey,
    String clientId,
  ) async {
    try {
      final response = await AdvisorAPI.generateTicobForm(
        apiKey,
        payload,
        clientId,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> generateTncPdf(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.generateTncPdf(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> uploadTncPdf(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.uploadTncPdf(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getNewsletters(String apiKey, String queryParam,
      {CancelToken? cancelToken}) async {
    try {
      final response = await AdvisorAPI.getNewsletters(
        apiKey,
        queryParam,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      throw e;
    }
  }

  Future<dynamic> getNewsletterYears(
    String apiKey,
    String queryParam,
  ) async {
    try {
      final response = await AdvisorAPI.getNewsletterYears(
        apiKey,
        queryParam,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      throw e;
    }
  }

  Future<dynamic> getNewsletterDetail(String apiKey, String id) async {
    try {
      final response = await AdvisorAPI.getNewsletterDetail(apiKey, id);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> subscribeNewsletter(
      String apiKey, Map<String, String> payload) async {
    try {
      final response = await AdvisorAPI.subscribeNewsletter(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerTrackerMetrics(
      String apiKey, String agentExternalId) async {
    try {
      final response =
          await AdvisorAPI.getPartnerTrackerMetrics(apiKey, agentExternalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getWealthyAiUrl(String apiKey, {String? question}) async {
    try {
      final response = await AdvisorAPI.getWealthyAiUrl(
        apiKey,
        question: question,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerReferralInfo(String apiKey) async {
    try {
      final response = await AdvisorAPI.getPartnerReferralInfo(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getReferralFaqTerms() async {
    try {
      final response = await AdvisorAPI.getReferralFaqTerms();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getClientBirthdays(String apiKey) async {
    try {
      final response = await AdvisorAPI.getClientBirthdays(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> callAiAssistant(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await AdvisorAPI.callAiAssistant(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getBrandingDetail(String apiKey,
      {String? lang, bool preview = true}) async {
    try {
      final response = await AdvisorAPI.getBrandingDetail(apiKey,
          lang: lang, preview: preview);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> downloadCalculatorReportPdf(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response =
          await AdvisorAPI.downloadCalculatorReportPdf(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPortfolioOpportunities(String apiKey) async {
    try {
      final response = await AdvisorAPI.getPortfolioOpportunities(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getStagnantSipOpportunities(String apiKey) async {
    try {
      final response = await AdvisorAPI.getStagnantSipOpportunities(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getStoppedSipOpportunities(String apiKey) async {
    try {
      final response = await AdvisorAPI.getStoppedSipOpportunities(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getInsuranceOpportunities(String apiKey) async {
    try {
      final response = await AdvisorAPI.getInsuranceOpportunities(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getOpportunitiesOverview(String apiKey) async {
    try {
      final response = await AdvisorAPI.getOpportunitiesOverview(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
