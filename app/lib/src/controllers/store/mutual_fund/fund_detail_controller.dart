import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

enum FundNavigationTab {
  Overview,
  ReturnRatings,
  Portfolio,
  WealthyScore,
  TopHoldings,
  Benchmark,
  Peers,
  Scheme_Details,
  FundManagement,
  RiskMeter,
  Tax
}

class FundDetailController extends GetxController {
  NetworkState fetchSchemeDataState = NetworkState.cancel;
  SchemeMetaModel? fund;

  ScrollController scrollController = ScrollController();

  int? exitLoadTime;
  String? exitLoadUnit;

  final String? wschemcode;

  // Section Keys
  FundNavigationTab? selectedTab = FundNavigationTab.Overview;

  Map<String, GlobalKey> navigationKeys = {
    // Main 4 Tabs
    FundNavigationTab.Overview.name: GlobalKey(),
    FundNavigationTab.Portfolio.name: GlobalKey(),
    FundNavigationTab.Peers.name: GlobalKey(),
    FundNavigationTab.Scheme_Details.name: GlobalKey(),

    FundNavigationTab.ReturnRatings.name: GlobalKey(),
    FundNavigationTab.WealthyScore.name: GlobalKey(),
    FundNavigationTab.TopHoldings.name: GlobalKey(),
    FundNavigationTab.Benchmark.name: GlobalKey(),
    FundNavigationTab.FundManagement.name: GlobalKey(),
    FundNavigationTab.RiskMeter.name: GlobalKey(),
    FundNavigationTab.Tax.name: GlobalKey(),
  };

  Map<String, double> navigationVisibilityPercentage = {
    FundNavigationTab.Overview.name: 0,
    FundNavigationTab.Portfolio.name: 0,
    FundNavigationTab.Peers.name: 0,
    FundNavigationTab.Scheme_Details.name: 0,
  };
//  { Overview, Portfolio, WealthyScore, TopHoldings, Benchmark, Peers, Scheme_Details, FundManagement, RiskMeter, Tax }
  FundNavigationTab? activeNavigationSection;

  bool showBottomArrowIndicator = true;

  FundGraphView selectedGraphView = FundGraphView.Historical;

  FundDetailController(this.wschemcode, this.fund) {
    if (wschemcode != null) {
      getSchemeData(wschemcode!);
    }
  }

  hideBottomArrowIndicator() {
    showBottomArrowIndicator = false;
    update(['bottom-arrow']);
  }

  updateNavigationVisibility(FundNavigationTab tab, double percentage) {
    navigationVisibilityPercentage[tab.name] = percentage;
    update(['navigation-visibility']);
  }

  updateNavigationSection(FundNavigationTab navigationSection,
      {bool disableScrolling = false}) async {
    if (navigationSection == FundNavigationTab.Portfolio ||
        navigationSection == FundNavigationTab.Peers ||
        navigationSection == FundNavigationTab.Scheme_Details) {
      if (activeNavigationSection == navigationSection) {
        selectedTab = null;
      } else {
        selectedTab = navigationSection;
      }
    }

    if (activeNavigationSection == navigationSection) {
      activeNavigationSection = null;
      update(['navigation']);
    } else {
      activeNavigationSection = navigationSection;

      update(['navigation']);
      if (!disableScrolling &&
          navigationKeys[navigationSection.name] != null &&
          navigationKeys[navigationSection.name]!.currentContext != null) {
        await Future.delayed(Duration(milliseconds: 200));
        Scrollable.ensureVisible(
          navigationKeys[navigationSection.name]!.currentContext!,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  updateNavigationTab(FundNavigationTab newTab,
      {bool disableScrolling = false}) async {
    // if (selectedTab == newTab) return;
    selectedTab = newTab;

    if (!disableScrolling && activeNavigationSection != newTab) {
      updateNavigationSection(newTab, disableScrolling: true);
    }

    update(['navigation']);
    LogUtil.printLog("selectedTab $selectedTab");
    if (selectedTab == FundNavigationTab.Overview && !disableScrolling) {
      scrollController.animateTo(
        0,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 500),
      );
    } else if (!disableScrolling && selectedTab != null) {
      await Future.delayed(Duration(milliseconds: 300));
      Scrollable.ensureVisible(
        navigationKeys[selectedTab?.name]!.currentContext!,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 500),
      );
    }
  }

  Future<void> getSchemeData(String wschemcode) async {
    fetchSchemeDataState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      final QueryResult response =
          await StoreRepository().getSchemeData(apiKey, null, wschemcode);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        fetchSchemeDataState = NetworkState.error;
      } else {
        StoreFundAllocation storeFundResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        fund = storeFundResult.schemeMetas?.first;

        fetchSchemeDataState = NetworkState.loaded;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      fetchSchemeDataState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getExitLoadDetails() async {
    try {
      String apiKey = await getApiKey() ?? '';
      final QueryResult response = await StoreRepository()
          .getSchemeExitLoadDetails(apiKey, null, fund?.wschemecode ?? '');

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
      } else {
        StoreFundAllocation storeFundResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        exitLoadTime =
            WealthyCast.toInt(storeFundResult.schemeMetas?.first.exitLoadTime);
        exitLoadUnit =
            WealthyCast.toStr(storeFundResult.schemeMetas?.first.exitLoadUnit);

        fund?.sipRegistrationStartDate = WealthyCast.toDate(
            storeFundResult.schemeMetas?.first.sipRegistrationStartDate);
      }
      LogUtil.printLog(exitLoadUnit);
    } catch (e) {
      LogUtil.printLog(e.toString());
    } finally {
      update(['exit-load']);
      update();
    }
  }
}
