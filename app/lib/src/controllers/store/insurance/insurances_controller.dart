import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/insurance_detail_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class InsurancesController extends GetxController {
  // Fields
  InsuranceListModel insurancesResult = InsuranceListModel(products: []);

  NetworkState? insurancesState;

  String? apiKey = '';
  String? insurancesErrorMessage = '';

  NetworkState? proposalUrlState;

  var proposalUrl;

  @override
  void onInit() {
    insurancesState = NetworkState.loading;

    super.onInit();
  }

  @override
  Future<void> onReady() async {
    apiKey = await getApiKey();
  }

  /// get Insurances from the API
  Future<void> getInsurances() async {
    insurancesState = NetworkState.loading;
    update();

    try {
      apiKey = await getApiKey();
      var response = await StoreRepository().getInsurancesCatData(apiKey!);

      if (response['status'] == '200') {
        insurancesResult = InsuranceListModel.fromJson(response['response']);
        insurancesState = NetworkState.loaded;
      } else {
        insurancesErrorMessage = response['response'];
        insurancesState = NetworkState.error;
      }
    } catch (error) {
      insurancesErrorMessage = 'Something went wrong';
      insurancesState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<bool?> shouldOpenWebView(String productVariant) async {
    bool? viaWebView = false;
    try {
      final data =
          await StoreRepository().getInsuranceProductDetail(productVariant);

      if (data['status'] == "200") {
        InsuranceDetailModel insuranceDetailModel =
            InsuranceDetailModel.fromJson(data['response']);
        viaWebView = insuranceDetailModel.viaWebView;
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    return viaWebView;
  }

  Future<void> getProposalUrl(
      BuildContext context, InsuranceModel insuranceData,
      {bool viaWebView = false}) async {
    try {
      proposalUrlState = NetworkState.loading;
      update([GetxId.createProposal]);
      // initiate screen loader
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );

      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      final payload = {
        "agent_id": agentId,
        "user_id": null,
        "product_category": insuranceData.category,
        "product_type": insuranceData.productType,
        "product_type_variant": insuranceData.productVariant,
        "lumsum_amount": 0,
        "product_extras": null,
      };

      var response =
          await ProposalRepository().getProposalUrl(apiKey, agentId, payload);

      if (response['status'] == "200") {
        proposalUrl = response['response']['customer_url'];
        showToast(
          text: 'Opening ${insuranceData.title!.toTitleCase()} insurance',
          context: context,
        );
        if (viaWebView) {
          proposalUrl = proposalUrl;
        } else {
          launch(proposalUrl);
        }
        proposalUrlState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        proposalUrlState = NetworkState.error;
      }
    } catch (error) {
      proposalUrlState = NetworkState.error;
      showToast(text: "Failed to create proposal. Please try again.");
    } finally {
      // close screen loader
      AutoRouter.of(context).popForced();
      update([GetxId.createProposal]);
    }
  }
}
