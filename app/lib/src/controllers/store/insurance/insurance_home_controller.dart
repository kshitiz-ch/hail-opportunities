import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class InsuranceHomeController extends GetxController {
  // Fields
  late List<BannerModel> insuranceBanners;
  NetworkState? insuranceBannerState;
  String? apiKey = '';
  String? insuranceBannerErrorMessage = '';
  bool isAgentFixed = true;

  @override
  void onInit() {
    insuranceBannerState = NetworkState.loading;
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    isAgentFixed = await getIsAgentFixed();
    getInsuranceBanner();
  }

  Future<void> getInsuranceBanner() async {
    insuranceBannerState = NetworkState.loading;
    update();

    try {
      apiKey = await getApiKey();
      var response = await StoreRepository().getInsuranceBannerData();

      if (response['status'] == '200') {
        final data = (SizeConfig().isTabletDevice
            ? response['response']['tablet']
            : response['response']['mobile']) as List;
        insuranceBanners = data
            .map<BannerModel>(
              (item) => BannerModel.fromJson(item),
            )
            .toList();
        insuranceBannerState = NetworkState.loaded;
      } else {
        insuranceBannerErrorMessage = response['response'];
        insuranceBannerState = NetworkState.error;
      }
    } catch (error) {
      insuranceBannerErrorMessage = 'Something went wrong';
      insuranceBannerState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<String?> getProposalUrl(InsuranceModel product, context) async {
    String? proposalUrl;

    try {
      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      final payload = {
        "agent_id": agentId,
        "user_id": null,
        "product_category": product.category,
        "product_type": product.productType,
        "product_type_variant": product.productVariant,
        "lumsum_amount": 0,
        "product_extras": null,
      };

      var response =
          await ProposalRepository().getProposalUrl(apiKey, agentId, payload);

      if (response['status'] == "200") {
        proposalUrl = response['response']['customer_url'];
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    return proposalUrl;
  }
}
