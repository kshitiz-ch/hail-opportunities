import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/advisor/models/client_revenue_model.dart';
import 'package:core/modules/advisor/models/revenue_detail_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/src/intl/date_format.dart';

class RevenueDetailController extends GetxController {
  final ClientRevenueModel selectedClientRevenue;
  EmployeesModel? partnerEmployeeSelected;
  String? payoutId;
  final List<String> agentExternalIdList;

  ApiResponse clientRevenueResponse = ApiResponse();
  List<RevenueDetailModel> clientRevenueList = [];
  final DateTime revenueDate;
  String? apiKey;
  Map<String, Map<String, String>> revenueFilterList = {};
  Map<String, String> selectedRevenueFilter = {};
  Map<String, String> savedRevenueFilter = {};

  String? currentSelectedFilterType;

  ApiResponse productTypeResponse = ApiResponse();

  ScrollController scrollController = ScrollController();
  bool isPaginating = false;
  MetaDataModel clientRevenueDataMeta =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);

  bool get isAllEmployeesSelected =>
      partnerEmployeeSelected == null && agentExternalIdList.isNotNullOrEmpty;

  bool get isEmployeeSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'employee';

  bool get isPartnerOfficeSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'partner-office';

  bool get isOwnerSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'owner';

  bool enableFilterFab = false;

  RevenueDetailController({
    required this.selectedClientRevenue,
    this.payoutId,
    this.partnerEmployeeSelected,
    required this.revenueDate,
    this.agentExternalIdList = const [],
  });

  @override
  void onInit() async {
    scrollController.addListener(() {
      handlePagination();
      showFilterFab();
    });
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    updateRevenueFilter();
    getClientRevenueDetail();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  int get savedFilterCount {
    return savedRevenueFilter.values
        .where((element) => element.toLowerCase() != 'all')
        .length;
  }

  Future<void> getClientRevenueDetail() async {
    clientRevenueResponse.state = NetworkState.loading;
    if (!isPaginating) {
      clientRevenueDataMeta.page = 0;
      clientRevenueList.clear();
    }
    update();

    try {
      apiKey ??= await getApiKey();

      final data = await AdvisorRepository().getClientRevenueDetail(
        apiKey!,
        getClientRevenueQueryParams(),
        isPartnerOfficeSelected || isAllEmployeesSelected,
      );

      if (data['status'] == '200') {
        final jsonData = WealthyCast.toList(data['response']['data']);
        final totalCount = WealthyCast.toInt(data['response']['total_count']);
        if (jsonData.isNotNullOrEmpty) {
          final revenueDetailList = jsonData
              .map((json) => RevenueDetailModel.fromJson(json))
              .toList();
          clientRevenueList.addAll(revenueDetailList);
          clientRevenueDataMeta.totalCount = totalCount;
        }
        clientRevenueResponse.state = NetworkState.loaded;
      } else {
        clientRevenueResponse.message =
            getErrorMessageFromResponse(data['response']);
        clientRevenueResponse.state = NetworkState.error;
      }
    } catch (error) {
      clientRevenueResponse.message = 'Something went wrong';
      clientRevenueResponse.state = NetworkState.error;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<List<Map>?> getProductTypes() async {
    List<Map>? productTypeData;
    try {
      apiKey ??= await getApiKey();
      QueryResult response = await AdvisorRepository().getProductTypes(apiKey!);
      if (!response.hasException) {
        productTypeData =
            WealthyCast.toList(response.data!['entreat']['productTypes']);
      }
    } catch (error) {
    } finally {
      if (productTypeData.isNullOrEmpty) {
        productTypeData = [];
        revenueProductMapping.keys.forEach((key) {
          productTypeData!.add({
            'name': key,
          });
        });
      }
      return productTypeData;
    }
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      bool isPagesRemaining = (clientRevenueDataMeta.totalCount! /
              (clientRevenueDataMeta.limit *
                  (clientRevenueDataMeta.page + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          clientRevenueResponse.state != NetworkState.loading) {
        clientRevenueDataMeta.page = clientRevenueDataMeta.page + 1;
        isPaginating = true;
        getClientRevenueDetail();
      }
    }
  }

  String getClientRevenueQueryParams() {
    String queryParams = '?';
    queryParams += 'month=${revenueDate.month}';
    queryParams += '&year=${revenueDate.year}';

    if (isEmployeeSelected) {
      // for specific employee
      queryParams +=
          '&request_agent_id=${partnerEmployeeSelected?.agentExternalId}';
    } else if (isPartnerOfficeSelected) {
      // for total partner office
      queryParams += '&designations=employee,owner';
    } else if (isAllEmployeesSelected) {
      // for all employees
      queryParams += '&designations=employee';
    }

    if (payoutId.isNotNullOrEmpty) {
      if (payoutId.isNotNullOrEmpty) {
        queryParams = '?payout_id=$payoutId';
      }
    }

    // get data client specific
    queryParams += '&client_crn=${selectedClientRevenue.clientDetails!.crn}';

    // get sorted results
    queryParams += '&sort_by=-revenue';

    // pagination
    final offset =
        ((clientRevenueDataMeta.page + 1) * clientRevenueDataMeta.limit) -
            clientRevenueDataMeta.limit;
    queryParams += '&limit=${clientRevenueDataMeta.limit}';
    queryParams += '&offset=$offset';

    // apply filter
    if (savedRevenueFilter.isNotEmpty) {
      savedRevenueFilter.entries.forEach((filterData) {
        if (filterData.value.isNotNullOrEmpty &&
            filterData.value.toLowerCase() != 'all') {
          switch (filterData.key) {
            case RevenueFilterText.productType:
              queryParams += '&product_type=${filterData.value}';
              break;
            case RevenueFilterText.revenueType:
              queryParams += '&category=${filterData.value}';
              break;
            case RevenueFilterText.revenueStatus:
              queryParams += '&show_locked_revenue=${filterData.value}';
              break;
            case RevenueFilterText.transactions:
              queryParams += '&revenue_from=${filterData.value}';
              break;
            default:
          }
        }
      });
    }
    return queryParams;
  }

  Future<void> updateRevenueFilter() async {
    try {
      productTypeResponse.state = NetworkState.loading;
      final productTypes = (await getProductTypes())!
        ..sort(
          ((a, b) {
            final key1 = a['name'].toString().toLowerCase();
            final key2 = b['name'].toString().toLowerCase();
            return key1.compareTo(key2);
          }),
        );

      Map<String, String> productTypeFilterData = {'ALL': 'All'};

      productTypes.forEach((productType) {
        final key = productType['name'].toString();
        String value = key;
        if (revenueProductMapping.containsKey(key)) {
          value = revenueProductMapping[key]!;
        }
        productTypeFilterData[key] = value;
      });

      Map<String, String> revenueTypeFilterData = {
        'ALL': 'All',
        'BONUS': 'Bonus Revenue',
        'CRYFWD': 'Carry Forward',
        'REFF': 'Referral Revenue',
        'REWD': 'Reward Revenue',
        'TEAM': 'Team Revenue',
        'ORDER': 'Transactions',
      };

      Map<String, String> revenueStatusFilterData = {
        'ALL': 'All',
        'yes': 'Locked',
        'no': 'Unlocked',
      };

      Map<String, String> transactionFilterData = {
        'ALL': 'All',
        'new': "${DateFormat("MMMM").format(DateTime.now())}'s Transactions",
        'old': 'Older Transactions',
      };

      revenueFilterList = <String, Map<String, String>>{
        RevenueFilterText.productType: productTypeFilterData,
        RevenueFilterText.revenueType: revenueTypeFilterData,
        RevenueFilterText.revenueStatus: revenueStatusFilterData,
        RevenueFilterText.transactions: transactionFilterData,
      };
      savedRevenueFilter = {
        RevenueFilterText.productType: 'ALL',
        RevenueFilterText.revenueType: 'ALL',
        RevenueFilterText.revenueStatus: 'ALL',
        RevenueFilterText.transactions: 'ALL',
      };
      currentSelectedFilterType = savedRevenueFilter.entries.first.key;
    } catch (e) {
      LogUtil.printLog('error updateRevenueFilter: ' + e.toString());
    } finally {
      productTypeResponse.state = NetworkState.loaded;
    }
  }

  void updateSelectedFilterType(String filterType) {
    if (currentSelectedFilterType != filterType) {
      currentSelectedFilterType = filterType;
      update();
    }
  }

  void updateFilterValues({
    required String value,
    required bool isAdding,
  }) {
    if (isAdding) {
      selectedRevenueFilter[currentSelectedFilterType!] = value;
    } else {
      selectedRevenueFilter[currentSelectedFilterType!] = 'ALL';
    }
    update();
  }

  void clearFilter() {
    savedRevenueFilter = {
      RevenueFilterText.productType: 'ALL',
      RevenueFilterText.revenueType: 'ALL',
      RevenueFilterText.revenueStatus: 'ALL',
      RevenueFilterText.transactions: 'ALL',
    };
    selectedRevenueFilter = Map.from(savedRevenueFilter);
    update();
  }

  void showFilterFab() {
    if (scrollController.hasClients) {
      final viewPortDimension = scrollController.position.viewportDimension;
      final extentBefore = scrollController.position.extentBefore;
      enableFilterFab = extentBefore >= (viewPortDimension / 2);
      update([GetxId.filter]);
    }
  }
}
