import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/offline_sip_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class SipBookController extends GetxController {
  List<String> tabs = ['SIP Book Summary', 'SIP Book'];
  TabController? tabController;

  List<SipBookTabType> sipBookTabs = SipBookTabType.values;
  SipBookTabType selectedSipBookTab = SipBookTabType.Online;

  ApiResponse sipMetricResponse = ApiResponse();
  SipAggregateModel? sipAggregate;

  ApiResponse sipGraphResponse = ApiResponse();
  List<MonthSipModel> activeSipMonthlyData = [];
  List<MonthSipModel> successfulSipMonthlyData = [];

  ApiResponse dailySipCountResponse = ApiResponse();
  List<DailySipModel> dailySipCountData = [];
  SwiperController swiperController = SwiperController();

  ApiResponse onlineSipResponse = ApiResponse();
  ApiResponse offlineSipResponse = ApiResponse();

  List<SipUserDataModel> sipUserData = [];
  List<OfflineSipModel> offlineSipData = [];

  MetaDataModel sipListingMetaData =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);

  // Sip filter online
  SipUserDataFilter? savedFilter;
  SipUserDataFilter? tempFilter;

  ScrollController scrollController = ScrollController();
  bool isPaginating = false;

  PartnerOfficeModel? partnerOfficeModel;

  TextEditingController searchController = TextEditingController();
  Client? selectedClient;

  SipGraphType sipGraphSelected = SipGraphType.SipBook;

  String? goalId;
  String? wschemecode;

  final bool fromSipBookScreen;

  SipBookController({
    this.selectedClient,
    this.goalId,
    this.wschemecode,
    this.fromSipBookScreen = true,
  });

  @override
  void onInit() {
    if (fromSipBookScreen) {
      fetchSipApis();
    } else {
      getSipUserData();
    }

    scrollController.addListener(handlePagination);

    super.onInit();
  }

  void onSipTabChange(SipBookTabType tab) {
    if (tab != selectedSipBookTab) {
      selectedSipBookTab = tab;
      update(['sip-tab']);
      resetFilters();
    }
  }

  void fetchSipApis() {
    getSipMetrics();
    getSipGraphData();
    getDailySipCount();
    fetchSipListing();
  }

  void fetchSipListing() {
    if (fromSipBookScreen) {
      if (selectedSipBookTab == SipBookTabType.Online) {
        getSipUserData();
      } else if (selectedSipBookTab == SipBookTabType.Offline) {
        getOfflineSipData();
      } else if (selectedSipBookTab == SipBookTabType.Transactions) {
        update();
      }
    } else {
      getSipUserData();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    tabController?.dispose();
    super.dispose();
  }

  String get partnerFirstName {
    String name = 'Your';
    String? partnerDisplayName = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().advisorOverviewModel?.agent?.displayName
        : null;

    if (partnerDisplayName != null && partnerDisplayName.isNotEmpty) {
      name = '${partnerDisplayName.split(" ")[0]}\'s';
    }
    return name;
  }

  ApiResponse get currentResponse {
    if (selectedSipBookTab == SipBookTabType.Online) {
      return onlineSipResponse;
    } else if (selectedSipBookTab == SipBookTabType.Offline) {
      return offlineSipResponse;
    }

    return onlineSipResponse;
  }

  Future<void> getSipMetrics() async {
    sipMetricResponse.state = NetworkState.loading;
    update(['sip-metric']);

    try {
      String apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response =
          await AdvisorRepository().getSipMetrics(apiKey, agentExternalIdList);

      if (!response.hasException) {
        sipMetricResponse.state = NetworkState.loaded;
        sipAggregate = SipAggregateModel.fromJson(response.data!["taxy"]);
      } else {
        sipMetricResponse.state = NetworkState.error;
        sipMetricResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      sipMetricResponse.state = NetworkState.error;
      sipMetricResponse.message = genericErrorMessage;
    } finally {
      update(['sip-metric']);
    }
  }

  Future<void> getSipGraphData() async {
    sipGraphResponse.state = NetworkState.loading;
    activeSipMonthlyData.clear();
    successfulSipMonthlyData.clear();
    update(['sip-graph']);

    try {
      String apiKey = await getApiKey() ?? '';
      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response = await AdvisorRepository()
          .getSipGraphData(apiKey, agentExternalIdList);

      if (!response.hasException) {
        final activeSipMonthlyJson = WealthyCast.toList(
          response.data!["taxy"]["sipGraphData"]["activeSipVsMonth"],
        );
        activeSipMonthlyData =
            activeSipMonthlyJson.map((e) => MonthSipModel.fromJson(e)).toList();

        final successfulSipMonthlyJson = WealthyCast.toList(
          response.data!["taxy"]["sipGraphData"]
              ["successfulNavAllocationAmountVsMonth"],
        );
        successfulSipMonthlyData = successfulSipMonthlyJson
            .map((e) => MonthSipModel.fromJson(e))
            .toList();

        sipGraphResponse.state = NetworkState.loaded;
      } else {
        sipGraphResponse.state = NetworkState.error;
        sipGraphResponse.message = response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      sipGraphResponse.state = NetworkState.error;
      sipGraphResponse.message = genericErrorMessage;
    } finally {
      update(['sip-graph']);
    }
  }

  Future<void> getDailySipCount() async {
    dailySipCountResponse.state = NetworkState.loading;
    dailySipCountData.clear();
    update(['daily-sip']);

    try {
      String apiKey = await getApiKey() ?? '';
      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response = await AdvisorRepository()
          .getDailySipCount(apiKey, agentExternalIdList);

      if (!response.hasException) {
        Map<String, dynamic> dailySipCountJson =
            response.data!["taxy"]["sipDayWiseActiveCount"];
        dailySipCountData = dailySipCountJson.entries.map(
          (sipCountJson) {
            final dailySipModel = DailySipModel.fromJson(sipCountJson.value);
            dailySipModel.day = WealthyCast.toInt(sipCountJson.key);
            return dailySipModel;
          },
        ).toList();

        dailySipCountResponse.state = NetworkState.loaded;
      } else {
        dailySipCountResponse.state = NetworkState.error;
        dailySipCountResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      dailySipCountResponse.state = NetworkState.error;
      dailySipCountResponse.message = genericErrorMessage;
    } finally {
      update(['daily-sip']);
    }
  }

  Future<void> getSipUserData() async {
    // fetch online sip
    onlineSipResponse.state = NetworkState.loading;
    if (!isPaginating) {
      sipUserData.clear();
      sipListingMetaData.page = 0;
    }

    update();

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> filters = {};

      if (savedFilter != null) {
        SipUserDataFilter.values.forEach((sipFilter) {
          if (savedFilter == sipFilter) {
            filters[sipFilter.name] = true;
          } else {
            filters[sipFilter.name] = false;
          }
        });
      }

      if (goalId.isNotNullOrEmpty) {
        filters["goalId"] = goalId;
      }
      if (wschemecode.isNotNullOrEmpty) {
        filters["wschemecodes"] = [wschemecode ?? ''];
      }

      List<String> agentExternalIdList = await getAgentExternalIdList();

      int offset = ((sipListingMetaData.page + 1) * sipListingMetaData.limit) -
          sipListingMetaData.limit;
      QueryResult response = await AdvisorRepository().getSipUserData(
        apiKey,
        agentExternalIdList: agentExternalIdList,
        filters: filters,
        userIds:
            selectedClient?.taxyID != null ? [selectedClient!.taxyID!] : [],
        limit: sipListingMetaData.limit,
        useSipDataV2Api: fromSipBookScreen == false,
        offset: offset,
      );

      if (response.hasException) {
        onlineSipResponse.state = NetworkState.error;
        onlineSipResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        List sipUserDataJson = response.data!["taxy"]["sipUserData"]["sipData"];
        sipUserDataJson.forEach((e) {
          final sipModel = SipUserDataModel.fromJson(e);
          if (sipModel.agentExternalId.isNullOrEmpty) {
            // for showing sip transactions in sip detail view as past sips instead of sipsV2
            // we need agentExternalId
            // for fromSipBookScreen == true we are getting agentExternalId
            // for fromSipBookScreen == false ie useSipDataV2Api == true
            // we are not getting agentExternalId from api its null
            // so updating agentExternalId from shared Preferences
            sipModel.agentExternalId = agentExternalIdList.first;
          }
          sipUserData.add(sipModel);
        });

        sipListingMetaData.totalCount =
            response.data!["taxy"]["sipUserData"]["count"] ?? 0;

        onlineSipResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      onlineSipResponse.state = NetworkState.error;
      onlineSipResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getOfflineSipData() async {
    // fetch online sip
    offlineSipResponse.state = NetworkState.loading;
    if (!isPaginating) {
      offlineSipData.clear();
      sipListingMetaData.page = 0;
    }

    update();

    try {
      final apiKey = await getApiKey() ?? '';

      int offset = ((sipListingMetaData.page + 1) * sipListingMetaData.limit) -
          sipListingMetaData.limit;

      final payload = {
        'agentExternalIdList': await getAgentExternalIdList(),
        'offset': offset,
        'limit': sipListingMetaData.limit,
        if (selectedClient != null) 'searchText': selectedClient?.crn,
      };

      QueryResult response =
          await AdvisorRepository().getOfflineSipData(apiKey, payload);

      if (response.hasException) {
        offlineSipResponse.state = NetworkState.error;
        offlineSipResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        final offlineSipApiData = WealthyCast.toList(response.data!["taxy"]
            ["partnerMfOfflineSips"]["userOfflineSipTransactionData"]);
        offlineSipApiData.forEach((e) {
          offlineSipData.add(OfflineSipModel.fromJson(e));
        });

        sipListingMetaData.totalCount =
            response.data!["taxy"]["partnerMfOfflineSips"]["count"] ?? 0;

        offlineSipResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      offlineSipResponse.state = NetworkState.error;
      offlineSipResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<List<Client>> getSearchClients(String query) async {
    List<Client> clients = [];
    try {
      update([GetxId.searchClient]);

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      final response = await ClientListRepository().queryClientData(
          agentId.toString(), false, false, apiKey!,
          query: query, requestAgentId: '', limit: 5, offset: 0);

      if (!response.hasException) {
        ClientListModel clientSearchList =
            ClientListModel.fromJson(response.data['hydra']);
        clients = clientSearchList.clients!;
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }

    return clients;
  }

  Future<List<String>> getAgentExternalIdList() async {
    List<String> agentExternalIds = [];
    if (partnerOfficeModel != null) {
      agentExternalIds = partnerOfficeModel!.agentExternalIds;
    }
    if (agentExternalIds.isNullOrEmpty) {
      agentExternalIds = [await getAgentExternalId() ?? ''];
    }
    return agentExternalIds;
  }

  void saveFilters() {
    savedFilter = tempFilter;
    sipListingMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);

    fetchSipListing();
  }

  void resetFilters() {
    savedFilter = null;
    tempFilter = null;
    sipListingMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);

    fetchSipListing();
  }

  void selectClient(Client client) {
    if (selectedClient?.taxyID != client.taxyID) {
      searchController.clear();
      selectedClient = client;
      if (selectedSipBookTab == SipBookTabType.Transactions) {
        final controller = Get.find<TransactionController>();
        controller.selectedClient = selectedClient;
        controller.getTransactions();
      }
      fetchSipListing();
    }
  }

  void resetSelectClient() {
    searchController.clear();
    selectedClient = null;
    if (selectedSipBookTab == SipBookTabType.Transactions) {
      final controller = Get.find<TransactionController>();
      controller.selectedClient = selectedClient;
      controller.getTransactions();
    }
    fetchSipListing();
  }

  void resetParams() {
    searchController.clear();
    selectedClient = null;
    sipListingMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
    savedFilter = null;
    tempFilter = null;
    updateSipGraphType(SipGraphType.SipBook);
  }

  void updateSipGraphType(SipGraphType newSipGraphType) {
    sipGraphSelected = newSipGraphType;
    update(['sip-graph']);
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    resetParams();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
    fetchSipApis();
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      bool isPagesRemaining = (sipListingMetaData.totalCount! /
              (sipListingMetaData.limit * (sipListingMetaData.page + 1))) >
          1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          currentResponse.state != NetworkState.loading) {
        sipListingMetaData.page = sipListingMetaData.page + 1;
        isPaginating = true;
        fetchSipListing();
      }
    }
  }

  void updateGraphIndex(int index) {
    swiperController.index = index;
    update(['daily-sip']);
  }
}
