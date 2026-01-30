import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScreenerController extends GetxController {
  ApiResponse screenerResponse = ApiResponse();
  Choice? returnTypeSelected;
  Choice? defaultReturnType;

  ScreenerModel? screener;
  ScrollController scrollController = ScrollController();
  ItemScrollController categoryScrollController = ItemScrollController();

  List<SchemeMetaModel> schemes = [];

  bool fromListScreen = false;
  bool fromCuratedFundsScreen = false;
  bool fromFundIdeasScreen = false;
  String searchControllerTag = 'mf-list';

  // Pagination
  int limit = 5;
  int page = 0;
  bool isPaginating = false;
  MetaDataModel metaData = MetaDataModel();

  // Filter & Sort
  FilterMode currentFilterMode = FilterMode.filter;
  FilterType filterTypeSelected = FilterType.category;

  List<Choice> categoryOptions = [];
  List<Choice> amcOptions = [];
  List<FundType> fundTypes = [FundType.Equity, FundType.Hybrid, FundType.Debt];

  FundType fundTypeSelected = FundType.Equity;
  FundType tempFundTypeSelected = FundType.Equity;

  ApiResponse categoryResponse = ApiResponse();
  List<Choice>? categorySelected;
  List<Choice> tempCategorySelected = [];

  // To track the position of category selected from the category list
  int categorySelectedIndex = 0;

  ApiResponse amcResponse = ApiResponse();
  List<Choice>? amcSelected;
  List<Choice> tempAmcSelected = [];

  Choice? sortSelected;
  Choice? tempSortSelected;

  SortOrder sortBy = SortOrder.descending;
  SortOrder tempSortBy = SortOrder.descending;
  //

  ReturnsModel? categoryAvgReturns;
  bool isCustomPortfoliosScreen;

  ScreenerController({
    this.screener,
    this.fromListScreen = false,
    this.fromCuratedFundsScreen = false,
    this.fromFundIdeasScreen = false,
    this.categorySelected,
    this.categorySelectedIndex = 0,
    this.amcSelected,
    this.isCustomPortfoliosScreen = false,
  });

  bool get canSelectMultipleCategory => isCustomPortfoliosScreen == true;

  @override
  void onInit() {
    if (fromListScreen) {
      limit = 20;
      scrollController.addListener(() {
        handlePagination();
      });
    }

    // Only choose the first category option as the default, if the category was not passed as a parameter
    if (categorySelected.isNullOrEmpty &&
        (screener?.categoryParams?.choices.isNotNullOrEmpty ?? false)) {
      categorySelected = [screener!.categoryParams!.choices!.first];
    }

    if (categorySelected.isNotNullOrEmpty) {
      tempCategorySelected = [...categorySelected!];
    }

    if (screener?.returnParams?.choices.isNotNullOrEmpty ?? false) {
      List choices = screener!.returnParams!.choices!;
      if (fromFundIdeasScreen && choices.length > 3) {
        returnTypeSelected = choices[3];
        defaultReturnType = choices[3];
      } else {
        for (Choice choice in choices) {
          if (choice.value == screener?.returnParams?.defaultValue) {
            returnTypeSelected = choice;
            defaultReturnType = choice;
            break;
          }
        }
      }
    }

    getSchemes();

    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  // Wealthy Select Funds
  // ====================
  Future<void> getSchemes() async {
    if (!isPaginating) {
      schemes.clear();
      screenerResponse.state = NetworkState.loading;
    }

    update();
    // schemes
    try {
      String apiKey = await getApiKey() ?? '';
      int offset = ((page + 1) * limit) - limit;

      String queryParams = '';

      if (categorySelected.isNotNullOrEmpty) {
        List<String> categories = categorySelected!.map((element) {
          return element.value ?? '';
        }).toList();
        queryParams += 'categories=${categories.join(",")}&';
      }

      if (amcSelected.isNotNullOrEmpty) {
        List<String> amcs = amcSelected!.map((element) {
          return element.value ?? '';
        }).toList();
        queryParams += 'amcs=${amcs.join(",")}&';
      }

      if (sortSelected != null) {
        if (sortBy == SortOrder.descending) {
          queryParams += 'ordering=-${sortSelected!.value}&';
        } else {
          queryParams += 'ordering=${sortSelected!.value}&';
        }
      }

      queryParams += 'limit=${limit}&offset=$offset';

      // String uri = '/v0/schemes/?$queryParams';
      String uri = screener?.uri ?? '';

      if (!fromCuratedFundsScreen) {
        if (Uri.parse(uri).queryParameters.isEmpty) {
          uri += '?$queryParams';
        } else {
          uri += '&$queryParams';
        }
      }

      var response;
      if (fromCuratedFundsScreen) {
        response = await StoreRepository().getCuratedFundsList(apiKey, uri);
      } else {
        response = await StoreRepository().getWealthySelectFunds(apiKey, uri);
      }

      if (response["status"] == "200") {
        List screenerJson;
        if (fromCuratedFundsScreen) {
          screenerJson = List.from(response["response"]["data"]);
          metaData = MetaDataModel();
        } else {
          screenerJson = List.from(response["response"]["results"]);
          metaData = MetaDataModel.fromJson(response["response"]["meta"]);
        }
        screenerJson.forEach(
          (x) => schemes.add(SchemeMetaModel.fromJson(x)),
        );

        if (schemes.isNotEmpty &&
            !fromCuratedFundsScreen &&
            (categorySelected ?? []).length == 1) {
          await getCategoryAvgReturns(schemes.first.classCode ?? '');
        }

        screenerResponse.state = NetworkState.loaded;
      } else {
        screenerResponse.state = NetworkState.error;
        screenerResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      screenerResponse.state = NetworkState.error;
      screenerResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getCategoryAvgReturns(String classCode) async {
    categoryAvgReturns = null;

    try {
      String apiKey = await getApiKey() ?? '';

      var response =
          await StoreRepository().getCategoryAvgReturns(apiKey, classCode);

      if (response["status"] == "200") {
        categoryAvgReturns = ReturnsModel.fromJson(response["response"]);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void updateCategorySelected(Choice newCategory, {int? categoryIndex = 0}) {
    bool isCategoryAlreadySelected = (categorySelected ?? []).firstWhereOrNull(
            (element) => element.value == newCategory.value) !=
        null;

    if (isCategoryAlreadySelected) return;

    if (canSelectMultipleCategory) {
      (categorySelected ?? []).add(newCategory);
    } else {
      categorySelected = [newCategory];
    }
    page = 0;

    if (categoryIndex != null) {
      categorySelectedIndex = categoryIndex;
    }

    getSchemes();
  }

  void updateTempFundTypeSelected(FundType newFundType) {
    tempFundTypeSelected = newFundType;
    getCategoryOptions();
  }

  void updateReturnTypeSelected(Choice newReturnType) {
    returnTypeSelected = newReturnType;
    update();
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      bool isPagesRemaining =
          ((metaData.totalCount ?? 0) / (limit * (page + 1))) > 1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          screenerResponse.state != NetworkState.loading) {
        page += 1;
        isPaginating = true;
        // update();
        getSchemes();
      }
    }
  }

  // Filters
  // ===================
  Future<void> getCategoryOptions() async {
    categoryOptions.clear();

    categoryResponse.state = NetworkState.loading;
    update(['filter']);

    try {
      String apiKey = await getApiKey() ?? '';

      String uri;
      if (isCustomPortfoliosScreen) {
        uri =
            '/v0/schemes/categories/?fund_type=${getFundTypeAbbr(tempFundTypeSelected)}';
      } else {
        uri = screener?.categoryParams?.uri ?? '';
      }

      var response = await StoreRepository().getWealthySelectFunds(apiKey, uri);

      if (response["status"] == "200") {
        List categoryListJson = response["response"]["data"];
        categoryListJson.forEach((e) {
          Choice categoryOption = Choice.fromJson(e);
          if (categoryOption.displayName.isNotNullOrEmpty &&
              categoryOption.value.isNotNullOrEmpty) {
            categoryOptions.add(Choice.fromJson(e));
          }
        });

        categoryResponse.state = NetworkState.loaded;
      } else {
        categoryResponse.state = NetworkState.error;
        categoryResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      categoryResponse.state = NetworkState.error;
      categoryResponse.message = genericErrorMessage;
    } finally {
      update(['filter']);
    }
  }

  Future<void> getAmcOptions() async {
    amcOptions.clear();
    amcResponse.state = NetworkState.loading;
    update(['filter']);

    try {
      String apiKey = await getApiKey() ?? '';

      var response = await StoreRepository().getAmcList(apiKey);

      if (response["status"] == "200") {
        List amcListJson = response["response"]["data"];
        amcListJson.forEach((e) {
          Choice amcOption = Choice.fromJson(e);

          if (amcOption.displayName.isNotNullOrEmpty &&
              amcOption.value.isNotNullOrEmpty) {
            amcOptions.add(amcOption);
          }
        });

        amcResponse.state = NetworkState.loaded;
      } else {
        amcResponse.state = NetworkState.error;
        amcResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      amcResponse.state = NetworkState.error;
      amcResponse.message = genericErrorMessage;
    } finally {
      update(['filter']);
    }
  }

  void changeFilterMode(FilterMode newFilterMode) {
    currentFilterMode = newFilterMode;
    update(['filter']);
  }

  void updateFilterTypeSelected(FilterType newFilterType) {
    filterTypeSelected = newFilterType;
    if (filterTypeSelected == FilterType.category && categoryOptions.isEmpty) {
      getCategoryOptions();
    } else if (filterTypeSelected == FilterType.amc && amcOptions.isEmpty) {
      getAmcOptions();
    }

    update(['filter']);
  }

  void updateTempFilter(Choice tempFilter) {
    if (filterTypeSelected == FilterType.category) {
      if (canSelectMultipleCategory) {
        bool isCategoryAlreadySelected = (categorySelected ?? [])
                .firstWhereOrNull(
                    (element) => element.value == tempFilter.value) !=
            null;
        if (isCategoryAlreadySelected) {
          tempCategorySelected.remove(tempFilter);
        } else {
          tempCategorySelected.add(tempFilter);
        }
      } else {
        tempCategorySelected = [tempFilter];
      }
    } else if (filterTypeSelected == FilterType.amc) {
      bool isAmcAlreadySelected = (amcSelected ?? []).firstWhereOrNull(
              (element) => element.value == tempFilter.value) !=
          null;
      if (isAmcAlreadySelected) {
        tempAmcSelected.remove(tempFilter);
      } else {
        tempAmcSelected.add(tempFilter);
      }
    }

    update(['filter']);
  }

  void clearFilterAndSort({bool clearSortOnly = false}) {
    (categorySelected ?? []).clear();
    tempCategorySelected.clear();
    categorySelectedIndex = -1;

    (amcSelected ?? []).clear();
    tempAmcSelected.clear();

    sortSelected = null;
    tempSortSelected = null;
    if (defaultReturnType != null) {
      returnTypeSelected = defaultReturnType;
    }

    page = 0;

    getSchemes();
  }

  void saveFilterAndSort() {
    categorySelected = [...tempCategorySelected];
    amcSelected = [...tempAmcSelected];
    sortSelected = tempSortSelected;
    sortBy = tempSortBy;

    // To find category selected index
    if (!canSelectMultipleCategory && categorySelected.isNotNullOrEmpty) {
      List<Choice> categoryOptions = screener?.categoryParams?.choices ?? [];
      int indexFound = -1;

      for (var index = 0; index < categoryOptions.length; index++) {
        Choice category = categoryOptions[index];
        if (category.value == categorySelected?.first.value) {
          indexFound = index;
          break;
        }
      }

      categorySelectedIndex = indexFound;
    }

    if (sortSelected != null && sortSelected!.value!.contains("return")) {
      List<Choice> returnOptions = screener?.returnParams?.choices ?? [];
      for (Choice option in returnOptions) {
        if (option.value == sortSelected?.value) {
          returnTypeSelected = option;
          break;
        }
      }
    }

    page = 0;
    getSchemes();
    update();
  }

  void changeSortByMode() {
    if (tempSortBy == SortOrder.descending) {
      tempSortBy = SortOrder.ascending;
    } else {
      tempSortBy = SortOrder.descending;
    }

    update(['filter']);
  }

  void getSavedFilterAndSort() {
    tempCategorySelected = List<Choice>.from(categorySelected ?? []).toList();
    tempAmcSelected = List<Choice>.from(amcSelected ?? []).toList();
    tempSortSelected = sortSelected;
    tempSortBy = sortBy;
    update(['filter']);
  }

  void updateTempSorting(Choice tempSorting) {
    tempSortSelected = tempSorting;
    update(['filter']);
  }

  void removeCategorySelected() {
    if (screenerResponse.state == NetworkState.loading) return;
    categorySelected = null;

    page = 0;

    getSchemes();
  }

  void removeAmcSelected() {
    if (screenerResponse.state == NetworkState.loading) return;
    amcSelected = null;

    page = 0;

    getSchemes();
  }

  void removeSortSelected() {
    if (screenerResponse.state == NetworkState.loading) return;
    sortSelected = null;
    if (defaultReturnType != null) {
      returnTypeSelected = defaultReturnType;
    }

    page = 0;

    getSchemes();
  }

  double? getReturnValue(ReturnsModel? returns) {
    switch (returnTypeSelected?.value) {
      case "returns_since_inception":
        return returns?.rtrnsSinceLaunch;
      case "returns_one_week":
        return returns?.oneWeekRtrns;
      case "returns_one_month":
        return returns?.oneMtRtrns;
      case "returns_three_months":
        return returns?.threeMtRtrns;
      case "returns_six_months":
        return returns?.sixMtRtrns;
      case "returns_one_year":
        return returns?.oneYrRtrns;
      case "returns_three_years":
        return returns?.threeYrRtrns;
      case "returns_five_years":
        return returns?.fiveYrRtrns;
      default:
        return null;
    }
  }

  void handleSchemeTableSwipe(details) {
    List<Choice> categoryOptions = screener?.categoryParams?.choices ?? [];

    if (categoryOptions.isNullOrEmpty) {
      return;
    }

    int? categoryIndex;

    // Swiping in left direction.
    if (details.velocity.pixelsPerSecond.dx > 800) {
      categoryIndex = categorySelectedIndex - 1;

      // if categoryIndex crossed min limit
      if (categoryIndex < 0) {
        categoryIndex = categoryOptions.length - 1;
      }
    }

    // Swiping in right direction.
    else if (details.velocity.pixelsPerSecond.dx < 0 &&
        details.velocity.pixelsPerSecond.dx < -800) {
      categoryIndex = categorySelectedIndex + 1;

      // if categoryIndex crossed max limit
      if (categoryIndex >= categoryOptions.length) {
        categoryIndex = 0;
      }
    }

    if (categoryIndex != null) {
      Choice choice = categoryOptions[categoryIndex];
      categoryScrollController.jumpTo(index: categoryIndex);
      updateCategorySelected(choice, categoryIndex: categoryIndex);
    }
  }
}
