import 'dart:math';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/common/models/chart_data_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/mf_index_model.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';

class ChartController extends GetxController {
  // Fields
  final bool isFund;
  final List<int> tabs;

  final String? productVariant;
  final String? wSchemeCode;

  final GoalSubtypeModel? portfolio;
  final SchemeMetaModel? fund;

  List<ChartDataModel> chartDataResult = [];
  List<ChartDataModel> indexChartData = [];
  List<MfIndexModel> mfIndices = [];
  MfIndexModel? selectedMfIndex;
  ReturnsModel? mfIndexReturn;

  NetworkState? fetchMfIndiceState;

  NetworkState? chartState;
  String? chartErrorMessage = '';

  int? selectedTab;
  bool isMaxTabSelected = false;

  bool get isDebtFund =>
      fundTypeDescription(fund?.fundType) == FundType.Debt.name;

  // Constructor
  ChartController(
    this.isFund, {
    this.productVariant,
    this.wSchemeCode,
    this.portfolio,
    this.fund,
  })  : assert(productVariant != null ? portfolio != null : true),
        assert(isFund ? wSchemeCode != null && fund != null : true),
        tabs = isFund ? [1, 6, 12, 36, 60] : [12, 36, 60];

  // Getters
  double get maxNav {
    if (chartDataResult.isNotEmpty) {
      return (chartDataResult.map<double>((e) => e.nav).reduce(max));
    } else {
      return 0;
    }
  }

  double get minNav {
    if (chartDataResult.isNotEmpty) {
      return (chartDataResult.map<double>((e) => e.nav).reduce(min));
    } else {
      return 0;
    }
  }

  // Getters
  double get maxPercentage {
    if (chartDataResult.isNotEmpty) {
      if (isFund) {
        double schemeMaxPercentage =
            chartDataResult.map<double>((e) => e.percentage).reduce(max);
        double indexMaxPercentage =
            indexChartData.map<double>((e) => e.percentage).reduce(max);
        return max(schemeMaxPercentage, indexMaxPercentage);
      } else {
        return (chartDataResult.map<double>((e) => e.percentage).reduce(max));
      }
    } else {
      return 0;
    }
  }

  double get minPercentage {
    if (chartDataResult.isNotEmpty) {
      if (isFund) {
        double schemeMinPercentage =
            chartDataResult.map<double>((e) => e.percentage).reduce(min);
        double indexMinPercentage =
            indexChartData.map<double>((e) => e.percentage).reduce(min);
        return min(schemeMinPercentage, indexMinPercentage);
      } else {
        return (chartDataResult.map<double>((e) => e.percentage).reduce(min));
      }
    } else {
      return 0;
    }
  }

  double get indexPercentage {
    // if (isMaxTabSelected) {

    // } else {

    // }
    switch (selectedTab) {
      case 1:
        return mfIndexReturn?.oneMtRtrns ?? 0;
      case 6:
        return mfIndexReturn?.sixMtRtrns ?? 0;
      case 12:
        return mfIndexReturn?.oneYrRtrns ?? 0;
      case 36:
        return mfIndexReturn?.threeYrRtrns ?? 0;
      case 60:
        return mfIndexReturn?.fiveYrRtrns ?? 0;
      default:
        return 0.0;
    }
  }

  double get navPercentage {
    if (isFund) {
      if (isMaxTabSelected) {
        return (fund?.returns?.rtrnsSinceLaunch ?? 0) * 100;
      } else {
        switch (selectedTab) {
          case 1:
            return (fund?.returns?.oneMtRtrns ?? 0) * 100;
          case 6:
            return (fund?.returns?.sixMtRtrns ?? 0) * 100;
          case 12:
            return (fund?.returns?.oneYrRtrns ?? 0) * 100;
          case 36:
            return (fund?.returns?.threeYrRtrns ?? 0) * 100;
          case 60:
            return (fund?.returns?.fiveYrRtrns ?? 0) * 100;
          default:
            return 0.0;
        }
      }
    } else {
      switch (selectedTab) {
        case 12:
          return (portfolio?.pastOneYearReturns ?? 0) * 100;
        case 36:
          return (portfolio?.pastThreeYearReturns ?? 0) * 100;
        case 60:
          return (portfolio?.pastFiveYearReturns ?? 0) * 100;
        default:
          return 0.0;
      }
    }
  }

  @override
  void onInit() {
    chartState = NetworkState.loading;

    if (isFund && fund?.launchDate != null) {
      final totalMonthsFromLunch =
          DateTime.now().difference(fund!.launchDate!).inDays / 30;
      // [1, 6, 12, 36, 60]
      if (totalMonthsFromLunch >= 36) {
        selectedTab = tabs[3];
      } else if (totalMonthsFromLunch >= 12) {
        selectedTab = tabs[2];
      } else if (totalMonthsFromLunch >= 6) {
        selectedTab = tabs[1];
      } else {
        selectedTab = tabs.first;
      }
    } else {
      selectedTab = tabs.first;
    }

    super.onInit();
  }

  @override
  void onReady() {
    getChartData(fetchIndexReturn: true);

    super.onReady();
  }

  /// Update the selected tab
  void updateTab(int tab) {
    selectedTab = tab;
    isMaxTabSelected = false;
    update();
  }

