import 'dart:convert';

import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:dio/dio.dart';

class StoreRepository {
  Future<dynamic> getUnlistedStocksData(String apiKey) async {
    final response = await StoreAPI.getStoreProducts(
        apiKey, 'category=invest&product_type=unlistedstock');

    return response;
  }

  Future<dynamic> getClientPortfolios(
      String apiKey, String userId, String category) async {
    final response =
        await StoreAPI.fetchClientPortfolio(apiKey, userId, category);

    return response;
  }

  Future<dynamic> getSchemeData(
      String apiKey, String? userId, String wSchemeCodes) async {
    final response = await StoreAPI.getSchemeData(apiKey, userId, wSchemeCodes);

    return response;
  }

  Future<dynamic> getSchemeExitLoadDetails(
      String apiKey, String? userId, String wSchemeCodes) async {
    final response =
        await StoreAPI.getSchemeExitLoadDetails(apiKey, userId, wSchemeCodes);

    return response;
  }

  Future<dynamic> getClientCustomGoalFunds(
      String apiKey, String goalId, String userId) async {
    final response =
        await StoreAPI.getClientCustomGoalFunds(apiKey, userId, goalId);

    return response;
  }

  Future<dynamic> fetchClientGoalAllocations(String apiKey,
      {required String goalId,
      required String userId,
      String? wschemecode}) async {
    final response = await StoreAPI.fetchClientGoalAllocations(
        apiKey, userId, goalId, wschemecode);

    return response;
  }

  Future<dynamic> getGoalSchemesv2(String apiKey,
      {required String goalId,
      required String userId,
      String? wschemecode}) async {
    final response =
        await StoreAPI.getGoalSchemesv2(apiKey, userId, goalId, wschemecode);

    return response;
  }

  Future<dynamic> getFdData(String apiKey) async {
    final response = await StoreAPI.getFDData(apiKey);

    return response;
  }

