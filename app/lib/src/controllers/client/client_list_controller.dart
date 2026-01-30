import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_filter_model.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

// New Client List Controller
class ClientListController extends GetxController {
  // Fields

  MetaDataModel clientListMetaData =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);

  List<NewClientModel> clientList = [];

  ApiResponse clientResponse = ApiResponse();

  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  PartnerOfficeModel? partnerOfficeModel;

  Timer? _debounce;
  FocusNode? searchBarFocusNode;

  bool isPaginating = false;

  ApiResponse clientReportResponse = ApiResponse();
  String? reportUrl;

  NetworkState? downloadReportState;
  Uint8List? clientReportDocByte;

  final String reportExtension = 'xlsx';

  FilterMode currentFilterMode = FilterMode.filter;
  SortOrder? sortBy;
  SortOrder? tempSortBy;
  String? tempSortSelected;
  String? sortSelected;

  final Map<String, String> defaultFilters;

  Map<String, String> sortingMap = {
    'Total Current Value': 'total_current_value',
    'Total Invested Value': 'total_current_invested_value',
    // 'MF Invested Value ': 'mf_current_invested_value',
    // 'MF Current Value': 'mf_current_value',
    // 'Tracker Value': 'trak_mf_current_value',
    // 'COB Oportunity': 'trak_cob_opportunity_value',
    // 'Alternative current value ': 'total_alternative_current_value',
  };

  Map<String, ClientFilterModel> filterListMap = {};
  ApiResponse clientFilterResponse = ApiResponse();

  Map<String, ClientFilterModel> tempFilterListMap = {};
  Map<String, ClientFilterModel> selectedFilterListMap = {};

  final GlobalKey<FormState> filterFormKey = GlobalKey<FormState>();

  ClientListController(
      {this.partnerOfficeModel, this.defaultFilters = const {}});

  @override
  void onInit() {
    scrollController.addListener(_handlePagination);

    super.onInit();
  }

  @override
  void onReady() async {
    getFilterMapping();
    queryClientList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    scrollController.dispose();
    searchBarFocusNode?.dispose();

    super.dispose();
  }

  void resetPagination() {
    clientList = [];
    clientListMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
    searchQuery = '';
    searchController?.clear();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> queryClientList() async {
    Map<String, String> getQueryMap(String agentExternalIds) {
      List<Map<String, String>> selectedFilters = [];

      if (selectedFilterListMap.isNotEmpty) {
        selectedFilterListMap.forEach((filterName, filter) {
          final selectedOperator = filter.selectedOperator;
          String inputValue = filter.inputValue;
          // between
          if (selectedOperator.toLowerCase() == 'bt' &&
              filter.inputValue2.isNotNullOrEmpty) {
            inputValue += ',${filter.inputValue2}';
          }
          selectedFilters.add(
            {
              "key": filter.name ?? '',
              "operation": selectedOperator,
              "value": inputValue
            },
          );
        });
      }

      final filters = [
        {
          "key": "agent_external_id",
          "operation": "eq",
          "value": agentExternalIds
        },
        ...selectedFilters
      ];

      if (defaultFilters.isNotEmpty) {
        filters.add(defaultFilters);
      }

      final payload = {
        "q": searchQuery,
        "page": (clientListMetaData.page + 1).toString(),
        "per_page": clientListMetaData.limit.toString(),
        "sort_by": sortSelected.isNotNullOrEmpty
            ? sortingMap[sortSelected] ?? "created_at"
            : "created_at",
        "sort_reverse": sortBy == SortOrder.ascending ? "false" : "true",
        "pt": "user_profile",
        "platform": "partner-app",
        "filters": jsonEncode(filters),
      };
      return payload;
    }

    try {
      if (!isPaginating) {
        clientList.clear();
        clientListMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
      }
      clientResponse.state = NetworkState.loading;
      update();

      final agentExternalIds = (await getAgentExternalIdList()).join(',');
      final apiKey = await getApiKey();

      final response = await CommonRepository().universalSearch(
        apiKey!,
        getQueryMap(agentExternalIds),
      );

      final status = WealthyCast.toInt(response["status"]);

      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        final clientListResponse =
            WealthyCast.toList(response?['response']?['user_profiles']?['data'])
                .map((clientJson) => NewClientModel.fromJson(clientJson))
                .toList();
        clientListMetaData.totalCount = WealthyCast.toInt(
            response?['response']?['user_profiles']?['meta']?['total_count']);
        if (isPaginating) {
          clientList.addAll(List.from(clientListResponse));
        } else {
          clientList = List.from(clientListResponse);
        }

        clientResponse.state = NetworkState.loaded;
      } else {
        clientResponse.state = NetworkState.error;
        clientResponse.message = genericErrorMessage;
      }
    } catch (e) {
      clientResponse.state = NetworkState.error;
      clientResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
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

  void _handlePagination() {
    if (scrollController.hasClients) {
      final isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      final isPagesRemaining = (clientListMetaData.totalCount! /
              (clientListMetaData.limit * (clientListMetaData.page + 1))) >
          1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          clientResponse.state != NetworkState.loading) {
        clientListMetaData.page = clientListMetaData.page + 1;
        isPaginating = true;
        queryClientList();
      }
    }
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    resetPagination();
    queryClientList();
  }

  Future<dynamic> searchClientList(String query) async {
    searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (searchQuery.isEmpty) {
        clearSearchBar();
      } else {
        queryClientList();
      }
    });
  }

  void clearSearchBar() {
    searchQuery = '';
    searchController?.clear();
    queryClientList();
  }

  // Client Report
  // =============
  Future<void> createAgentReport() async {
    clientReportResponse.state = NetworkState.loading;
    update([GetxId.clientReport]);

    try {
      int agentId = await getAgentId() ?? 0;
      String apiKey = await getApiKey() ?? '';

      DateTime today = DateTime.now();
      String asOnDate = today.toIso8601String().split('T')[0];

      final variables = <String, dynamic>{
        "agentId": agentId,
        "templateName": "CLIENT-LIST-REPORT-V1",
        // pass true to refresh old reports
        "regenerate": false,
        "context": "{ \"as_on_date\": \"$asOnDate\"}"
      };

      QueryResult response =
          await AdvisorRepository().createAgentReport(apiKey, variables);

      if (response.hasException) {
        clientReportResponse.state = NetworkState.error;
        clientReportResponse.message = 'Something went wrong. Please try again';
      } else {
        reportUrl = WealthyCast.toStr(
                response.data?['createAgentReport']['report']['reportUrl']) ??
            '';
        clientReportResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      clientReportResponse.state = NetworkState.error;
      clientReportResponse.message = 'Something went wrong. Please try again';
    } finally {
      update([GetxId.clientReport]);
    }
  }

  Future<void> downloadAgentReport() async {
    downloadReportState = NetworkState.loading;
    update([GetxId.clientReport]);

    try {
      String apiKey = await getApiKey() ?? '';

      var response = await AdvisorRepository().downloadAgentReport(
          apiKey, '${reportUrl ?? ''}&type=$reportExtension');

      if (response['status'] == "200") {
        clientReportDocByte = response["response"];
        downloadReportState = NetworkState.loaded;
      } else {
        downloadReportState = NetworkState.error;
      }
    } catch (error) {
      downloadReportState = NetworkState.error;
    } finally {
      update([GetxId.clientReport]);
    }
  }

  void changeSortByMode() {
    if (tempSortBy == SortOrder.descending) {
      tempSortBy = SortOrder.ascending;
    } else {
      tempSortBy = SortOrder.descending;
    }

    update(['filter']);
  }

  void updateTempSorting(String tempSorting) {
    tempSortSelected = tempSorting;
    update(['filter']);
  }

  void changeFilterMode(FilterMode newFilterMode) {
    currentFilterMode = newFilterMode;
    update(['filter']);
  }

  void clearFilterAndSort() {
    // clear filter & sort separately
    if (currentFilterMode == FilterMode.filter) {
      tempFilterListMap = {};
      selectedFilterListMap = {};
    } else if (currentFilterMode == FilterMode.sort) {
      sortBy = null;
      tempSortBy = null;
      tempSortSelected = null;
      sortSelected = null;
    }

    currentFilterMode = FilterMode.filter;
    queryClientList();
  }

  void saveFilterAndSort() {
    sortBy = tempSortBy;
    sortSelected = tempSortSelected;

    // update selectedFilter only if tempFilter is null (remove filter) or
    // if it has value it should be not null
    selectedFilterListMap = {};
    if (tempFilterListMap.isNotEmpty) {
      tempFilterListMap.forEach((filterName, filter) {
        if (filter.inputValue.trim().isNotNullOrEmpty) {
          selectedFilterListMap[filterName] = ClientFilterModel.clone(filter);
        }
      });
    }

    currentFilterMode = FilterMode.filter;
    queryClientList();
  }

  void getSavedFilterAndSort() {
    tempSortSelected = sortSelected;
    tempSortBy = sortBy;
    tempFilterListMap = {};

    if (selectedFilterListMap.isNotEmpty) {
      selectedFilterListMap.forEach((filterName, filter) {
        tempFilterListMap[filterName] = ClientFilterModel.clone(filter);
      });
    }

    update(['filter']);
  }

  Future<void> getFilterMapping() async {
    try {
      clientFilterResponse.state = NetworkState.loading;
      update(['filter']);

      final apiKey = await getApiKey();

      final response = await ClientListRepository().getFilterMapping(apiKey!);

      final status = WealthyCast.toInt(response["status"]);

      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        final filterList = WealthyCast.toList(response?['response'])
            .map((filterJson) => ClientFilterModel.fromJson(filterJson))
            .toList()
            .where(
          (filterModel) {
            final isFilterCategory = filterModel.category.isNotNullOrEmpty &&
                filterModel.category!
                    .any((cat) => cat.toUpperCase() == 'FILTER');
            final isValidFilter = filterModel.name == 'total_current_value' ||
                filterModel.name == 'total_current_invested_value';
            return isFilterCategory && isValidFilter;
          },
        ).toList();

        filterList.forEach((filter) {
          filterListMap[filter.name!] = filter;
        });

        clientFilterResponse.state = NetworkState.loaded;
      } else {
        clientFilterResponse.state = NetworkState.error;
        clientFilterResponse.message = genericErrorMessage;
      }
    } catch (e) {
      clientFilterResponse.state = NetworkState.error;
      clientFilterResponse.message = genericErrorMessage;
    } finally {
      update(['filter']);
    }
  }
}