  void setMaxTab() {
    isMaxTabSelected = true;
    selectedTab = null;
    update();
  }

  /// Helper function to fetch chart data from different APIs based on [isFund]
  Future<void> getChartData({bool fetchIndexReturn = false}) async {
    isFund
        ? await getMfChartData(wSchemeCode!,
            years: selectedTab! ~/ 12, fetchIndexReturn: fetchIndexReturn)
        : await getPortfolioChartData(
            productVariant!,
            DateTime.now()
                .subtract(Duration(days: selectedTab! * 30))
                .millisecondsSinceEpoch,
          );
  }

  /// Fetch MF Portfolio Chart data from API
  Future<void> getPortfolioChartData(String subType, int from) async {
    chartState = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> response =
          await StoreRepository().getPortfolioChartData(subType, from);

      if (response['status'] == '200') {
        List<dynamic> data = response['response'];

        chartDataResult = data
            .map(
              (el) => ChartDataModel(WealthyCast.toInt(el['d'])!,
                  WealthyCast.toDouble(el['iv'])!, 0),
            )
            .toList();
        chartState = NetworkState.loaded;
      } else {
        chartErrorMessage = response['response'];
        chartState = NetworkState.error;
      }
    } catch (error) {
      chartErrorMessage = 'Something went wrong';
      chartState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getMfIndexReturns() async {
    mfIndexReturn = null;
    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository()
          .getMfIndexDetails(apiKey, selectedMfIndex?.id ?? '');

      if (data["status"] == "200") {
        Map returnJson = data["response"]["data"];

        mfIndexReturn = ReturnsModel(
          oneMtRtrns: returnJson["returns_one_month"],
          sixMtRtrns: returnJson["returns_six_months"],
          oneYrRtrns: returnJson["returns_one_year"],
          threeYrRtrns: returnJson["returns_three_years_cagr"],
          fiveYrRtrns: returnJson["returns_five_years_cagr"],
        );
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }

  /// get MF Chart data from the API
  Future<void> getMfChartData(String wSchemeCode,
      {int years = 1, bool fetchIndexReturn = false}) async {
    indexChartData.clear();
    chartDataResult.clear();
    update();

    try {
      chartState = NetworkState.loading;

      String apiKey = (await getApiKey())!;

      String period;
      if (isMaxTabSelected) {
        period = "max";
      } else {
        period = selectedTab! ~/ 12 >= 1
            ? '${selectedTab! ~/ 12}y'
            : '${selectedTab}m';
      }

      if (mfIndices.isEmpty) {
        await getMfIndices();
      }

      if (!isDebtFund) {
        if (selectedMfIndex != null && fetchIndexReturn) {
          await getMfIndexReturns();
        }
      }

      String mfIndexId = selectedMfIndex?.id ?? '';
      String queryParams =
          '?period=$period&scheme_wpcs=${fund?.wpc}&stockids=$mfIndexId';

      var data = await StoreRepository().getMfChartDatav2(apiKey, queryParams);

      if (data["status"] == "200") {
        // var schemeNavData = response.data!['metahouse']['schemeNavData'];
        List? schemeResult = data["response"]["data"]["schemes"][fund?.wpc];

        if (schemeResult != null) {
          // List result = schemeNavData['navData'];
          List<ChartDataModel> chartData = [];
          schemeResult.forEach((data) {
            chartData.add(
              ChartDataModel(
                  DateTime.parse(data[0]).millisecondsSinceEpoch,
                  WealthyCast.toDouble(data[1])!,
                  WealthyCast.toDouble(data[3])!),
            );
          });

          chartDataResult = chartData;
          chartState = NetworkState.loaded;

          try {
            List? indexResult =
                data["response"]?["data"]?["stocks"]?[mfIndexId];

            if (indexResult != null) {
              indexResult.forEach((data) {
                indexChartData.add(
                  ChartDataModel(
                    DateTime.parse(data[0]).millisecondsSinceEpoch,
                    WealthyCast.toDouble(data[1])!,
                    WealthyCast.toDouble(data[2])!,
                  ),
                );
              });
            }
          } catch (error) {
            LogUtil.printLog(error);
          }
        } else {
          chartErrorMessage = dataNotPresentText;
          chartState = NetworkState.error;
        }
      } else {
        // chartErrorMessage = response.exception!.graphqlErrors[0].message;
        chartDataResult = [];
        chartState = NetworkState.error;
      }
    } catch (error) {
      chartState = NetworkState.error;
      chartErrorMessage = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> getMfIndices() async {
    mfIndices.clear();
    fetchMfIndiceState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      var data = await StoreRepository().getMfIndices(apiKey);

      if (data["status"] == "200") {
        data["response"]["data"].forEach((e) {
          mfIndices.add(MfIndexModel.fromJson(e));
        });

        selectedMfIndex = mfIndices.first;
        fetchMfIndiceState = NetworkState.loaded;
      } else {
        fetchMfIndiceState = NetworkState.error;
      }
    } catch (error) {
      fetchMfIndiceState = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateSelectedMfIndex(MfIndexModel index) async {
    if (index != selectedMfIndex) {
      selectedMfIndex = index;
      getChartData(fetchIndexReturn: true);
    }
  }
}
