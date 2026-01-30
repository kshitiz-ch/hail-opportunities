import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/models/mf/nfo_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';

class NfoDetailController extends GetxController {
  NetworkState fetchNfoDetailsState = NetworkState.cancel;
  ApiResponse nfoMinSipAmountResponse = ApiResponse();

  NfoModel? nfo;
  String? nfoWschemecode;

  NfoDetailController({this.nfo, this.nfoWschemecode}) {
    if (nfo == null) {
      getNfoDetails();
    }
  }

  void onInit() {
    super.onInit();
  }

  Future<void> getNfoDetails() async {
    fetchNfoDetailsState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      var data =
          await StoreRepository().getNfoDetails(apiKey, nfoWschemecode ?? '');
      if (data["status"] == "200") {
        nfo = NfoModel.fromJson(data["response"]);
        fetchNfoDetailsState = NetworkState.loaded;
      } else {
        fetchNfoDetailsState = NetworkState.error;
      }
    } catch (error) {
      fetchNfoDetailsState = NetworkState.error;
    } finally {
      update();
    }
  }
}
