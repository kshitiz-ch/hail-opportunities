import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/credit_card_product_model.dart';
import 'package:core/modules/store/models/credit_card_promotion_model.dart';
import 'package:core/modules/store/models/credit_card_summary_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CreditCardsController extends GetxController {
  String? proposalUrl = '';

  NetworkState proposalUrlState = NetworkState.loaded;
  NetworkState creditCardApplicationListDetailState = NetworkState.loading;
  NetworkState creditCardApplicationDetailState = NetworkState.loading;
  NetworkState creditCardSummaryState = NetworkState.loading;
  NetworkState creditCardPromotionState = NetworkState.loading;
  NetworkState creditCardResumeState = NetworkState.cancel;

  String creditCardApplicationListingErrorMessage = '';
  String creditCardApplicationDetailErrorMessage = '';
  String creditCardSummaryErrorMessage = '';
  String creditCardPromotionErrorMessage = '';
  String creditCardResumeUrl = '';

  bool showLoadingState = true;

  List<CreditCardProductModel> creditCardApplicationList =
      <CreditCardProductModel>[];
  CreditCardSummaryModel? creditCardSummaryModel;
  CreditCardProductModel? selectedCreditCardDetail;
  CreditCardPromotionModel? creditCardPromotionModel;

  @override
  void onInit() {
    super.onInit();
    getCreditCardSummary();
    getCreditCardPromotionalDetails();
  }

  Future<void> getCreditCardProposalUrl(BuildContext context) async {
    try {
      proposalUrlState = NetworkState.loading;

      // initiate screen loader
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      final payload = {
        "agent_id": agentId.toString(),
      };

      final response = await StoreRepository()
          .getCreditCardProposalUrl(apiKey ?? '', payload);

      if (response['status'] == "200") {
        proposalUrl = response['response']['redirect_url'];
        showToast(text: "Opening credit card proposal form");
        // launch(proposalUrl);
        proposalUrlState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        proposalUrlState = NetworkState.error;
      }
    } catch (error) {
      proposalUrlState = NetworkState.error;
      showToast(text: "Failed to get proposal url. Please try again.");
    } finally {
      // close screen loader
      AutoRouter.of(context).popForced();
      update();
    }
  }

  Future<void> getCreditCardApplicationListingDetails() async {
    try {
      creditCardApplicationListDetailState = NetworkState.loading;
      update();

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      // for testing purposes
      // agentId = 123456;

      final response = await StoreRepository()
          .getCreditCardListingDetail(apiKey ?? '', agentId.toString());

      if (response['status'] == "200") {
        creditCardApplicationList = ((response['response']) as List)
            .map(
              (json) => CreditCardProductModel.fromJson(json),
            )
            .toList();
        creditCardApplicationListDetailState = NetworkState.loaded;
      } else {
        creditCardApplicationListingErrorMessage =
            handleApiError(response) ?? genericErrorMessage;
        creditCardApplicationListDetailState = NetworkState.error;
      }
    } catch (error) {
      creditCardApplicationListingErrorMessage = genericErrorMessage;
      creditCardApplicationListDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getCreditCardApplicationDetail(String externalID) async {
    try {
      creditCardApplicationDetailState = NetworkState.loading;
      update();

      String? apiKey = await getApiKey();
      // for testing purposes
      // externalID = 'cc_C5zxdKTmfSu2iWxb7jYZ65';

      final response =
          await StoreRepository().getCreditCardDetail(apiKey ?? '', externalID);

      if (response['status'] == "200") {
        selectedCreditCardDetail =
            CreditCardProductModel.fromJson(response['response']);

        creditCardApplicationDetailState = NetworkState.loaded;
      } else {
        creditCardApplicationDetailErrorMessage =
            handleApiError(response) ?? genericErrorMessage;
        creditCardApplicationDetailState = NetworkState.error;
      }
    } catch (error) {
      creditCardApplicationDetailErrorMessage = genericErrorMessage;
      creditCardApplicationDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getCreditCardSummary() async {
    try {
      creditCardSummaryState = NetworkState.loading;
      update();

      String? apiKey = await getApiKey();
      int? agentId = await getAgentId();

      // for testing purposes
      // externalID = 'cc_C5zxdKTmfSu2iWxb7jYZ65';

      final response = await StoreRepository().getCreditCardSummary(
        apiKey ?? '',
        agentId.toString(),
      );

      if (response['status'] == "200") {
        creditCardSummaryModel = CreditCardSummaryModel.fromJson(
          response['response']['credit_card'],
        );

        creditCardSummaryState = NetworkState.loaded;
      } else {
        creditCardSummaryErrorMessage =
            handleApiError(response) ?? genericErrorMessage;
        creditCardSummaryState = NetworkState.error;
      }
    } catch (error) {
      creditCardSummaryErrorMessage = genericErrorMessage;
      creditCardSummaryState = NetworkState.error;
    } finally {
      if (creditCardPromotionState != NetworkState.loading) {
        showLoadingState = false;
      }
      update();
    }
  }

  Future<void> getCreditCardPromotionalDetails() async {
    try {
      creditCardPromotionState = NetworkState.loading;
      update();

      String? apiKey = await getApiKey();
      int? agentId = await getAgentId();

      final response = await StoreRepository().getCreditCardPromotionalDetails(
        apiKey ?? '',
        agentId.toString(),
      );

      if (response['status'] == "200") {
        creditCardPromotionModel =
            CreditCardPromotionModel.fromJson(response['response']);
        creditCardPromotionState = NetworkState.loaded;
      } else {
        creditCardPromotionErrorMessage =
            handleApiError(response) ?? genericErrorMessage;
        creditCardPromotionState = NetworkState.error;
      }
    } catch (error) {
      creditCardPromotionErrorMessage = genericErrorMessage;
      creditCardPromotionState = NetworkState.error;
    } finally {
      if (creditCardSummaryState != NetworkState.loading) {
        showLoadingState = false;
      }
      update();
    }
  }

  Future<void> getCreditCardResumeURL(
      String externalID, BuildContext context) async {
    try {
      creditCardResumeState = NetworkState.loading;
      // initiate screen loader
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );

      String? apiKey = await getApiKey();

      final response = await StoreRepository().getCreditCardResumeURL(
        apiKey ?? '',
        externalID,
      );

      if (response['status'] == "200") {
        creditCardResumeUrl = response['response']['redirect_url'];
        showToast(text: "Opening credit card application resume form");
        creditCardResumeState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        creditCardResumeState = NetworkState.error;
      }
    } catch (error) {
      showToast(text: "Failed to get resume url. Please try again.");
      creditCardResumeState = NetworkState.error;
    } finally {
      // close screen loader
      AutoRouter.of(context).popForced();
      update();
    }
  }
}
