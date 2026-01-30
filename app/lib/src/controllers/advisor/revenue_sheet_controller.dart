import 'dart:async';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/client_revenue_model.dart';
import 'package:core/modules/advisor/models/product_revenue_model.dart';
import 'package:core/modules/advisor/models/revenue_sheet_overview_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueSheetController extends GetxController {
  ApiResponse clientWiseRevenueResponse = ApiResponse();
  List<ClientRevenueModel> clientWiseRevenue = [];

  // Revenue Sheet Overview
  ApiResponse revenueSheetOverviewResponse = ApiResponse();
  RevenueSheetOverviewModel? revenueSheetOverview;
  DateTime overviewDate = DateTime.now();

  // Partner Office
  PartnerOfficeModel? partnerOfficeModel;

  ApiResponse productWiseRevenueResponse = ApiResponse();
  late ProductRevenueUIData productRevenueUIData;

  ScrollController scrollController = ScrollController();
  bool isPaginating = false;
  MetaDataModel clientWiseRevenueDataMeta =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);
  String? payoutId;

  String? apiKey;
  String? agentExternalId;
  Timer? _debounce;
  String? searchText;

  TextEditingController searchController = TextEditingController();

  RevenueSheetController({this.payoutId});

  @override
  void onInit() async {
    scrollController.addListener(handlePagination);
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    agentExternalId = await getAgentExternalId();
    if (payoutId.isNullOrEmpty) getRevenueSheetOverview();
    getClientWiseRevenue();
    if (payoutId.isNullOrEmpty) getProductWiseRevenue();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getClientWiseRevenue() async {
    clientWiseRevenueResponse.state = NetworkState.loading;
    if (!isPaginating) {
      clientWiseRevenueDataMeta.page = 0;
      clientWiseRevenue.clear();
    }
    update([GetxId.clientWiseRevenue]);

    try {
      apiKey ??= await getApiKey();

      final offset = ((clientWiseRevenueDataMeta.page + 1) *
              clientWiseRevenueDataMeta.limit) -
          clientWiseRevenueDataMeta.limit;

      String queryParams = '?';
      queryParams += 'month=${overviewDate.month}';
      queryParams += '&year=${overviewDate.year}';

      if (payoutId.isNotNullOrEmpty) {
        // dont pass date
        queryParams = '?payout_id=$payoutId';
      }

      if (searchText.isNotNullOrEmpty) {
        queryParams += '&customer_search=${searchText}';
      }
      queryParams += '&offset=$offset';
      queryParams += '&limit=${clientWiseRevenueDataMeta.limit}';

      queryParams += await getPartnerOfficeQueryParam();

      final data =
          await AdvisorRepository().getClientWiseRevenue(apiKey!, queryParams);

      if (data['status'] == '200') {
        final apiResponse = WealthyCast.toList<List>(data['response']['data']);
        if (apiResponse.isNotNullOrEmpty) {
          for (final clientRevenueJson in apiResponse) {
            final clientRevenueList = WealthyCast.toList(clientRevenueJson).map(
              (revenueData) {
                return ClientRevenueModel.fromJson(
                    revenueData.entries.first.value);
              },
            ).toList();
            clientWiseRevenue.addAll(clientRevenueList);
          }
        }

        clientWiseRevenueDataMeta.totalCount =
            WealthyCast.toInt(data['response']['total_count']);
        clientWiseRevenueResponse.state = NetworkState.loaded;
      } else {
        clientWiseRevenueResponse.message =
            getErrorMessageFromResponse(data['response']);
        clientWiseRevenueResponse.state = NetworkState.error;
      }
    } catch (error) {
      clientWiseRevenueResponse.message = 'Something went wrong';
      clientWiseRevenueResponse.state = NetworkState.error;
    } finally {
      isPaginating = false;
      update([GetxId.clientWiseRevenue]);
    }
  }

  Future<void> getRevenueSheetOverview() async {
    revenueSheetOverviewResponse.state = NetworkState.loading;
    update([GetxId.overview]);

    try {
      apiKey = await getApiKey();

      String queryParams = '';
      queryParams += '?month=${overviewDate.month}';
      queryParams += '&year=${overviewDate.year}';

      queryParams += await getPartnerOfficeQueryParam();

      final data = await AdvisorRepository()
          .getRevenueSheetOverview(apiKey!, queryParams);

      if (data['status'] == '200') {
        revenueSheetOverview =
            RevenueSheetOverviewModel.fromJson(data['response']['data']);
        revenueSheetOverviewResponse.state = NetworkState.loaded;
      } else {
        revenueSheetOverviewResponse.state = NetworkState.error;
      }
    } catch (error) {
      revenueSheetOverviewResponse.state = NetworkState.error;
    } finally {
      update([GetxId.overview]);
    }
  }

  Future<void> getProductWiseRevenue() async {
    productWiseRevenueResponse.state = NetworkState.loading;
    update([GetxId.productWiseRevenue]);

    try {
      apiKey ??= await getApiKey();

      String queryParams = '?';
      queryParams += 'month=${overviewDate.month}';
      queryParams += '&year=${overviewDate.year}';

      queryParams += await getPartnerOfficeQueryParam();

      final data =
          await AdvisorRepository().getProductWiseRevenue(apiKey!, queryParams);

      if (data['status'] == '200') {
        final productWiseRevenue = WealthyCast.toList(data['response']['data'])
            .map<ProductRevenueModel>(
              (productRevenue) => ProductRevenueModel.fromJson(productRevenue),
            )
            .toList();
        productRevenueUIData = ProductRevenueUIData(productWiseRevenue);
        productWiseRevenueResponse.state = NetworkState.loaded;
      } else {
        productWiseRevenueResponse.message =
            getErrorMessageFromResponse(data['response']);
        productWiseRevenueResponse.state = NetworkState.error;
      }
    } catch (error) {
      productWiseRevenueResponse.message = 'Something went wrong';
      productWiseRevenueResponse.state = NetworkState.error;
    } finally {
      update([GetxId.productWiseRevenue]);
    }
  }

  Future<String> getPartnerOfficeQueryParam() async {
    List<String> requestAgentIds = [];
    if (partnerOfficeModel != null) {
      requestAgentIds = partnerOfficeModel!.agentExternalIds;
    }
    if (requestAgentIds.isNullOrEmpty) {
      agentExternalId ??= await getAgentExternalId();
      requestAgentIds = [agentExternalId ?? ''];
    }
    if (requestAgentIds.isNotNullOrEmpty) {
      return '&request_agent_ids=${requestAgentIds.join(',')}';
    }
    return '';
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    getRevenueSheetOverview();
    getClientWiseRevenue();
    getProductWiseRevenue();
  }

  void updateOverviewDate(DateTime date) {
    overviewDate = date;
    if (payoutId.isNullOrEmpty) getRevenueSheetOverview();
    getClientWiseRevenue();
    if (payoutId.isNullOrEmpty) getProductWiseRevenue();
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      bool isPagesRemaining = (clientWiseRevenueDataMeta.totalCount! /
              (clientWiseRevenueDataMeta.limit *
                  (clientWiseRevenueDataMeta.page + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          clientWiseRevenueResponse.state != NetworkState.loading) {
        clientWiseRevenueDataMeta.page = clientWiseRevenueDataMeta.page + 1;
        isPaginating = true;
        getClientWiseRevenue();
      }
    }
  }

  Future<dynamic> searchRevenueSheet() async {
    clientWiseRevenueResponse.state = NetworkState.loading;
    update([GetxId.clientWiseRevenue]);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (searchText.isNullOrEmpty) {
          clearSearchBar();
          return null;
        }
        getClientWiseRevenue();
      },
    );
  }

  void clearSearchBar() {
    searchText = "";
    searchController.clear();
    update([GetxId.clientWiseRevenue]);
  }
}
