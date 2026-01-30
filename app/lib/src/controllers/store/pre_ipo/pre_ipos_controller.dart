import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PreIPOsController extends GetxController {
  // Fields
  UnlistedStockModel preIPOsResult = UnlistedStockModel(products: []);
  AdvisorVideoModel? productVideo;

  NetworkState? preIPOsState;
  NetworkState? productVideoState;

  String? apiKey = '';

  bool isProductVideoViewed = false;
  String? preIPOsErrorMessage = '';

  @override
  void onInit() {
    preIPOsState = NetworkState.loading;
    getProductVideo();

    super.onInit();
  }

  @override
  Future<void> onReady() async {
    apiKey = await getApiKey();
    getPreIPOs();

    super.onReady();
  }

  /// get Pre-IPOs from the API
  Future<void> getPreIPOs() async {
    preIPOsState = NetworkState.loading;
    update();

    try {
      String? apiKey = await getApiKey();

      var response = await StoreRepository().getUnlistedStocksData(apiKey!);

      if (response['status'] == '200') {
        preIPOsResult = UnlistedStockModel.fromJson(response['response']);
        preIPOsState = NetworkState.loaded;
      } else {
        preIPOsErrorMessage = response['response'];
        preIPOsState = NetworkState.error;
      }
    } catch (error) {
      preIPOsErrorMessage = 'Something went wrong';
      preIPOsState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getProductVideo() async {
    try {
      var videoResponse = await AdvisorOverviewRepository()
          .getProductVideos(ProductVideosType.PRE_IPO);
      if (videoResponse['status'] == '200') {
        var video = videoResponse['response'];
        productVideo = AdvisorVideoModel.fromJson(video);

        isProductVideoViewed =
            await checkProductVideoViewed(ProductVideosType.PRE_IPO);

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
}
