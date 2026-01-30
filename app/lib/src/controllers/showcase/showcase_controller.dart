import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

enum showCaseIds {
  HomeSearchBar,
  StoreSearchBar,
  AddFundMainButton,
  AmountTextField,
  FilterFunds,
  ApplyFilterButton,
  MutualFundAddButton,
  ViewBasketButton,
  BasketOverviewContinue,
  BasketDetailContinue,
  SelectClientSearch,
  SendProposalToClient
}

extension ShowCaseExtension on showCaseIds {
  String get id {
    switch (this) {
      case showCaseIds.HomeSearchBar:
        return 'home-search-bar';
      case showCaseIds.StoreSearchBar:
        return 'store-search-bar';
      case showCaseIds.AddFundMainButton:
        return 'add-fund-main-button';
      case showCaseIds.AmountTextField:
        return 'amount-text-field';
      case showCaseIds.ViewBasketButton:
        return 'view-basket-button';
      case showCaseIds.BasketOverviewContinue:
        return 'basket-overview-continue';
      case showCaseIds.BasketDetailContinue:
        return 'basket-detail-continue';
      case showCaseIds.SelectClientSearch:
        return 'select-client-search';
      case showCaseIds.SendProposalToClient:
        return 'send-proposal-to-client';
      // TODO: Separate flow, kept for future updates
      case showCaseIds.FilterFunds:
        return 'filter-funds';
      case showCaseIds.ApplyFilterButton:
        return 'apply-filter-button';
      case showCaseIds.MutualFundAddButton:
        return 'mutual-fund-add-button';
      default:
        return '';
    }
  }
}

List showCaseList = [
  {
    'id': showCaseIds.HomeSearchBar.id,
    'title': 'New Global Search 👆',
    'description': 'Enter fund name to search across all products '
  },
  {
    'id': showCaseIds.AddFundMainButton.id,
    'title': 'Click to Add Fund 👇',
    'description': 'This will Add fund to your basket'
  },
  {
    'id': showCaseIds.AmountTextField.id,
    'title': 'Enter Amount to be invested 👆',
    'description': ''
  },
  {
    'id': showCaseIds.ViewBasketButton.id,
    'title': 'View funds added in your basket 👇',
    'description': ''
  },
  {
    'id': showCaseIds.BasketOverviewContinue.id,
    'title': 'Click continue to proceed 👇',
    'description': ''
  },
  {
    'id': showCaseIds.BasketDetailContinue.id,
    'title': 'Click to select a client 👇',
    'description': ''
  },
  {
    'id': showCaseIds.SelectClientSearch.id,
    'title': 'Search for a client and select to proceed 👆',
    'description': ''
  },
  {
    'id': showCaseIds.SendProposalToClient.id,
    'title': 'Send proposal to your selected client 👇',
    'description': ''
  },
  // {
  //   'id': showCaseIds.FilterFunds.id,
  //   'title': 'Click to filter Funds 👆',
  //   'description': ''
  // },
  // {
  //   'id': showCaseIds.ApplyFilterButton.id,
  //   'title': 'Apply the filters to your search',
  //   'description': ''
  // },
  // {
  //   'id': showCaseIds.MutualFundAddButton.id,
  //   'title': 'Click to Add Fund quickly 👆',
  //   'description': ''
  // }
];

List storeShowCaseList = [
  {
    'id': showCaseIds.StoreSearchBar.id,
    'title': 'New Global Search 👆',
    'description': 'Enter fund name to search across all products '
  },
  ...showCaseList.sublist(1)
];

class ShowCaseController extends GetxController {
  GlobalKey resourcesShowcaseKey = GlobalKey();
  List currentActiveList = [];

  String activeShowCaseId = '';
  int activeShowCaseIndex = -1;
  bool isShowCaseVisibleCurrently = false;

  onInit() async {
    currentActiveList = [...showCaseList];

    final SharedPreferences sharedPreferences = await prefs;

    // * uncomment following to reset on app restart
    // await sharedPreferences.remove('mf_proposal_showcase_index');

    bool shouldShowProposalCoachMarks =
        (sharedPreferences.getBool("show_proposal_coachmarks")) ?? false;

    if (shouldShowProposalCoachMarks) {
      getActiveShowCase();
    }

    super.onInit();
  }

