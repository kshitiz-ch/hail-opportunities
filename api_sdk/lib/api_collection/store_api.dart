import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';
import 'package:dio/dio.dart';

class StoreAPI {
  static getSchemeData(
      String apiKey, String? userId, String wSchemeCodes) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    if (userId != null) {
      headers['x-w-client-id'] = userId;
    }
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getSchemeData(wSchemeCodes);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getSchemeExitLoadDetails(
      String apiKey, String? userId, String wSchemeCodes) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    if (userId != null) {
      headers['x-w-client-id'] = userId;
    }
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.getSchemeExitLoadDetails(wSchemeCodes);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getInsuranceProduct(String apiKey, String category,
      {String? productVariant}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String queryParams = '?$category';
    if (productVariant != null && productVariant.isNotEmpty) {
      queryParams += '&product_type_variant=$productVariant';
    }

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('store-products-old')}$queryParams',
        headers);
    return response;
  }

  static getSchemeDetails(String apiKey, String schemeCodes) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      String queryParams = '?scheme_codes=$schemeCodes';

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().getRestApiUrl('metahouse-mf-funds')}$queryParams',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getInsuranceBanners() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/insurance-banners', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getStoreProducts(String apiKey, String category,
      {String? productVariant}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String queryParams = '?$category';
    if (productVariant != null && productVariant.isNotEmpty) {
      queryParams += '&product_type_variant=$productVariant';
    }

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('store-products-v2')}$queryParams',
        headers);
    return response;
  }

  static fetchClientPortfolio(
      String apiKey, String userId, String category) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.fetchClientPortfolio(userId, category);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static fetchGoalSubtype(String apiKey, String userId, String goalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.fetchGoalSubtype(userId, goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getClientCustomGoalFunds(
      String apiKey, String userId, String goalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.getClientCustomGoalFunds(userId, goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static fetchClientGoalAllocations(
      String apiKey, String userId, String goalId, String? wschemecode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.fetchClientGoalAllocations(
          userId, goalId, wschemecode);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getGoalSchemesv2(
      String apiKey, String userId, String goalId, String? wschemecode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    print(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.getGoalSchemesv2(goalId, wschemecode);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  static getStoreProduct(String apiKey, String category, String productType,
      String productTypeVariant) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('store-products-v1')}?category=$category&product_type=$productType&product_type_variant=$productTypeVariant',
        headers);
    return response;
  }

  static getGoalDetails(String apiKey,
      {required String userId, required String goalId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.getGoalDetails(userId: userId, goalId: goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getGoalSummary(String apiKey,
      {required String userId, required String goalId}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    print(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlQlHandler.getGoalSummary(userId: userId, goalId: goalId);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  static getGoalOrderCounts(String apiKey,
      {required String userId,
      required String goalId,
      String? wschemecode}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getGoalOrderCounts(
          userId: userId, goalId: goalId, wschemecode: wschemecode);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPopularProducts(String apiKey, String page) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('store-products-v3')}?page=$page',
        headers);
    return response;
  }

  static searchStoreProducts(String apiKey, String query) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('search-store')}?q=$query';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
    );
    return response;
  }

  static searchMutualFunds(
      {String? apiKey,
      String? query,
      Map? filters,
      String? sorting,
      int limit = 20,
      int offset = 0}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String queryParams = '?q=$query&limit=$limit&offset=$offset';
    if (filters != null && filters.isNotEmpty) {
      queryParams += '&filters=${jsonEncode(filters)}';
    }

    if (sorting != null && sorting.isNotEmpty) {
      queryParams += '&$sorting';
    }

    final response = await RestApiHandlerData.getData(
      '${ApiConstants().getRestApiUrl('mf-search')}$queryParams',
      headers,
    );
    return response;
  }

  static addProposals(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('proposals');
    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('proposals'), body, headers);

    return response;
  }

  static addProposalsV2(dynamic body, String apiKey,
      {bool isSip = false}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String url;

    if (isSip) {
      url =
          "${ApiConstants().getRestApiUrl('quinjet-proposals')}mf/v1/sip-setup/";
    } else {
      url =
          "${ApiConstants().getRestApiUrl('quinjet-proposals')}mf/v0/lumpsum/";
    }

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(url, body, headers);

    return response;
  }

  static findSimilarProposals(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('proposals')}similar-proposals/',
        body,
        headers);

    return response;
  }

  static getTrackerRequest(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('tracker-request')}', headers);
    return response;
  }

  static sendTrackerRequest(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('tracker-request')}request-mfc-sync/',
        body,
        headers);
    return response;
  }

  static createFixedDepositProposal(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('proposals')}', body, headers);
    return response;
  }

  static getPortfolioChartData(
    String subType,
    int from,
    int step,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('chart-data')}?subtype=$subType&step=$step&from=$from',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getMfIndices(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        "https://fundsapi.wealthy.in/market/v0/indices/?category=ci";

    try {
      final response = await RestApiHandlerData.getData(
        apiUrl,
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getBenchmarkReturn(String apiKey, String thirdPartyId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/benchmarks/$thirdPartyId/returns/';

    try {
      final response = await RestApiHandlerData.getData(
        apiUrl,
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getMfChartData(String apiKey, String wSchemeCode, int years,
      {String? navType}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getMfChartData(wSchemeCode, years,
          navType: navType);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getMfChartDatav2(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        "https://fundsapi.wealthy.in/market/v0/instruments/historical/$queryParam";

    try {
      final response = await RestApiHandlerData.getData(
        apiUrl,
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getFundFilters() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/fund-filters-v2', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getFundSortingOptions() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/fund-sorting', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getInsuranceProductDetail(String productVariant) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      String queryParams = '';
      if (productVariant.isNotEmpty) {
        queryParams = '?variant=$productVariant';
      }

      final response = await RestApiHandlerData.getData(
        '${ApiConstants().advisorWorkerBaseUrl}/insurance-details$queryParams',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getFDData(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('fd-data');
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getFDInterestData(
      String apiKey, Map payload, CancelToken? cancelToken) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('fd-interest-data');
    final response = await RestApiHandlerData.postData(
      url,
      payload,
      headers,
      cancelToken: cancelToken,
    );
    return response;
  }

  static getCreditCardProposalUrl(String apiKey, Map payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('credit-card-proposal');
    final response =
        await RestApiHandlerData.postData(url, jsonEncode(payload), headers);
    return response;
  }

  static getCreditCardListingDetail(String apiKey, String agentID) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('credit-card-detail')}?agent_id=$agentID';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getCreditCardSummary(String apiKey, String agentID) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('credit-card-summary')}?agent_id=$agentID';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getCreditCardDetail(String apiKey, String externalID) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('credit-card-detail')}$externalID/';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getCreditCardPromotionalDetails(String apiKey, String agentID) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('credit-card-promotions')}?agent_id=$agentID';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static getCreditCardResumeURL(String apiKey, String externalID) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('credit-card-resume')}$externalID';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static fetchFDBanners() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
        '${ApiConstants().advisorWorkerBaseUrl}/fd-banners',
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getStoreDematDetails(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('store-demat')}';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static createDematProposal(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";

    String apiUrl = '${ApiConstants().getRestApiUrl('store-demat')}/proposal';
    final response = await RestApiHandlerData.postData(apiUrl, body, headers);
    return response;
  }

  static getDematBanners() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/demat-creatives', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getGoalSchemeOrders(String apiKey,
      {required String goalId,
      required String userId,
      String? wschemecode,
      int limit = 20,
      int offset = 0}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler clientInvestments =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await clientInvestments.getGoalSchemeOrders(userId,
          goalId: goalId,
          wschemecode: wschemecode,
          limit: limit,
          offset: offset);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getWealthySelectScreeners(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/screeners/?category=wealthy-select-funds';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getWealthySelectFunds(String apiKey, String uri) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('mf-lobby')}$uri';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getCategoryAvgReturns(String apiKey, String classCode) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('metahouse-open')}/$classCode/category-returns/';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getAmcList(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/amcs/';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getCuratedFundScreeners(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        'https://fundsapi.wealthy.in/market/v0/screeners/?category=mf-lobby';

    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getCuratedFundsList(String apiKey, String uri) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = 'https://fundsapi.wealthy.in/$uri';

    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getSchemeList(String apiKey, String queryParams) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/$queryParams';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getTopSellingFunds(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/screeners/?category=top-selling-funds';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getNfoDetails(String apiKey, String isin) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/nfos/$isin/';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getSipStartMonth(
    String apiKey,
    String queryParams,
    String userId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    String apiUrl =
        '${ApiConstants().getRestApiUrl('sip-start-months-v2')}/$queryParams';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getSipStartEndDate(
    String apiKey,
    String queryParams,
    String userId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    String apiUrl =
        '${ApiConstants().getRestApiUrl('sip-start-and-end-date-v2')}/$queryParams';
    final response = await RestApiHandlerData.getData(apiUrl, headers);
    return response;
  }

  static getFundReturn(
    String apiKey,
    String queryParam,
    String? wpc,
    String? wschemeCode,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = ApiConstants().getRestApiUrl('metahouse-open');

    if (wpc != null && wpc.isNotEmpty) {
      apiUrl += "/wpc/$wpc/";
    } else {
      apiUrl += "/wschemecode/$wschemeCode/";
    }
    apiUrl += "calculate-returns/?$queryParam";

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getBasketReturn(String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = 'application/json';

    String apiUrl =
        "https://fundsapi.wealthy.in/api/v0/mf-funds/basket-returns/calculate/";

    final response = await RestApiHandlerData.postData(
        apiUrl, json.encode(payload), headers);

    return response;
  }

  static getBasketMaxStartNavDate(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        "https://fundsapi.wealthy.in/api/v0/mf-funds/max-starting-nav-date/$queryParam";

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSchemeCategoryBreakup(String apiKey, String wpc) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/${wpc}/holdings/category-breakup/';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getMfIndexDetails(String apiKey, String indexId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        "https://fundsapi.wealthy.in/market/v0/stocks/exchange-token/${indexId}/fundamentals/";
    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSchemeFundBreakup(String apiKey, String wpc) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/${wpc}/holdings/fund-breakup/';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSchemeSectorBreakup(String apiKey, String wpc) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/${wpc}/holdings/sector-breakup/';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getCreditRatingBreakup(String apiKey, String wpc) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/${wpc}/holdings/credit-rating-breakup/';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSchemeStockHoldings(
      String apiKey, String wpc, int limit, int offset) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('mf-lobby')}/v0/schemes/$wpc/holdings/?ordering=-holding_percentage&limit=$limit&offset=$offset';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getUserFolios(String apiKey, String? userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    if (userId != null) {
      headers['x-w-client-id'] = userId;
    }

    String apiUrl = '${ApiConstants().getRestApiUrl('taxy')}get-user-folios/';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSifProducts(String apiKey, String queryParam) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final url = '${ApiConstants().getRestApiUrl('sif-products')}$queryParam';

    final response = await RestApiHandlerData.getData(
      url,
      headers,
    );
    return response;
  }

  static getSifDetail(String apiKey, String isin) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final url = '${ApiConstants().getRestApiUrl('sif-products')}$isin/';

    final response = await RestApiHandlerData.getData(
      url,
      headers,
    );
    return response;
  }
}

// const fetchCategoryBreakup = (wpc) => {
//   const finalURL = `https://api.buildwealth.in/metahouse/partners/v0/schemes/${wpc}/holdings/category-breakup/`;
//   const config = {
//     headers: {
//       Authorization: "5c8d2168bdd9ad1180ac088eb338f629410495f4"
//     }
//   };
//   return storeAxios.get(finalURL, config);
// };

// const fetchSectorBreakup = (wpc) => {
//   const finalURL = `https://api.buildwealth.in/metahouse/partners/v0/schemes/${wpc}/holdings/sector-breakup/`;
//   const config = {
//     headers: {
//       Authorization: "5c8d2168bdd9ad1180ac088eb338f629410495f4"
//     }
//   };
//   return storeAxios.get(finalURL, config);
// };

// const fetchFundBreakup = (wpc) => {
//   const finalURL = `https://api.buildwealth.in/metahouse/partners/v0/schemes/${wpc}/holdings/fund-breakup/`;
//   const config = {
//     headers: {
//       Authorization: "5c8d2168bdd9ad1180ac088eb338f629410495f4"
//     }
//   };
//   return storeAxios.get(finalURL, config);
// };
