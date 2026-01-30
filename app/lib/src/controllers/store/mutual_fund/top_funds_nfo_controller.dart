import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopFundsNfoController extends GetxController {
  MfListType activeTab = MfListType.TopSelling;

  ApiResponse topSellingFundsResponse = ApiResponse();
  ApiResponse nfoResponse = ApiResponse();

  ScreenerListModel? topSellingFundsList;
  ScreenerModel? nfoScreener;

  TopFundsNfoController({this.activeTab = MfListType.Nfo});

  @override
  void onInit() {
    getTopSellingFundsNfo();
    // if (activeTab == MfListType.TopSelling) {
    //   getTopSellingFundsNfo();
    // } else if (activeTab == MfListType.Nfo) {
    //   getTopSellingFunds();
    // }
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateActiveTab(MfListType tab) {
    activeTab = tab;
    update();
  }

  Future<void> getTopSellingFundsNfo() async {
    topSellingFundsResponse.state = NetworkState.loading;
    update(['top-selling-funds']);

    try {
      String apiKey = await getApiKey() ?? '';
      var response = await StoreRepository().getTopSellingFunds(apiKey);
      if (response['status'] == '200') {
        List<dynamic> data = response["response"]['data'];
        topSellingFundsList = ScreenerListModel.fromJson(data.first);
        if (topSellingFundsList?.screeners.isNotNullOrEmpty ?? false) {
          for (ScreenerModel screener in topSellingFundsList!.screeners!) {
            if ((screener.uri ?? '').contains("nfo")) {
              nfoScreener = screener;
              break;
            }
          }
        }

        topSellingFundsResponse.state = NetworkState.loaded;
      } else {
        topSellingFundsResponse.state = NetworkState.error;
      }
    } catch (error) {
      topSellingFundsResponse.state = NetworkState.error;
    } finally {
      update(['top-selling-funds']);
    }
  }

  Future<void> getNfoList() async {
    nfoResponse.state = NetworkState.loading;
    update(['nfo']);

    try {
      String apiKey = await getApiKey() ?? '';
      var response = await StoreRepository().getTopSellingFunds(apiKey);
      if (response['status'] == '200') {
        nfoResponse.state = NetworkState.loaded;
      } else {
        nfoResponse.state = NetworkState.error;
      }
    } catch (error) {
      nfoResponse.state = NetworkState.error;
    } finally {
      update(['nfo']);
    }
  }
}