  Future<bool> checkMfBasketExists() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File file = File('$path/basket.json');
      String jsonData = await file.readAsString();
      if (jsonData.isNullOrEmpty) {
        return false;
      } else {
        Map basket = jsonDecode(jsonData);
        return basket.isNotEmpty;
      }
    } catch (error) {
      return false;
    }
  }

  Future<String> getActiveShowCase() async {
    final SharedPreferences sharedPreferences = await prefs;

    bool isMfBasketExists = await checkMfBasketExists();

    if (isMfBasketExists || SizeConfig().isTabletDevice) {
      sharedPreferences.setInt("mf_proposal_showcase_index", -1);
      activeShowCaseIndex = -1;
      return '';
    }

    int currentShowCaseIndex =
        sharedPreferences.get("mf_proposal_showcase_index") as int? ?? 0;

    //* If not in length of showCase List
    if (currentShowCaseIndex > currentActiveList.length - 1 ||
        currentShowCaseIndex == -1) {
      activeShowCaseIndex = -1;
      return '';
    }

    bool shouldShowNewFeatureDetails = sharedPreferences
            .getBool(SharedPreferencesKeys.showNewFeatureDetails) ??
        false;

    bool isNewUpdateFeatureViewed = sharedPreferences
            .getBool(SharedPreferencesKeys.isNewUpdateFeatureViewed) ??
        false;

    if (shouldShowNewFeatureDetails &&
        !isNewUpdateFeatureViewed &&
        currentShowCaseIndex == 0) {
      // Switch showcase list to store showcase list since home screen has new update feature botttomsheet opened
      currentActiveList = storeShowCaseList;
    }

    activeShowCaseId = currentActiveList[currentShowCaseIndex]['id'] ?? '';
    activeShowCaseIndex = currentShowCaseIndex;
    update(['update-showcase-index']);

    return currentActiveList[currentShowCaseIndex]['id'] ?? '';
  }

  void setShowCaseVisibleCurrently(bool val) {
    isShowCaseVisibleCurrently = val;
    update();
  }

  Future<void> setActiveShowCase() async {
    isShowCaseVisibleCurrently = false;

    try {
      if (activeShowCaseIndex == -1) return;

      if (activeShowCaseIndex < currentActiveList.length - 1) {
        activeShowCaseIndex++;
      } else {
        activeShowCaseIndex = -1;
      }

      final SharedPreferences sharedPreferences = await prefs;

      await sharedPreferences.setInt(
          "mf_proposal_showcase_index", activeShowCaseIndex);

      if (activeShowCaseIndex == -1) {
        activeShowCaseId = '';
      } else {
        activeShowCaseId = currentActiveList[activeShowCaseIndex]['id'] ?? '';
      }
      update(['update-showcase-index']);
    } catch (error) {
      LogUtil.printLog(
          'error occured while setting value $activeShowCaseIndex');
      LogUtil.printLog('error in setActiveShowCase $error');
    }
  }

  Future<void> switchToStoreShowCaseList() async {
    try {
      activeShowCaseIndex = 0;
      activeShowCaseId = showCaseIds.StoreSearchBar.id;

      // Switch to show case list that replaces home search bar with store search bar
      currentActiveList = storeShowCaseList;

      final SharedPreferences sharedPreferences = await prefs;
      await sharedPreferences.setInt(
          "mf_proposal_showcase_index", activeShowCaseIndex);

      update(['update-showcase-index']);
    } catch (error) {
      LogUtil.printLog(
          'error occured while setting value $activeShowCaseIndex');
      LogUtil.printLog('error in setActiveShowCase $error');
    }
  }

  void disableShowCase() {
    activeShowCaseIndex = -1;
    activeShowCaseId = '';
    update(['update-showcase-index']);
  }

  Future<void> startResourcesShowcase(BuildContext context) async {
    final SharedPreferences sharedPreferences = await prefs;
    bool isViewed =
        sharedPreferences.getBool('resources_showcase_viewed') ?? false;

    if (!isViewed) {
      // Add delay to ensure widget tree is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        ShowCaseWidget.of(context).startShowCase([resourcesShowcaseKey]);
        sharedPreferences.setBool('resources_showcase_viewed', true);
      });
    }
  }
}
