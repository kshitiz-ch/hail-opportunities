import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum PMSNavigationTab {
  Strategy,
  Portfolio,
  Holdings,
  Risk,
}

class PMSProductController extends GetxController {
  // Fields
  NetworkState? getPMSProductDataState;
  String? apiKey;
  String? getPMSProductDataErrorMessage;
  late StoreRepository storeRepository;
  PMSProductsModel? pmsProductModel;
  TextEditingController? textEditingController;

  PMSProductController() {
    storeRepository = StoreRepository();
    getPMSProductDataState = NetworkState.loading;
    textEditingController = TextEditingController();
  }

  // Section Keys
  PMSNavigationTab? selectedTab = PMSNavigationTab.Strategy;
  PMSNavigationTab? activeNavigationSection;

  Map<String, GlobalKey> navigationKeys = {
    // Main 2 Tabs
    PMSNavigationTab.Strategy.name: GlobalKey(),
    PMSNavigationTab.Portfolio.name: GlobalKey(),

    PMSNavigationTab.Holdings.name: GlobalKey(),
    PMSNavigationTab.Risk.name: GlobalKey(),
  };

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getPMSProductData();
  }

  @override
  void dispose() {
    textEditingController!.dispose();
    super.dispose();
  }

  void updateNavigationSection(PMSNavigationTab navigationSection) async {
    if (navigationSection == PMSNavigationTab.Portfolio ||
        navigationSection == PMSNavigationTab.Holdings ||
        navigationSection == PMSNavigationTab.Risk) {
      selectedTab = PMSNavigationTab.Portfolio;

      if (activeNavigationSection == navigationSection) {
        activeNavigationSection = null;
      } else {
        activeNavigationSection = navigationSection;
        if (navigationKeys[navigationSection.name] != null &&
            navigationKeys[navigationSection.name]!.currentContext != null) {
          await Future.delayed(Duration(milliseconds: 200));
          Scrollable.ensureVisible(
            navigationKeys[navigationSection.name]!.currentContext!,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 500),
          );
        }
      }
      update(['navigation']);
    }
  }

  void updateNavigationTab(PMSNavigationTab newTab) async {
    if (selectedTab == newTab) return;
    selectedTab = newTab;

    if (selectedTab == PMSNavigationTab.Strategy) {
      activeNavigationSection = null;
    } else {
      activeNavigationSection = PMSNavigationTab.Holdings;
    }

    await Future.delayed(Duration(milliseconds: 300));

    Scrollable.ensureVisible(
      selectedTab == PMSNavigationTab.Strategy
          ? navigationKeys[selectedTab?.name]!.currentContext!
          : navigationKeys[activeNavigationSection?.name]!.currentContext!,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
    );

    update(['navigation']);
  }

  /// get PMS Product Data from the API
  Future<void> getPMSProductData() async {
    try {
      getPMSProductDataState = NetworkState.loading;
      update([GetxId.pmsProducts]);
      final response = await storeRepository.getPMSProductData(apiKey!);
      if (response['status'] != "200") {
        getPMSProductDataState = NetworkState.error;
        getPMSProductDataErrorMessage =
            getErrorMessageFromResponse(response['response']);
      } else {
        pmsProductModel = PMSProductsModel.fromJson(response['response']);
        getPMSProductDataState = NetworkState.loaded;
      }
    } catch (error) {
      getPMSProductDataErrorMessage =
          handleApiError(error) ?? genericErrorMessage;
      getPMSProductDataState = NetworkState.error;
    } finally {
      update([GetxId.pmsProducts]);
    }
  }
}
