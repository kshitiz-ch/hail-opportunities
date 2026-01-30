import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/fund_filter_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum SortBy { ascending, descending }

class FundsController extends GetxController {
  // Fields

  MetaDataModel fundsMetaData = MetaDataModel();
  final GoalSubtypeModel? portfolio;

  NetworkState? searchState;
  NetworkState? fundsState;
  NetworkState? fundFilterState;
  double? minAmountFilter = 0;

  int limit = 20;
  int page = 0;
  bool isPaginating = false;

  List<SchemeMetaModel>? customPortfolioFunds = [];
  List<SchemeMetaModel>? fundsResult = [];

  List<FundFilterModel> fundFilters = [];
  List<FundSortModel> fundSortingOptions = [];
  Map<String?, List<dynamic>> filtersSelected = {};
  Map<String?, List<dynamic>> filtersSaved = {};

  String currentSelectedSorting = '';
  String sortingSaved = '';
  String? currentSelectedFilter = '';
  SortBy sortBy = SortBy.descending;

  String fundsErrorMessage = '';

  TextEditingController? searchController;
  ScrollController? scrollController;
  TextEditingController? minAmountController;
  ScrollController? filterScrollController;

  String searchText = '';
  bool isCustomPortfolio = false;
  bool isTopUpPortfolio = false;
  FilterMode currentFilterMode = FilterMode.filter;

  Timer? _debounce;
  FocusNode? searchBarFocusNode;
  bool isWealthySelectFunds = false;

  FundsController({
    this.filtersSaved = const {},
    this.portfolio,
    this.isCustomPortfolio = false,
    this.isTopUpPortfolio = false,
    this.isWealthySelectFunds = false,
  });

  @override
  void onInit() {
    if (filtersSaved.keys.isNotEmpty) {
      filtersSelected = {...filtersSaved};
    }
    searchState = NetworkState.cancel;
    fundsState = NetworkState.loading;
    fundFilterState = NetworkState.cancel;

    searchBarFocusNode = FocusNode();

    searchController = TextEditingController();
    scrollController = ScrollController();
    filterScrollController = ScrollController();
    minAmountController = TextEditingController(text: '0');

    scrollController!.addListener(handlePagination);
    if (!isTopUpPortfolio) {
      getFundFilters();
      getFundSortingOptions();
    }

    super.onInit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    scrollController!.dispose();
    filterScrollController!.dispose();
    searchBarFocusNode?.dispose();
    super.dispose();
  }

