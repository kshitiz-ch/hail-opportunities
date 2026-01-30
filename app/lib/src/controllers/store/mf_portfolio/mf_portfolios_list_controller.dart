import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MfPortfoliosListController extends GetxController {
  String? apiKey;

  MFPortfolioModel mutualFundsResult = MFPortfolioModel();
  List<GoalSubtypeModel> wealthyPortfolios = [];
  AdvisorVideoModel? productVideo;

  NetworkState mutualFundsState = NetworkState.cancel;
  NetworkState productVideoState = NetworkState.cancel;
  String? mutualFundsErrorMessage;

  bool isProductVideoViewed = false;

  @override
  void onInit() {
    getMututalFunds();
    getProductVideo();
    super.onInit();
  }

  @override
  void dispose() {
    // _debounce?.cancel();
    // searchController.dispose();
    // searchBarFocusNode?.dispose();
    super.dispose();
  }

  Future<void> getProductVideo() async {
    try {
      var videoResponse = await AdvisorOverviewRepository()
          .getProductVideos(ProductVideosType.MF_PORTFOLIO);
      if (videoResponse['status'] == '200') {
        var video = videoResponse['response'];
        productVideo = AdvisorVideoModel.fromJson(video);

        isProductVideoViewed =
            await checkProductVideoViewed(ProductVideosType.MF_PORTFOLIO);

        productVideoState = NetworkState.loaded;
      } else {
        productVideoState = NetworkState.error;
      }
    } catch (error) {
      productVideoState = NetworkState.error;
    } finally {
      update(['product-video']);
    }
  }

  Future<dynamic> getMututalFunds() async {
    wealthyPortfolios.clear();
    mutualFundsState = NetworkState.loading;
    update(['mutual-funds']);

    try {
      apiKey = await getApiKey();
      // wealthyPortfolios
      var response = await StoreRepository().getMutualFundsData(apiKey!);

      if (response['status'] == '200') {
        mutualFundsResult = MFPortfolioModel.fromJson(response['response']);
        for (MFProductModel product in (mutualFundsResult.products ?? [])) {
          for (GoalSubtypeModel goalSubtype in (product.goalSubtypes ?? [])) {
            if (mfBasketPortfolioSubtypes
                .contains(goalSubtype.productVariant)) {
              wealthyPortfolios.add(goalSubtype);
            }

            if (wealthyPortfolios.length == mfBasketPortfolioSubtypes.length) {
              break;
            }
          }

          if (wealthyPortfolios.length == mfBasketPortfolioSubtypes.length) {
            break;
          }
        }
        mutualFundsState = NetworkState.loaded;
      } else {
        mutualFundsErrorMessage = response['response'];
        mutualFundsState = NetworkState.error;
      }
    } catch (error) {
      mutualFundsErrorMessage = 'Something went wrong';
      mutualFundsState = NetworkState.error;
    } finally {
      update(['mutual-funds']);
    }
  }

  getMfBasketPortfolios() {}
}
