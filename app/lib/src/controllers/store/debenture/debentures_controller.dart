import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/store/models/popular_products_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DebenturesController extends GetxController {
  // Fields
  DebenturesModel debenturesResult = DebenturesModel(products: []);

  NetworkState? debenturesState;

  String? apiKey = '';
  String? debenturesErrorMessage = '';

  @override
  void onInit() {
    debenturesState = NetworkState.loading;

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getDebentures();

    super.onReady();
  }

  /// get Debentures from the API
  Future<void> getDebentures() async {
    debenturesState = NetworkState.loading;
    update();

    try {
      var response = await StoreRepository().getDebentures(apiKey!);

      if (response['status'] == '200') {
        debenturesResult = DebenturesModel.fromJson(response['response']);
        debenturesState = NetworkState.loaded;
      } else {
        debenturesErrorMessage = response['response'];
        debenturesState = NetworkState.error;
      }
    } catch (error) {
      debenturesErrorMessage = 'Something went wrong';
      debenturesState = NetworkState.error;
    } finally {
      update();
    }
  }
}