  onFundSearch(String query) {
    if (query.isEmpty) {
      searchText = query;
      getMutualFunds();

      update(['search', 'funds']);
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchText = query;

          getMutualFunds();

          update(['search', 'funds']);
        },
      );
    }
  }

  void resetScrollController() {
    scrollController!.animateTo(
      0,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  Future<void> getMutualFunds({bool isRetry = false}) async {
    if (!isPaginating) {
      if (scrollController!.positions.isNotEmpty &&
          scrollController!.position.pixels >=
              scrollController!.position.minScrollExtent) {
        resetScrollController();
      }
      page = 0;
      fundsResult = [];
      fundsState = NetworkState.loading;
      update(['funds']);
    }

    try {
      String? apiKey = await getApiKey();

      Map filters = {};
      String sorting = '';

      if (filtersSaved.keys.length > 0) {
        filtersSaved.keys.forEach((filter) {
          var filterValues = filtersSaved[filter];
          if (filterValues != null && filterValues.isNotEmpty) {
            filters[filter] = filtersSaved[filter]!.join(",");
          }
        });
      }

      if (sortingSaved.isNotNullOrEmpty) {
        bool sortReverse = sortBy == SortBy.descending;
        sorting = 'sort_by=$sortingSaved&sort_reverse=$sortReverse';
      }

      // if (isWealthySelectFunds) {
      // }
      filters["wealthy_select"] = true;
      // if (searchText.isEmpty &&
      //     filters.keys.length == 0 &&
      //     minAmountFilter! <= 0) {
      //   filters["wealthy_select"] =
      //       sortingSaved.isNullOrEmpty && isWealthySelectFunds;
      // }

      if (minAmountFilter! > 0) {
        filters['min_deposit_amt'] = minAmountFilter;
      }

      int offset = ((page + 1) * limit) - limit;
      final response = await StoreRepository().searchMutualFunds(
        apiKey: apiKey,
        query: searchText,
        filters: filters,
        sorting: sorting,
        limit: limit,
        offset: offset,
      );

      if (response['status'] == "200") {
        List result = response['response']['data'];
        MetaDataModel metaData =
            MetaDataModel.fromJson(response['response']['meta']);

        // result.forEach((element) {

        // });
        for (var i = 0; i < result.length; i++) {
          // TODO: Push this logic to the Scheme Meta model
          var fundSchemeData = result[i];
          Map<String, dynamic> fund = {
            'id': fundSchemeData['objectID'],
            'amc': fundSchemeData['amc'],
            'schemeName': fundSchemeData['scheme_name'],
            'displayName': fundSchemeData['display_name'],
            'category': fundSchemeData['category'],
            'subcategory': fundSchemeData['subcategory'],
            'fundType': fundSchemeData['fund_type'],
            'expenseRatio': fundSchemeData['expense_ratio'],
            'returnType': fundSchemeData['return_type'],
            'planType': fundSchemeData['plan_type'],
            'schemeCode': fundSchemeData['scheme_code'],
            'wschemecode': fundSchemeData['wschemecode'],
            'exitLoadTime': fundSchemeData['exit_load_time'],
            'exitLoadUnit': fundSchemeData['exit_load_unit'],
            'exitLoadPercentage': fundSchemeData['exit_load_percentage'],
            'minDepositAmt': fundSchemeData['min_deposit_amt'],
            'minAddDepositAmt': fundSchemeData['min_add_deposit_amt'],
            'navAtLaunch': fundSchemeData['nav_at_launch'],
            'nav': fundSchemeData['nav'],
            'navDate': fundSchemeData['nav_date'],
            'isTaxSaver': fundSchemeData['is_tax_saver'],
            'minWithdrawalAmt': fundSchemeData['min_withdrawal_amt'],
            'returns': fundSchemeData['returns'],
            'minSipDepositAmt': fundSchemeData['min_sip_deposit_amt'],
            'isPaymentAllowed': fundSchemeData['is_payment_allowed'],
            'sipAllowed': fundSchemeData['sip_allowed'],
            'sipRegistrationStartDate':
                fundSchemeData['sip_registration_start_date'],
            "wealthy_select": fundSchemeData["wealthy_select"],
            'isNewFund': false,
            'launch_date': fundSchemeData['launch_date'],
            'wpc': fundSchemeData?['wpc']
          };

          fundsResult!.add(SchemeMetaModel.fromJson(fund));
        }

        fundsMetaData = metaData;
        LogUtil.printLog(metaData.totalCount);
        fundsState = NetworkState.loaded;
      } else {
        fundsState = NetworkState.error;
        fundsErrorMessage = getErrorMessageFromResponse(response['response']);
      }
    } catch (error) {
      fundsErrorMessage = 'Something went wrong';
      fundsState = NetworkState.error;
    } finally {
      isPaginating = false;
      update(['funds', 'pagination-loader']);
    }
  }

  Future<void> getFundFilters() async {
    fundFilterState = NetworkState.loading;
    try {
      final data = await StoreRepository().getFundFilters();
      if (data['status'] == '200') {
        var filtersList = data['response'];
        filtersList.forEach((filter) {
          FundFilterModel fundFilterModel = FundFilterModel.fromJson(filter);
          fundFilters.add(fundFilterModel);
          // if (!fundFilterModel.isCustom) {
          // }
        });
        currentSelectedFilter = fundFilters[0].name;
        fundFilterState = NetworkState.loaded;
      } else {
        fundFilterState = NetworkState.error;
      }
    } catch (error) {
      fundFilterState = NetworkState.error;
    } finally {
      update(['search']);
    }
  }

  Future<void> getFundSortingOptions() async {
    try {
      final data = await StoreRepository().getFundSortingOptions();
      if (data['status'] == '200') {
        var sortingOptions = data['response'];
        sortingOptions.forEach((option) {
          fundSortingOptions.add(FundSortModel.fromJson(option));
        });
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update(['search']);
    }
  }

  // TODO: Improve variable names
  void updateFilterValues({dynamic filterValue, bool isAdding = true}) {
    String? filterName = currentSelectedFilter;
    if (filtersSelected.containsKey(filterName)) {
      List? existingFilterValues = filtersSelected[filterName];
      if (isAdding) {
        existingFilterValues!.add(filterValue);
      } else {
        existingFilterValues!.removeWhere((value) => value == filterValue);
      }

      // Remove filter from object if the options is selected is null or empty
      if (existingFilterValues.isEmpty) {
        filtersSelected.remove(filterName);
      } else {
        filtersSelected[filterName] = existingFilterValues;
      }
    } else {
      if (isAdding) {
        filtersSelected[filterName] = [filterValue];
      } else {
        filtersSelected.remove(filterName);
      }
    }

    update(['search', 'funds']);
  }

  void updateFilterSelected(String? filter) {
    currentSelectedFilter = filter;
    filterScrollController!.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.ease,
    );
    update(['funds', 'search']);
  }

  void updateSortingSelected(String sortingOption) {
    currentSelectedSorting = sortingOption;
    update(['funds', 'search']);
  }

  void updateMinAmountFilter(double? value) {
    minAmountFilter = value;
    update(['min-amount-slider']);
  }

  void saveFiltersAndSorting() {
    page = 0;
    filtersSaved = {};
    Map filtersSelectedCopy = {...filtersSelected};
    filtersSelectedCopy.keys.forEach((filterName) {
      filtersSaved[filterName] = [...filtersSelectedCopy[filterName]];
    });

    sortingSaved = currentSelectedSorting;

    update(['funds', 'search']);
    getMutualFunds();
  }

  void resetFilter() {
    page = 0;
    filtersSelected = {};
    update(['funds', 'search']);
  }

  void clearFilters() {
    bool isFiltersAdded =
        filtersSaved.keys.isNotEmpty || filtersSelected.keys.isNotEmpty;
    bool isMinAmountFilterAdded = minAmountController!.text.isNotNullOrEmpty &&
        minAmountController!.text != '0';
    bool isSortingAdded = currentSelectedSorting.isNotNullOrEmpty;

    if (isFiltersAdded) {
      filtersSelected = {};
      filtersSaved = {};
    }

    if (isSortingAdded) {
      currentSelectedSorting = '';
      sortingSaved = '';
    }

    if (isMinAmountFilterAdded) {
      minAmountController!.text = '0';
      minAmountFilter = 0;
    }

    if (isFiltersAdded || isSortingAdded || isMinAmountFilterAdded) {
      getMutualFunds();
    }

    update(['funds', 'search']);
  }

  void removeNonSavedFilters() {
    filtersSelected = {};
    Map filtersSavedCopy = {...filtersSaved};
    filtersSavedCopy.keys.forEach((filterName) {
      filtersSelected[filterName] = [...filtersSavedCopy[filterName]];
    });

    // if the selected sorting is not saved,
    // then clear or reassign the current selected sorting option
    if (sortingSaved.isNullOrEmpty) {
      currentSelectedSorting = '';
    } else if (sortingSaved != currentSelectedSorting) {
      currentSelectedSorting = sortingSaved;
    }

    update(['funds', 'search']);
  }

  /// Clears the SearchBar
  void clearSearchBar() {
    searchText = "";
    searchController!.clear();
    getMutualFunds();
    update(['funds', 'search']);
  }

  handlePagination() {
    bool isScrolledToBottom = scrollController!.position.maxScrollExtent <=
            scrollController!.position.pixels &&
        scrollController!.positions.isNotEmpty;

    bool isPagesRemaining = false;
    if (fundsMetaData.totalCount != null) {
      isPagesRemaining = (fundsMetaData.totalCount! / (limit * (page + 1))) > 1;
    }

    if (isScrolledToBottom && isPagesRemaining) {
      page += 1;
      isPaginating = true;
      update(['pagination-loader']);
      getMutualFunds();
    }
  }

  void changeFilterMode(FilterMode newFilterMode) {
    currentFilterMode = newFilterMode;

    update(['funds', 'search']);
  }

  void changeSortByMode() {
    if (sortBy == SortBy.descending) {
      sortBy = SortBy.ascending;
    } else {
      sortBy = SortBy.descending;
    }

    update(['funds', 'search']);
  }
}
