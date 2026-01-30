import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/insurance_detail_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class InsuranceController extends GetxController {
  String proposalUrl = '';

  NetworkState createProposalState = NetworkState.loaded;
  NetworkState proposalUrlState = NetworkState.loaded;

  NetworkState insuranceProductDetailState = NetworkState.cancel;
  NetworkState getInsuranceDataState = NetworkState.cancel;

  InsuranceDetailModel? insuranceDetailModel;
  InsuranceModel? insuranceData;

  Client? selectedClient;

  String createProposalErrorMessage = '';

  String? productVariant;

  InsuranceController({this.insuranceData, this.productVariant}) {
    if (insuranceData == null && productVariant != null) {
      getInsuranceData(productVariant!);
    }
  }

  setSelectedClient(Client? client) {
    selectedClient = client;
    update();
  }

  Future<void> getInsuranceData(String productVariant) async {
    try {
      getInsuranceDataState = NetworkState.loading;
      update([GetxId.createProposal]);

      String apiKey = (await getApiKey())!;

      final data =
          await StoreRepository().getInsuranceData(apiKey, productVariant);

      if (data['status'] == "200") {
        insuranceData =
            InsuranceModel.fromJson(data['response']['products'][0]);
        getInsuranceDataState = NetworkState.loaded;
      } else {
        getInsuranceDataState = NetworkState.error;
      }
    } catch (error) {
      getInsuranceDataState = NetworkState.error;
    } finally {
      update([GetxId.createProposal]);
    }
  }

  Future<void> createProposal(InsuranceModel? product) async {
    try {
      createProposalState = NetworkState.loading;
      update([GetxId.createProposal]);

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      if (selectedClient?.isSourceContacts ?? false) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      Map<String, dynamic> extraDataMap = {
        "lumsum_amount": 0,
        "product_category": product!.category,
        "product_type": product.productType,
        "product_type_variant": product.productVariant,
        "product_extras": null,
      };

      var data = await StoreRepository().addProposals(
        agentId!,
        selectedClient?.taxyID ?? '',
        product.productVariant!,
        apiKey!,
        extraDataMap,
      );

      if (data['status'] == "200") {
        proposalUrl = data['response']['customer_url'];
        await addQueryParam();
        createProposalState = NetworkState.loaded;
      } else {
        createProposalState = NetworkState.error;
        createProposalErrorMessage =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      createProposalState = NetworkState.error;
      createProposalErrorMessage = "Something went wrong";
    } finally {
      update([GetxId.createProposal]);
    }
  }

  Future<void> getProposalUrl(InsuranceModel product, context,
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
        showToast(
          text: 'Opening ${product.title!.toTitleCase()} insurance',
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

  Future<bool> addClientFromContacts() async {
    RestApiResponse clientCreatedResponse =
        await AddClientController().addClientFromContacts(selectedClient!);
    if (clientCreatedResponse.status == 1) {
      selectedClient = clientCreatedResponse.data;
      update([GetxId.createProposal]);
      return true;
    } else {
      // createProposalErrorMessage = clientCreatedResponse.message;
      createProposalState = NetworkState.cancel;
      return false;
    }
  }

  Future<void> addQueryParam() async {
    if (proposalUrl.isNotNullOrEmpty) {
      final packageInfo = await initPackageInfo();
      proposalUrl += ('&appName=partner-app_v${packageInfo.version}');
    }
  }

  Future<void> getInsuranceProductDetail(String productVariant) async {
    try {
      insuranceProductDetailState = NetworkState.loading;
      update([GetxId.insuranceProductDetail, GetxId.createProposal]);

      final data =
          await StoreRepository().getInsuranceProductDetail(productVariant);

      if (data['status'] == "200") {
        insuranceDetailModel = InsuranceDetailModel.fromJson(data['response']);
        insuranceProductDetailState = NetworkState.loaded;
      } else {
        insuranceProductDetailState = NetworkState.error;
      }
    } catch (error) {
      insuranceProductDetailState = NetworkState.error;
    } finally {
      update([GetxId.insuranceProductDetail, GetxId.createProposal]);
    }
  }
}
