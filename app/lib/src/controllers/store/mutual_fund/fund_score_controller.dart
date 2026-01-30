import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/stock_holding_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

enum CategorySort { Annual_Return, Absoute_Percentage }

class FundScoreController extends GetxController {
  NetworkState fetchSchemeScoreState = NetworkState.loading;
  NetworkState fetchSchemeDataState = NetworkState.loading;
  SchemeMetaModel? schemeData;

  SchemeMetaModel scheme;

  // Return Ratings
  ReturnsModel? categoryAvgReturns;
  CategorySort categorySortOption = CategorySort.Annual_Return;
  List<int> categoryReturnYearOptions = [1, 3, 5];
  int categoryReturnYearSelected = 3;

  // Holding Analysis
  NetworkState fetchHoldingAnalysisState = NetworkState.cancel;
  NetworkState fetchCategoryBreakupState = NetworkState.cancel;
  NetworkState fetchFundBreakupState = NetworkState.cancel;
  NetworkState fetchSectorBreakupState = NetworkState.cancel;
  NetworkState fetchCreditRatingBreakupState = NetworkState.cancel;
  List<List> sectorBreakup = [];
  List<List> categoryBreakup = [];
  List<List> fundBreakup = [];
  List<List> creditRatingBreakup = [];
  bool expandSectorAllocation = false;

  // Stock Holding State
  NetworkState fetchStockHoldingState = NetworkState.cancel;
  List<StockHoldingModel> stockHoldings = [];
  bool isPaginating = false;
  MetaDataModel stockHoldingMeta = MetaDataModel(limit: 10);

  // Top Category Funds State
  NetworkState fetchTopCategoryFundState = NetworkState.cancel;
  List<SchemeMetaModel> topCategoryFunds = [];
  int topCategoryFundReturnYearSelected = 3;

  bool get isStockHoldingCountRemaining {
    return (stockHoldingMeta.totalCount! /
            (stockHoldingMeta.limit * (stockHoldingMeta.page + 1))) >
        1;
  }

  // Fund Benchmark Return
  NetworkState fetchBenchmarkReturnState = NetworkState.cancel;
  ReturnsModel? benchmarkReturn;

  FundScoreController({
    required this.scheme,
  });

  void onInit() {
    getSchemeAdditionalData();

    super.onInit();
  }

  switchCategorySortOption() {
    if (categorySortOption == CategorySort.Annual_Return) {
      categorySortOption = CategorySort.Absoute_Percentage;
    } else {
      categorySortOption = CategorySort.Annual_Return;
    }

    update(['return-ratings']);
  }

  updateCategoryReturnYearSelected(int year) {
    categoryReturnYearSelected = year;
    update(['return-ratings']);
  }

  updatetopCategoryFundReturnYearSelected(int year) {
    topCategoryFundReturnYearSelected = year;
    update(['top-category-funds']);
  }

  Future<void> getSchemeAdditionalData() async {
    fetchSchemeDataState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      final QueryResult response = await StoreRepository()
          .getSchemeData(apiKey, null, scheme.wschemecode ?? '');
      if (!response.hasException) {
        StoreFundAllocation fundsResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        schemeData = fundsResult.schemeMetas?.first;
        fetchSchemeDataState = NetworkState.loaded;

        await getCategoryAvgReturns(schemeData?.classCode ?? '');
      } else {
        fetchSchemeDataState = NetworkState.error;
      }
    } catch (error) {
      fetchSchemeDataState = NetworkState.error;
    } finally {
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

  // Holding Analysis
  // ================
  Future<void> getHoldingAnalysis() async {
    fetchHoldingAnalysisState = NetworkState.loading;
    update(['holding-analysis']);
    String fundDescription = fundTypeDescription(schemeData?.fundType);

    if (fundDescription == FundType.Equity.name) {
      await getSchemeFundBreakup();
      await getSchemeCategoryBreakup();
      await getSchemeSectorBreakup();
    } else if (fundDescription == FundType.Hybrid.name) {
      await getSchemeFundBreakup();
      await getSchemeCategoryBreakup();
      await getCreditRatingBreakup();
      await getSchemeSectorBreakup();
    } else if (fundDescription == FundType.Debt.name) {
      await getCreditRatingBreakup();
      await getSchemeSectorBreakup();
    } else {
      await getSchemeFundBreakup();
    }

    fetchHoldingAnalysisState = NetworkState.loaded;
    update(['holding-analysis']);
  }

  // Large Cap, Mid Cap, Small Cap
  Future<void> getSchemeCategoryBreakup() async {
    fetchCategoryBreakupState = NetworkState.loading;
    update(['scheme-category-breakup']);

    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getSchemeCategoryBreakup(apiKey, schemeData?.wpc ?? '');
      if (data["status"] == "200") {
        categoryBreakup = WealthyCast.toList<List>(data["response"]["data"]);
        fetchCategoryBreakupState = NetworkState.loaded;
      } else {
        fetchCategoryBreakupState = NetworkState.error;
      }
    } catch (error) {
      fetchCategoryBreakupState = NetworkState.error;
    } finally {
      update(['scheme-category-breakup']);
    }
  }

