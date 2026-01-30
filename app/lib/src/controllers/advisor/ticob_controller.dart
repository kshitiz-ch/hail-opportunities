import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/advisor/models/amc_model.dart';
import 'package:core/modules/advisor/models/ticob_folio_model.dart';
import 'package:core/modules/advisor/models/ticob_transaction_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/synced_pan_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class TicobController extends GetxController {
  TabController? tabController;
  final tabs = ['Opportunities', 'Transactions'];

  ApiResponse ticobTransactionResponse = ApiResponse();
  List<TicobTransactionModel> ticobTransactionList = [];

  ApiResponse ticobOpportunityResponse = ApiResponse();
  List<Client> ticobOpportunityList = [];

  ApiResponse syncedPanResponse = ApiResponse();
  List<SyncedPanModel> syncedPanInfo = [];

  ApiResponse ticobFolioResponse = ApiResponse();
  TicobFolioListing? ticobFolios;
  List<TicobFolioModel> folioBasket = [];

  bool get includeAllInBasket =>
      folioBasket.length == ticobFolios!.ticobRegularFolioList.length;

  String? apiKey;

  ApiResponse ticobFormResponse = ApiResponse();

  ScrollController scrollController = ScrollController();

  bool isPaginating = false;
  MetaDataModel ticobMetaData =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);

  TextEditingController searchController = TextEditingController();
  String? searchText;
  Timer? _debounce;

  PartnerOfficeModel? partnerOfficeModel;

  final cobOptions = {
    CobType.Tracker:
        'Choose from clients who have an external mutual fund tracker synced, then select a folio to generate the Change of Broker form',
    CobType.Manual:
        'Select any client and manually enter the folio number to generate the Change of Broker form'
  };

  CobType? selectedCobOption;

  Map<String, Map> allTransactionFilter = {};
  Map<String, List> savedTransactionFilter = {};
  Map<String, List> tempTransactionFilter = {};
  String? selectedFilterType;

  List<AmcModel> amcList = [];
  List<AmcModel> filteredAmcList = [];
  ApiResponse amcResponse = ApiResponse();

  Client? selectedClient;
  SyncedPanModel? selectedPan;
  TextEditingController folioInputController = TextEditingController();
  AmcModel? selectedAmc;

  Uint8List? cobFormDocByte;

  bool get isTransactionTabSelected =>
      tabs[tabController?.index ?? 0] == 'Transactions';

  @override
  void onInit() async {
    super.onInit();
    apiKey = await getApiKey();
    getAmcList();
    fetchData();
    scrollController.addListener(() {
      handlePagination();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getTicobTransactions() async {
    ticobTransactionResponse.state = NetworkState.loading;
    if (!isPaginating) {
      ticobMetaData.page = 0;
      ticobTransactionList.clear();
    }

    update();

    try {
      apiKey ??= await getApiKey() ?? '';

      final offset = ((ticobMetaData.page + 1) * ticobMetaData.limit) -
          ticobMetaData.limit;
      final filterPayload = getFilterPayload();

      final payload = {
        'agentExternalIdList': await getAgentExternalIdList(),
        'offset': offset,
        'limit': ticobMetaData.limit,
        'orderBy': 'post_date', // 'created_at,
        if (searchText.isNotNullOrEmpty) 'searchText': searchText,
        if (filterPayload.isNotEmpty) 'filters': jsonEncode(getFilterPayload()),
      };

      QueryResult response =
          await AdvisorRepository().getTicobTransactions(payload, apiKey!);

      if (response.hasException) {
        ticobTransactionResponse.state = NetworkState.error;
        ticobTransactionResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        final ticobTransactions = WealthyCast.toList(response.data!["taxy"]
            ["userMfTicobTransactions"]["userTicobTransactionData"]);

        ticobTransactionList.addAll(
          ticobTransactions
              .map((json) => TicobTransactionModel.fromJson(json))
              .toList(),
        );

        ticobMetaData.totalCount = WealthyCast.toInt(
                response.data!["taxy"]["userMfTicobTransactions"]["count"]) ??
            0;
        ticobTransactionResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      ticobTransactionResponse.state = NetworkState.error;
      ticobTransactionResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> generateTicobForm({bool fromFolioScreen = false}) async {
    ticobFormResponse.state = NetworkState.loading;
    update();

    try {
      apiKey ??= await getApiKey() ?? '';

      Map<String, dynamic> payload = {
        'request_date':
            DateFormat('yyyy-MM-dd').format(DateTime.now()), // "2024-07-30",
        'user_data': folioBasket.map(
          (folioData) {
            return {
              "pan_number": fromFolioScreen
                  ? selectedPan?.pan ?? '-'
                  : selectedClient?.panNumber ?? '-',
              "folio_number": folioData.folioNumber ?? '',
              "amc_code": folioData.amcCode ?? '',
              "amount": folioData.currentValue?.toStringAsFixed(3) ?? '0',
              "client_name": fromFolioScreen
                  ? selectedPan?.name ?? ''
                  : selectedClient?.name ?? ''
            };
          },
        ).toList(),
      };

      final response = await AdvisorRepository().generateTicobForm(
        payload,
        apiKey!,
        selectedClient!.taxyID!,
      );

      if (response['status'] == '200') {
        ticobFormResponse.state = NetworkState.loaded;
        cobFormDocByte = response["response"];
      } else {
        ticobFormResponse.message =
            getErrorMessageFromResponse(response['response']);
        ticobFormResponse.state = NetworkState.error;
      }
    } catch (error) {
      ticobFormResponse.state = NetworkState.error;
      ticobFormResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getAmcList() async {
    amcResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey();

      final data = await AdvisorRepository().getAmcSoaList(apiKey!);

      if (data['status'] == '200') {
        amcList = WealthyCast.toList(data['response'])
            .map((amcJson) => AmcModel.fromJson(amcJson))
            .toList();

        amcResponse.state = NetworkState.loaded;
      } else {
        amcResponse.message = getErrorMessageFromResponse(data['response']);
        amcResponse.state = NetworkState.error;
      }
    } catch (error) {
      amcResponse.message = 'Something went wrong';
      amcResponse.state = NetworkState.error;
    } finally {
      filteredAmcList = List.from(amcList);
      updateFilter();
    }
  }

  Future<void> getTicobOpportunities() async {
    ticobOpportunityResponse.state = NetworkState.loading;
    if (!isPaginating) {
      ticobMetaData.page = 0;
      ticobOpportunityList.clear();
    }

    update();

    try {
      apiKey ??= await getApiKey() ?? '';

      final offset = ((ticobMetaData.page + 1) * ticobMetaData.limit) -
          ticobMetaData.limit;

      // filter
      // =50000 --> equals 50k
      // +50000 --> greater than =50k
      // -50000 --> less than =50k
      final filter = '+1'; // greater than =1

      final payload = {
        'requestAgentId': (await getAgentExternalIdList()).join(','),
        'offset': offset,
        'limit': ticobMetaData.limit,
        if (searchText.isNotNullOrEmpty) 'q': searchText,
        'trakCobOpportunityValueFilter': filter,
      };

      QueryResult response =
          await AdvisorRepository().getTicobOpportunities(payload, apiKey!);

      if (response.hasException) {
        ticobOpportunityResponse.state = NetworkState.error;
        ticobOpportunityResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        final ticobOpportunities =
            WealthyCast.toList(response.data!["hydra"]["clients"]);

        ticobOpportunityList.addAll(
          ticobOpportunities.map((json) => Client.fromJson(json)).toList(),
        );

        ticobMetaData.totalCount =
            WealthyCast.toInt(response.data!["hydra"]["customerCountV2"]) ?? 0;
        ticobOpportunityResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      ticobOpportunityResponse.state = NetworkState.error;
      ticobOpportunityResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getSyncedPanInfo() async {
    syncedPanResponse.state = NetworkState.loading;

    update();

    try {
      apiKey ??= await getApiKey() ?? '';

      QueryResult response = await ClientListRepository().getSyncedPanInfo(
        selectedClient?.taxyID ?? '',
        apiKey!,
      );

      if (response.hasException) {
        syncedPanResponse.state = NetworkState.error;
        syncedPanResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        syncedPanInfo =
            WealthyCast.toList(response.data!["phaser"]["wsyncPansInfo"])
                .map(
                  (panData) => SyncedPanModel.fromJson(panData),
                )
                .toList();
        syncedPanResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      syncedPanResponse.state = NetworkState.error;
      syncedPanResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getTicobFolioList() async {
    ticobFolioResponse.state = NetworkState.loading;
    update();

    try {
      apiKey ??= await getApiKey() ?? '';

      QueryResult response = await AdvisorRepository().getTicobFolioList(
        apiKey: apiKey!,
        userId: selectedClient?.taxyID ?? '',
        panNumber: selectedPan?.pan ?? '',
      );

      if (response.hasException) {
        ticobFolioResponse.state = NetworkState.error;
        ticobFolioResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        ticobFolios = TicobFolioListing.fromJson(response.data!["phaser"]);
        ticobFolioResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      ticobFolioResponse.state = NetworkState.error;
      ticobFolioResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  void updateFilter() {
    if (amcResponse.state == NetworkState.loaded) {
      allTransactionFilter = {
        'AMC': Map.fromEntries(
          amcList.map((e) => MapEntry(e.amc.toTitleCase(), e.amcCode)).toList(),
        ),
        'Processed Date': Map.fromEntries(
          getLastSixMonthsDate()
              .map((e) => MapEntry(DateFormat('MMM yyyy').format(e), e))
              .toList()
              .reversed,
        ),
      };
      tempTransactionFilter = {'AMC': [], 'Processed Date': []};
      savedTransactionFilter = {'AMC': [], 'Processed Date': []};
      selectedFilterType = 'AMC';
    }
    update();
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

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      bool isPagesRemaining = (ticobMetaData.totalCount! /
              (ticobMetaData.limit * (ticobMetaData.page + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          ticobTransactionResponse.state != NetworkState.loading) {
        ticobMetaData.page = ticobMetaData.page + 1;
        isPaginating = true;
        fetchData();
      }
    }
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
    fetchData();
  }

  Map<String, List> getFilterPayload() {
    final filterPayload = <String, List>{};
    final allAmcMap = allTransactionFilter['AMC'];
    final selectedAmcList = savedTransactionFilter['AMC']?.map(
      (amcName) {
        final amcCode = allAmcMap?[amcName].toString();
        return amcCode;
      },
    ).toList();
    final allDateMap = allTransactionFilter['Processed Date'];
    final selectedDateList = savedTransactionFilter['Processed Date']?.map(
      (date) {
        final formattedDate = DateFormat('MM-yyyy').format(allDateMap?[date]);
        return formattedDate;
      },
    ).toList();

    if (selectedAmcList.isNotNullOrEmpty) {
      filterPayload['amc__in'] = selectedAmcList!;
    }
    if (selectedDateList.isNotNullOrEmpty) {
      filterPayload['post_date__in'] = selectedDateList!;
    }
    return filterPayload;
  }

  void clearSearchBar() {
    searchText = "";
    searchController.clear();
    update();
  }

  void resetParams() {
    ticobMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
    clearSearchBar();
    clearFilter();
  }

  void fetchData() {
    if (isTransactionTabSelected) {
      getTicobTransactions();
    } else {
      getTicobOpportunities();
    }
  }

  void onTabChange() {
    resetParams();
    fetchData();
  }

  Future<dynamic> search() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (searchText.isNullOrEmpty) {
          clearSearchBar();
          return null;
        }
        fetchData();
      },
    );
  }

  void updateSelectedCobOption(CobType option) {
    if (selectedCobOption != option) {
      selectedCobOption = option;
      update();
    }
  }

  void updateFilterValues(String value, bool isAdding) {
    if (isAdding) {
      tempTransactionFilter[selectedFilterType]?.add(value);
    } else {
      tempTransactionFilter[selectedFilterType]?.remove(value);
    }
    update();
  }

  void clearFilter() {
    tempTransactionFilter = {'AMC': [], 'Processed Date': []};
    savedTransactionFilter = {'AMC': [], 'Processed Date': []};
    selectedFilterType = 'AMC';

    // reset amc list
    filteredAmcList = List.from(amcList);
  }

  void updateSelectedFilterType(String filterType) {
    selectedFilterType = filterType;

    // reset amc list
    filteredAmcList = List.from(amcList);
    update();
  }

  void searchAmc(String searchText) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (searchText.isNullOrEmpty) {
          filteredAmcList = amcList;
        } else {
          filteredAmcList = amcList.where((amc) {
            return (amc.amc?.toLowerCase() ?? '')
                .contains(searchText.toLowerCase());
          }).toList();
        }
        update();
      },
    );
  }
}
