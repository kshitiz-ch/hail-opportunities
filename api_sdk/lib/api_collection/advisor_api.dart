import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';
import 'package:dio/dio.dart';

class AdvisorAPI {
  static getSipMetrics(String apiKey, List<String> agentExternalIdList) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSipMetrics(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPayouts(String apiKey, {bool isBrokingPayout = false}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.getPayouts(isBrokingPayout: isBrokingPayout);
      return response;
    } catch (e) {
      LogUtil.printLog('payouts error ==> ${e.toString()}');
    }
  }

  static getPartnerNominee(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getPartnerNominee();
      return response;
    } catch (e) {
      LogUtil.printLog('getPartnerNominee error ==> ${e.toString()}');
    }
  }

  static changePartnerDisplayName(
      String apiKey, String agentId, String displayName) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.changePartnerDisplayName(agentId, displayName);
      return response;
    } catch (e) {
      LogUtil.printLog('changePartnerDisplayName error ==> ${e.toString()}');
    }
  }

  static changeReferralCode(
      String apiKey, String agentId, String referralCode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.changeReferralCode(agentId, referralCode);
      return response;
    } catch (e) {
      LogUtil.printLog('changeReferralCode error ==> ${e.toString()}');
    }
  }

  static createPartnerNominee(
      String apiKey, Map<String, dynamic> payload, String agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.createPartnerNominee(agentId, payload);
      return response;
    } catch (e) {
      LogUtil.printLog('createPartnerNominee error ==> ${e.toString()}');
    }
  }

  static getPayoutProductBreakup(String apiKey, String payoutId,
      {bool isBrokingPayout = false}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getPayoutProductBreakup(
        payoutId,
        isBrokingPayout: isBrokingPayout,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('getPayoutProductBreakup error ==> ${e.toString()}');
    }
  }

  static getSipGraphData(
      String apiKey, List<String> agentExternalIdList) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getSipGraphData(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getDailySipCount(
      String apiKey, List<String> agentExternalIdList) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.getDailySipCount(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getSipUserData(
    String apiKey, {
    required List<String> agentExternalIdList,
    int limit = 20,
    int offset = 0,
    List<String>? userIds,
    bool useSipDataV2Api = false,
    required Map<String, dynamic> filters,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    if (userIds?.isNotEmpty ?? false) {
      headers['x-w-client-id'] = userIds?.first ?? '';
    }

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getSipUserData(
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

  static getOfflineSipData(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getOfflineSipData(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static createAgentReport(
      String apiKey, Map<String, dynamic> variables) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.createAgentReport(variables);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static refreshAgentReportLink({
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.refreshAgentReportLink(payload);

      return response;
    } catch (e) {
      LogUtil.printLog("refreshAgentReportLink error ==> ${e.toString()}");
    }
  }

  static getAgentReport(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getAgentReport(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentReportTemplates(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getAgentReportTemplates();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static downloadAgentReport(String apiKey, String reportUrl) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().baseUrl}$reportUrl';

    final response =
        await RestApiHandlerData.getData(apiUrl, headers, isPdf: true);

    return response;
  }

  static getRevenueSheetOverview(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('revenue-sheet')}/overview/$queryParam';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getClientWiseRevenue(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('revenue-sheet')}/clientwise-agg/$queryParam';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getProductWiseRevenue(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('revenue-sheet')}/productwise-agg/$queryParam';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getClientRevenueDetail(
      String apiKey, String queryParam, bool usePartnerOfficeApi) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '';
    if (usePartnerOfficeApi) {
      apiUrl =
          '${ApiConstants().getRestApiUrl('partner-office-revenue-book')}/$queryParam';
    } else {
      apiUrl =
          '${ApiConstants().getRestApiUrl('partner-revenue-book')}/$queryParam';
    }

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getProductTypes(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getProductTypes();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentsWithAssoicateAccess() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/agents-with-associates',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentsWithLimitedAccess() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/agents-limited-access',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAmcSoaList(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().getRestApiUrl('amc-soa-list')}';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSoaFolioList(
    String apiKey,
    String userId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    String apiUrl = '${ApiConstants().getRestApiUrl('soa-folio-list')}';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getQuickActions(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getQuickActions();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static updateQuickActions(
    String apiKey,
    Map<String, dynamic> payload,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.updateQuickActions(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getTicobTransactions(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getTicobTransactions(payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getTicobOpportunities(
      Map<String, dynamic> payload, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getTicobOpportunities(payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getTicobFolioList({
    required String userId,
    required String panNumber,
    required String apiKey,
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getTicobFolioList(
        userId: userId,
        panNumber: panNumber,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static generateTicobForm(
      String apiKey, Map<String, dynamic> payload, String clientId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = ApiConstants().getRestApiUrl('generate-ticob-form');
    headers['x-w-client-id'] = clientId;
    headers['Content-Type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
      apiUrl,
      json.encode(payload),
      headers,
      isPdf: true,
    );

    return response;
  }

  static generateTncPdf(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().getRestApiUrl('tnc')}generate-pdf/';

    final response =
        await RestApiHandlerData.postData(apiUrl, payload, headers);

    return response;
  }

  static uploadTncPdf(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().getRestApiUrl('tnc')}upload-pdf/';

    final response =
        await RestApiHandlerData.postData(apiUrl, payload, headers);

    return response;
  }

  static getNewsletters(String apiKey, String queryParam,
      {CancelToken? cancelToken}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().getRestApiUrl('newsletter')}$queryParam';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
      isUTF8: true,
      cancelToken: cancelToken,
    );

    return response;
  }

  static getNewsletterYears(
    String apiKey,
    String queryParam,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('newsletter')}years/$queryParam';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
      isUTF8: true,
    );

    return response;
  }

  static getNewsletterDetail(String apiKey, String id) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = '${ApiConstants().getRestApiUrl('newsletter')}$id/';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
      isUTF8: true,
    );

    return response;
  }

  static subscribeNewsletter(String apiKey, Map<String, String> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final apiUrl = '${ApiConstants().getRestApiUrl('newsletter-subscribe')}';

    final response =
        await RestApiHandlerData.postData(apiUrl, jsonEncode(payload), headers);

    return response;
  }

  static getPartnerTrackerMetrics(String apiKey, String agentExternalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlHandler.getPartnerTrackerMetrics(agentExternalId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

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

  static getPartnerReferralInfo(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final apiUrl = ApiConstants().getRestApiUrl('partner-referral-info');

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getReferralFaqTerms() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    final apiUrl = '${ApiConstants().advisorWorkerBaseUrl}/referral-data';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getClientBirthdays(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getClientBirthdays();
      return response;
    } catch (e) {
      LogUtil.printLog('getClientBirthdays error ==> ${e.toString()}');
    }
  }

  static callAiAssistant(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.callAiAssistant(payload);
      return response;
    } catch (e) {
      LogUtil.printLog('callAiAssistant error ==> ${e.toString()}');
    }
  }

  static getBrandingDetail(String apiKey,
      {String? lang, bool preview = true}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      String apiUrl = ApiConstants().getRestApiUrl('branding');

      // Add query parameters
      final queryParams = <String>[];
      if (lang != null && lang.isNotEmpty) {
        queryParams.add('lang=$lang');
      }
      queryParams.add('preview=$preview');

      if (queryParams.isNotEmpty) {
        apiUrl += '?${queryParams.join('&')}';
      }

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getBrandingDetail error ==> ${e.toString()}');
    }
  }

  static downloadCalculatorReportPdf(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl = ApiConstants().getRestApiUrl('calculator-report-pdf');

      final response = await RestApiHandlerData.postData(
        apiUrl,
        payload,
        headers,
        isPdf: true,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('downloadCalculatorReportPdf error ==> ${e.toString()}');
    }
  }

  static getPortfolioOpportunities(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl =
          'https://d35234f9430c.ngrok-free.app/api/portfolio/review-opportunities';

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getPortfolioOpportunities error ==> ${e.toString()}');
    }
  }

  static getStagnantSipOpportunities(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl =
          'https://d35234f9430c.ngrok-free.app/api/opportunities/stagnant-sips?limit=10';

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getStagnantSipOpportunities error ==> ${e.toString()}');
    }
  }

  static getStoppedSipOpportunities(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl =
          'https://d35234f9430c.ngrok-free.app/api/opportunities/stopped-sips?limit=10';

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getStoppedSipOpportunities error ==> ${e.toString()}');
    }
  }

  static getInsuranceOpportunities(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl =
          'https://d35234f9430c.ngrok-free.app/api/insurance/opportunities/coverage-gaps';

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getInsuranceOpportunities error ==> ${e.toString()}');
    }
  }

  static getOpportunitiesOverview(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final apiUrl =
          'https://d35234f9430c.ngrok-free.app/api/ai/dashboard-insights/';

      final response = await RestApiHandlerData.getData(apiUrl, headers);
      return response;
    } catch (e) {
      LogUtil.printLog('getOpportunitiesOverview error ==> ${e.toString()}');
    }
  }
}