  // Equity / Debt Split
  Future<void> getSchemeFundBreakup() async {
    fetchFundBreakupState = NetworkState.loading;
    update(['scheme-fund-breakup']);
    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getSchemeFundBreakup(apiKey, schemeData?.wpc ?? '');
      if (data["status"] == "200") {
        fundBreakup = WealthyCast.toList<List>(data["response"]["data"]);
        ;
        fetchFundBreakupState = NetworkState.loaded;
      } else {
        fetchFundBreakupState = NetworkState.error;
      }
    } catch (error) {
      fetchFundBreakupState = NetworkState.error;
    } finally {
      update(['scheme-fund-breakup']);
    }
  }

  // Sector Split
  Future<void> getSchemeSectorBreakup() async {
    fetchCategoryBreakupState = NetworkState.loading;

    update(['scheme-sector-breakup']);
    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getSchemeSectorBreakup(apiKey, schemeData?.wpc ?? '');

      if (data["status"] == "200") {
        sectorBreakup = WealthyCast.toList<List>(data["response"]["data"]);
        fetchCategoryBreakupState = NetworkState.loaded;
      } else {
        fetchCategoryBreakupState = NetworkState.error;
      }
    } catch (error) {
      fetchCategoryBreakupState = NetworkState.error;
    } finally {
      update(['scheme-sector-breakup']);
    }
  }

  void setExpandSectorAllocation() {
    expandSectorAllocation = true;
    update(['scheme-sector-breakup']);
  }

  // Stock Holding Split
  // ===================
  Future<void> getStockHolding() async {
    fetchStockHoldingState = NetworkState.loading;
    if (!isPaginating) {
      stockHoldings.clear();
    }
    update(['stock-holding']);

    try {
      String apiKey = await getApiKey() ?? '';
      int offset = ((stockHoldingMeta.page + 1) * stockHoldingMeta.limit) -
          stockHoldingMeta.limit;
      var data = await StoreRepository().getSchemeStockHoldings(
        apiKey,
        schemeData?.wpc ?? '',
        limit: stockHoldingMeta.limit,
        offset: offset,
      );

      if (data["status"] == "200") {
        if (data?["response"]?["meta"] != null) {
          stockHoldingMeta.totalCount =
              data?["response"]?["meta"]["total_count"] ?? 0;
        }

        data["response"]["results"].forEach((e) {
          stockHoldings.add(StockHoldingModel.fromJson(e));
        });
        fetchStockHoldingState = NetworkState.loaded;
      } else {
        fetchStockHoldingState = NetworkState.error;
      }
    } catch (error) {
      fetchStockHoldingState = NetworkState.error;
    } finally {
      isPaginating = false;
      update(['stock-holding']);
    }
  }

  void paginateStockHolding() {
    stockHoldingMeta.page += 1;
    isPaginating = true;
    update(['stock-holding']);
    getStockHolding();
  }

  // Fund vs Benchmark Comparison
  // ============================
  Future<void> getBenchmarkReturn() async {
    update(['benchmark-return']);
    fetchBenchmarkReturnState = NetworkState.loading;
    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getBenchmarkReturn(apiKey, schemeData?.benchmarkTpid ?? '');

      if (data["status"] == "200") {
        benchmarkReturn = ReturnsModel.fromJson(data["response"]["data"]);
        fetchBenchmarkReturnState = NetworkState.loaded;
      } else {
        fetchBenchmarkReturnState = NetworkState.error;
      }
    } catch (error) {
      fetchBenchmarkReturnState = NetworkState.error;
    } finally {
      update(['benchmark-return']);
    }
  }

  // Top Category Funds
  // ===================
  Future<void> getTopCategoryFunds() async {
    fetchTopCategoryFundState = NetworkState.loading;
    topCategoryFunds.clear();
    update(['top-category-funds']);
    try {
      String apiKey = await getApiKey() ?? '';

      // String returnYearDescription = '';
      // if (topCategoryFundReturnYearSelected == 1) {
      //   returnYearDescription = "returns_one_year";
      // } else if (topCategoryFundReturnYearSelected == 3) {
      //   returnYearDescription = "returns_three_years";
      // } else if (topCategoryFundReturnYearSelected == 5) {
      //   returnYearDescription = "returns_five_years";
      // }

      String categoryEncoded = Uri.encodeComponent(schemeData?.category ?? '');

      String queryParam =
          '?fund_type=${schemeData?.fundType}&category=${categoryEncoded}&limit=8&offset=0';
      var data = await StoreRepository().getSchemeList(apiKey, queryParam);

      if (data["status"] == "200") {
        data["response"]["results"].forEach((e) {
          topCategoryFunds.add(SchemeMetaModel.fromJson(e));
        });
        fetchTopCategoryFundState = NetworkState.loaded;
      } else {
        fetchTopCategoryFundState = NetworkState.error;
      }
    } catch (error) {
      fetchTopCategoryFundState = NetworkState.error;
    } finally {
      update(['top-category-funds']);
    }
  }

  // Credit Rating
  // =================
  Future<void> getCreditRatingBreakup() async {
    fetchCreditRatingBreakupState = NetworkState.loading;
    update(['credit-rating']);
    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getCreditRatingBreakup(apiKey, schemeData?.wpc ?? '');
      if (data["status"] == "200") {
        creditRatingBreakup =
            WealthyCast.toList<List>(data["response"]["data"]);
        ;
        fetchCreditRatingBreakupState = NetworkState.loaded;
      } else {
        fetchCreditRatingBreakupState = NetworkState.error;
      }
    } catch (error) {
      fetchCreditRatingBreakupState = NetworkState.error;
    } finally {
      update(['credit-rating']);
    }
  }

  // Return, Risk and Earnings Score Sub fields
  // ==========================================
  List<Map<String, String>> getReturnScoreSubFields() {
    List<Map<String, String>> labelValuePairs = [
      {
        ScoreSubfields.ThreeYearReturn:
            getReturnPercentageText(schemeData?.returns?.threeYrRtrns)
      }
    ];

    String fundDescription = fundTypeDescription(schemeData?.fundType);

    if (fundDescription == FundType.Debt.name) {
      labelValuePairs.addAll([
        {
          ScoreSubfields.YTM:
              (schemeData?.yieldTillMaturity?.isNotNullOrZero ?? false)
                  ? '${schemeData!.yieldTillMaturity!.toStringAsFixed(1)}%'
                  : '-'
        },
      ]);
      return labelValuePairs;
    }

    if (fundDescription == FundType.Hybrid.name) {
      labelValuePairs.addAll([
        {
          ScoreSubfields.Alpha: (schemeData?.alpha?.isNotNullOrZero ?? false)
              ? '${schemeData!.alpha!.toStringAsFixed(1)}%'
              : '-'
        },
        {
          ScoreSubfields.YTM:
              (schemeData?.yieldTillMaturity?.isNotNullOrZero ?? false)
                  ? '${schemeData!.yieldTillMaturity!.toStringAsFixed(1)}%'
                  : '-'
        },
      ]);
      return labelValuePairs;
    }

    labelValuePairs.addAll([
      {
        ScoreSubfields.Alpha: (schemeData?.alpha?.isNotNullOrZero ?? false)
            ? '${schemeData!.alpha!.toStringAsFixed(1)}%'
            : '-'
      },
    ]);
    return labelValuePairs;
  }

  List<Map<String, String>> getRiskScoreSubFields() {
    List<Map<String, String>> labelValuePairs = [
      {
        ScoreSubfields.SD: (schemeData?.sd?.isNotNullOrZero ?? false)
            ? '${schemeData?.sd!.toStringAsFixed(1)}%'
            : '-'
      },
    ];

    String fundDescription = fundTypeDescription(schemeData?.fundType);

    if (fundDescription == FundType.Debt.name) {
      labelValuePairs.addAll([
        {
          ScoreSubfields.MD:
              (schemeData?.modifiedDuration?.isNotNullOrZero ?? false)
                  ? '${schemeData!.modifiedDuration}'
                  : '-'
        },
      ]);
      return labelValuePairs;
    }

    if (fundDescription == FundType.Hybrid.name) {
      labelValuePairs.addAll([
        {
          ScoreSubfields.Beta: (schemeData?.beta?.isNotNullOrZero ?? false)
              ? '${schemeData!.beta!.toStringAsFixed(1)}'
              : '-'
        },
        {
          ScoreSubfields.MD:
              (schemeData?.modifiedDuration?.isNotNullOrZero ?? false)
                  ? '${schemeData!.modifiedDuration}'
                  : '-'
        },
      ]);
      return labelValuePairs;
    }

    labelValuePairs.addAll([
      {
        ScoreSubfields.Beta: (schemeData?.beta?.isNotNullOrZero ?? false)
            ? '${schemeData!.beta!.toStringAsFixed(1)}'
            : '-'
      },
    ]);
    return labelValuePairs;
  }

  List<Map<String, String>> getEarningsScoreSubFields() {
    String fundDescription = fundTypeDescription(schemeData?.fundType);

    if (fundDescription == FundType.Debt.name) {
      return [
        {
          ScoreSubfields.AAA:
              (schemeData?.aaaSovereignAllocation?.isNotNullOrZero ?? false)
                  ? '${schemeData!.aaaSovereignAllocation!.toStringAsFixed(1)}%'
                  : '-'
        },
        {
          ScoreSubfields.Holding: (schemeData
                      ?.holdingInTop20Companies?.isNotNullOrZero ??
                  false)
              ? '${schemeData!.holdingInTop20Companies!.toStringAsFixed(1)}%'
              : '-'
        },
      ];
    }

    return [
      {
        ScoreSubfields.PE: (schemeData?.pe?.isNotNullOrZero ?? false)
            ? '${schemeData!.pe!.toStringAsFixed(1)}'
            : '-'
      },
    ];
  }

  Map<String, String> subfieldsDescription = {
    ScoreSubfields.ThreeYearReturn:
        "The average annual return of the mutual fund over the past three years",
    ScoreSubfields.YTM:
        "The total return anticipated on a bond if the bond is held until it matures",
    ScoreSubfields.Alpha:
        "A measure of a mutual fund's performance on a risk-adjusted basis relative to a benchmark index",
    ScoreSubfields.SD:
        "A measure of the volatility or risk associated with the mutual fund's returns",
    ScoreSubfields.MD:
        "A measure of the sensitivity of a bond fund's price to changes in interest rates",
    ScoreSubfields.Beta:
        "A measure of a mutual fund's volatility in relation to the overall market",
    ScoreSubfields.AAA:
        "Indicates that the mutual fund holds a significant portion of its assets in AAA-rated securities, which are considered the highest credit quality",
    ScoreSubfields.Holding:
        "The percentage of the mutual fund's total assets that are invested in its top 20 securities holdings.",
    ScoreSubfields.PE:
        "The average price-to-earnings ratio of the stocks held in the mutual fund's portfolio",
  };
}
