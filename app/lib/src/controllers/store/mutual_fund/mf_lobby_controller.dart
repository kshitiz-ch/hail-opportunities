import 'dart:async';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';

class MfLobbyController extends GetxController {
  ApiResponse screenerResponse = ApiResponse();

  NetworkState fetchCuratedFundScreenerState = NetworkState.cancel;
  List<ScreenerModel> curatedFundScreeners = [];

  ScreenerListModel? screenerList;
  List wealthySelectFunds = [];

  Client? selectedClient;

  List<String> mfBasketPortfolioSubtypes = ["2099", "201", "202", "203"];
  Map<String, double> mfBasketPortfolioMinSipAmount = {
    "2099": 3000,
    "201": 400,
    "202": 400,
    "203": 1000
  };
  NetworkState fetchCuratedPortfolioState = NetworkState.cancel;
  List<GoalSubtypeModel> mfPortfolios = [];

  MfLobbyController({this.selectedClient});

  void onInit() {
    getCuratedFundScreeners();
    getWealthySelectScreeners();
    getCuratedMfPortfolios();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getCuratedFundScreeners() async {
    fetchCuratedFundScreenerState = NetworkState.loading;
    update(['curated-funds']);

    try {
      String apiKey = await getApiKey() ?? '';
      var response = await StoreRepository().getCuratedFundScreeners(apiKey);

      if (response["status"] == "200") {
        List<dynamic> data = response["response"]['data'];
        data.first["screeners"].forEach((e) {
          curatedFundScreeners.add(ScreenerModel.fromJson(e));
        });
        fetchCuratedFundScreenerState = NetworkState.loaded;
      } else {
        fetchCuratedFundScreenerState = NetworkState.error;
      }
    } catch (error) {
      fetchCuratedFundScreenerState = NetworkState.error;
    } finally {
      update(['curated-funds']);
    }
  }

  Future<void> getWealthySelectScreeners() async {
    screenerResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      var response = await StoreRepository().getWealthySelectScreeners(apiKey);

      if (response["status"] == "200") {
        List<dynamic> data = response["response"]['data'];
        screenerList = ScreenerListModel.fromJson(data.first);

        // if (screenerList?.screeners.isNotNullOrEmpty ?? false) {
        //   for (int index = 0;
        //       index < screenerList!.screeners!.length;
        //       index++) {
        //     ScreenerModel screener = screenerList!.screeners![index];
        //     await getSchemes(screener, index);
        //   }
        // }
        screenerResponse.state = NetworkState.loaded;
      } else {
        screenerResponse.state = NetworkState.error;
        screenerResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      screenerResponse.state = NetworkState.error;
      screenerResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<dynamic> getCuratedMfPortfolios() async {
    fetchCuratedPortfolioState = NetworkState.loading;
    update(['curated-portfolios']);

    try {
      String apiKey = await getApiKey() ?? '';
      var response = await StoreRepository().getMutualFundsData(
        apiKey,
        productVariant: mfBasketPortfolioSubtypes.join(','),
      );

      if (response['status'] == '200') {
        MFPortfolioModel mutualFundsResult =
            MFPortfolioModel.fromJson(response['response']);
        for (MFProductModel product in (mutualFundsResult.products ?? [])) {
          for (GoalSubtypeModel goalSubtype in (product.goalSubtypes ?? [])) {
            if (mfBasketPortfolioSubtypes
                .contains(goalSubtype.productVariant)) {
              goalSubtype.minSipAmount =
                  mfBasketPortfolioMinSipAmount[goalSubtype.productVariant];
              mfPortfolios.add(goalSubtype);
            }

            if (mfPortfolios.length == mfBasketPortfolioSubtypes.length) {
              break;
            }
          }

          if (mfPortfolios.length == mfBasketPortfolioSubtypes.length) {
            break;
          }
        }

        if (mfPortfolios.isEmpty) {
          throw Exception();
        }
        fetchCuratedPortfolioState = NetworkState.loaded;
      } else {
        // popularProductsErrorMessage = response['response'];
        fetchCuratedPortfolioState = NetworkState.error;
        // productSectionOrder = defaultProductSectionOrder;
      }
    } catch (error) {
      // productSectionOrder = defaultProductSectionOrder;
      // popularProductsErrorMessage = 'Something went wrong';
      fetchCuratedPortfolioState = NetworkState.error;
    } finally {
      update(['curated-portfolios']);
    }
  }
}