  Future<dynamic> getFdInterestData(
      String apiKey, Map payload, CancelToken? cancelToken) async {
    try {
      final response =
          await StoreAPI.getFDInterestData(apiKey, payload, cancelToken);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> getCreditCardProposalUrl(String apiKey, Map payload) async {
    final response = await StoreAPI.getCreditCardProposalUrl(apiKey, payload);
    return response;
  }

  Future<dynamic> getCreditCardListingDetail(
      String apiKey, String agentID) async {
    final response = await StoreAPI.getCreditCardListingDetail(apiKey, agentID);
    return response;
  }

  Future<dynamic> getCreditCardSummary(String apiKey, String agentID) async {
    final response = await StoreAPI.getCreditCardSummary(apiKey, agentID);
    return response;
  }

  Future<dynamic> getCreditCardDetail(String apiKey, String externalID) async {
    final response = await StoreAPI.getCreditCardDetail(apiKey, externalID);
    return response;
  }

  Future<dynamic> getCreditCardPromotionalDetails(
      String apiKey, String agentID) async {
    final response =
        await StoreAPI.getCreditCardPromotionalDetails(apiKey, agentID);
    return response;
  }

  Future<dynamic> getCreditCardResumeURL(
      String apiKey, String externalID) async {
    final response = await StoreAPI.getCreditCardResumeURL(apiKey, externalID);
    return response;
  }

  Future<dynamic> getDebentures(String apiKey) async {
    final response = await StoreAPI.getStoreProducts(
        apiKey, 'category=invest&product_type=mld');

    return response;
  }

  Future<dynamic> getMutualFundsData(
    String apiKey, {
    String? productVariant,
  }) async {
    final response = await StoreAPI.getStoreProducts(
      apiKey,
      'category=invest&product_type=mf',
      productVariant: productVariant,
    );

    return response;
  }

  Future<dynamic> getStoreProduct(String apiKey, String category,
      String productType, String productTypeVariant) async {
    final response = await StoreAPI.getStoreProduct(
        apiKey, category, productType, productTypeVariant);

    return response;
  }

  Future<dynamic> getGoalDetails(String apiKey,
      {required String userId, required String goalId}) async {
    final response =
        await StoreAPI.getGoalDetails(apiKey, userId: userId, goalId: goalId);

    return response;
  }

  Future<dynamic> getGoalSummary(String apiKey,
      {required String userId, required String goalId}) async {
    final response =
        await StoreAPI.getGoalSummary(apiKey, userId: userId, goalId: goalId);

    return response;
  }

  Future<dynamic> getGoalOrderCounts(String apiKey,
      {required String userId,
      required String goalId,
      String? wschemecode}) async {
    final response = await StoreAPI.getGoalOrderCounts(apiKey,
        userId: userId, goalId: goalId, wschemecode: wschemecode);

    return response;
  }

  Future<dynamic> getPopularProducts(String apiKey, String page) async {
    final response = await StoreAPI.getPopularProducts(apiKey, page);

    return response;
  }

  Future<dynamic> getWealthySelectScreeners(String apiKey) async {
    final response = await StoreAPI.getWealthySelectScreeners(apiKey);

    return response;
  }

  Future<dynamic> getAmcList(String apiKey) async {
    final response = await StoreAPI.getAmcList(apiKey);

    return response;
  }

  Future<dynamic> getCuratedFundScreeners(String apiKey) async {
    final response = await StoreAPI.getCuratedFundScreeners(apiKey);

    return response;
  }

  Future<dynamic> getCuratedFundsList(String apiKey, String uri) async {
    final response = await StoreAPI.getCuratedFundsList(apiKey, uri);

    return response;
  }

  Future<dynamic> getSchemeList(String apiKey, String queryParam) async {
    final response = await StoreAPI.getSchemeList(apiKey, queryParam);

    return response;
  }

  Future<dynamic> getCategoryAvgReturns(String apiKey, String classCode) async {
    final response = await StoreAPI.getCategoryAvgReturns(apiKey, classCode);

    return response;
  }

  Future<dynamic> getWealthySelectFunds(String apiKey, String uri) async {
    final response = await StoreAPI.getWealthySelectFunds(apiKey, uri);

    return response;
  }

  Future<dynamic> getTopSellingFunds(String apiKey) async {
    final response = await StoreAPI.getTopSellingFunds(apiKey);

    return response;
  }

  Future<dynamic> searchStoreProducts(String apiKey, String query) async {
    final response = await StoreAPI.searchStoreProducts(apiKey, query);

    return response;
  }

  Future<dynamic> searchMutualFunds(
      {String? apiKey,
      String? query,
      Map? filters,
      String? sorting,
      int limit = 20,
      int offset = 0}) async {
    final response = await StoreAPI.searchMutualFunds(
      apiKey: apiKey,
      query: query,
      filters: filters,
      sorting: sorting,
      limit: limit,
      offset: offset,
    );

    return response;
  }

  Future<dynamic> getInsurancesCatData(String apiKey) async {
    final response = await StoreAPI.getStoreProducts(apiKey, 'category=insure');

    return response;
  }

  Future<dynamic> getInsuranceData(String apiKey, String productVariant) async {
    final response = await StoreAPI.getInsuranceProduct(
        apiKey, 'category=Insure',
        productVariant: productVariant);

    return response;
  }

  Future<dynamic> getInsuranceBannerData() async {
    final response = await StoreAPI.getInsuranceBanners();

    return response;
  }

  Future<dynamic> addProposals(int id, String userId, String productTypeVariant,
      String apiKey, Map extraDataMap,
      {bool useProposalV2 = false, bool isSip = false}) async {
    final data = {
      'agent_id': id,
      'user_id': userId,
      'product_type_variant': productTypeVariant,
    };
    var response;
    if (useProposalV2) {
      response = await StoreAPI.addProposalsV2(
          json.encode(extraDataMap), apiKey,
          isSip: isSip);
    } else {
      response = await StoreAPI.addProposals(
          json.encode({...data, ...extraDataMap}), apiKey);
    }

    // LogUtil()
    //     .printPrettyJsonString(tag: 'Props/', jsonString: jsonEncode(response));
    return response;
  }

  Future<dynamic> findSimilarProposals(int id, String userId,
      String productTypeVariant, String apiKey, Map extraDataMap) async {
    final insure = {
      'agent_id': id,
      'user_id': userId,
      'product_type_variant': productTypeVariant,
    };

    final response = await StoreAPI.findSimilarProposals(
        json.encode({...insure, ...extraDataMap}), apiKey);

    // LogUtil()
    //     .printPrettyJsonString(tag: 'Props/', jsonString: jsonEncode(response));
    return response;
  }

  Future<dynamic> getDematAccounts(String userId, String apiKey) async {
    final response = await CommonAPI.getDematAccounts(userId, apiKey);

    return response;
  }

  Future<dynamic> createDematAccount(
      String userId, Map body, String apiKey) async {
    final response = await CommonAPI.createDematAccount(userId, body, apiKey);

    return response;
  }

  Future<dynamic> createPreIpoProposal(Map body, String apiKey) async {
    final response = await StoreAPI.addProposals(json.encode(body), apiKey);

    return response;
  }

  Future<dynamic> updatePreIpoProposal(
      Map body, String proposalId, String apiKey) async {
    final response = await CommonAPI.updateProposalData(
        apiKey, proposalId, json.encode(body));

    return response;
  }

  Future<dynamic> getTrackerRequest(String apiKey) async {
    final response = await StoreAPI.getTrackerRequest(apiKey);

    return response;
  }

  Future<dynamic> sendTrackerRequest(Map body, String apiKey) async {
    final response =
        await StoreAPI.sendTrackerRequest(json.encode(body), apiKey);

    return response;
  }

  Future<dynamic> getCreateProposalUrl(String apiKey, agentId, payload) async {
    try {
      final response =
          await CommonAPI.getProposalUrl(apiKey, json.encode(payload));

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> createFixedDepositProposal(
      String apiKey, agentId, payload) async {
    try {
      final response = await StoreAPI.createFixedDepositProposal(
          apiKey, json.encode(payload));

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getPortfolioChartData(
    String subType,
    int from, {
    int step = 1,
  }) async {
    try {
      final response =
          await StoreAPI.getPortfolioChartData(subType, from, step);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getMfChartData(String apiKey, String wSchemeCode, int years,
      {String? navType}) async {
    try {
      final response = await StoreAPI.getMfChartData(apiKey, wSchemeCode, years,
          navType: navType);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getMfChartDatav2(String apiKey, String queryParam) async {
    try {
      final response = await StoreAPI.getMfChartDatav2(apiKey, queryParam);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getPMSProductData(
    String apiKey,
  ) async {
    try {
      final response = await StoreAPI.getStoreProducts(
          apiKey, 'category=invest&product_type=pms');
      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getFundFilters() async {
    try {
      final response = await StoreAPI.getFundFilters();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getFundSortingOptions() async {
    try {
      final response = await StoreAPI.getFundSortingOptions();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> fetchGoalSubtype(
      String apiKey, String userId, String goalId) async {
    try {
      final response = await StoreAPI.fetchGoalSubtype(apiKey, userId, goalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getInsuranceProductDetail(String productVariant) async {
    try {
      final response = await StoreAPI.getInsuranceProductDetail(productVariant);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> fetchFDBanners() async {
    try {
      final response = await StoreAPI.fetchFDBanners();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSchemeDetails(
      {required String apiKey, required String wSchemeCodes}) async {
    try {
      final response = await StoreAPI.getSchemeDetails(apiKey, wSchemeCodes);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSipDays() async {
    try {
      final response = await CommonAPI.getSipDays();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> auditDematConsent(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await CommonAPI.auditDematConsent(apiKey, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getStoreDematDetails(String apiKey) async {
    try {
      final response = await StoreAPI.getStoreDematDetails(apiKey);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> createDematProposal(String apiKey, payload) async {
    try {
      final response =
          await StoreAPI.createDematProposal(apiKey, json.encode(payload));

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getDematBanners() async {
    final response = await StoreAPI.getDematBanners();

    return response;
  }

  Future<dynamic> getGoalSchemeOrders(apiKey,
      {required String goalId,
      required String userId,
      String? wschemecode,
      int limit = 20,
      int offset = 0}) async {
    try {
      final response = await StoreAPI.getGoalSchemeOrders(apiKey,
          userId: userId,
          goalId: goalId,
          wschemecode: wschemecode,
          limit: limit,
          offset: offset);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getFundReturn(
    String apiKey,
    String queryParam,
    String? wpc,
    String? wschemeCode,
  ) async {
    try {
      final response = await StoreAPI.getFundReturn(
        apiKey,
        queryParam,
        wpc,
        wschemeCode,
      );

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getBasketReturn(
      String apiKey, Map<String, dynamic> payload) async {
    try {
      final response = await StoreAPI.getBasketReturn(apiKey, payload);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getBasketMaxStartNavDate(
      String apiKey, String queryParam) async {
    try {
      final response =
          await StoreAPI.getBasketMaxStartNavDate(apiKey, queryParam);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getSipStartMonth(
    String apiKey,
    String queryParam,
    String userId,
  ) async {
    try {
      final response = await StoreAPI.getSipStartMonth(
        apiKey,
        queryParam,
        userId,
      );

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getSipStartEndDate(
    String apiKey,
    String queryParam,
    String userId,
  ) async {
    try {
      final response = await StoreAPI.getSipStartEndDate(
        apiKey,
        queryParam,
        userId,
      );

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getSchemeCategoryBreakup(String apiKey, String wpc) async {
    final response = await StoreAPI.getSchemeCategoryBreakup(apiKey, wpc);

    return response;
  }

  Future<dynamic> getSchemeFundBreakup(String apiKey, String wpc) async {
    final response = await StoreAPI.getSchemeFundBreakup(apiKey, wpc);

    return response;
  }

  Future<dynamic> getSchemeSectorBreakup(String apiKey, String wpc) async {
    final response = await StoreAPI.getSchemeSectorBreakup(apiKey, wpc);

    return response;
  }

  Future<dynamic> getCreditRatingBreakup(String apiKey, String wpc) async {
    final response = await StoreAPI.getCreditRatingBreakup(apiKey, wpc);

    return response;
  }

  Future<dynamic> getNfoDetails(String apiKey, String isin) async {
    final response = await StoreAPI.getNfoDetails(apiKey, isin);

    return response;
  }

  Future<dynamic> getSchemeStockHoldings(String apiKey, String wpc,
      {int limit = 10, int offset = 0}) async {
    final response =
        await StoreAPI.getSchemeStockHoldings(apiKey, wpc, limit, offset);

    return response;
  }

  Future<dynamic> getMfIndices(String apiKey) async {
    final response = await StoreAPI.getMfIndices(apiKey);

    return response;
  }

  Future<dynamic> getBenchmarkReturn(String apiKey, String thirdPartyId) async {
    final response = await StoreAPI.getBenchmarkReturn(apiKey, thirdPartyId);

    return response;
  }

  Future<dynamic> getMfIndexDetails(String apiKey, String indexId) async {
    final response = await StoreAPI.getMfIndexDetails(apiKey, indexId);

    return response;
  }

  Future<dynamic> getUserFolios(String apiKey, String? userId) async {
    final response = await StoreAPI.getUserFolios(apiKey, userId);

    return response;
  }

  Future<dynamic> getSifProducts(String apiKey, String queryParam) async {
    final response = await StoreAPI.getSifProducts(apiKey, queryParam);

    return response;
  }

  Future<dynamic> getSifDetail(String apiKey, String isin) async {
    final response = await StoreAPI.getSifDetail(apiKey, isin);

    return response;
  }
}
