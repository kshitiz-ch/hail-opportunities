import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/broking/models/broking_plan_model.dart';
import 'package:core/modules/broking/resources/broking_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class DematProposalController extends GetxController {
  ApiResponse dematDetailsResponse = ApiResponse();
  ApiResponse brokingPlansResponse = ApiResponse();
  ApiResponse proposalApiResponse = ApiResponse();
  ApiResponse defaultBrokingPlanResponse = ApiResponse();

  List<BrokingPlanModel> brokingPlans = [];

  // If partner coming from any client page
  Client? client;

  List<Client> selectedClients = [];

  BannerModel? dematBenefitsBanner;
  List<BannerModel> carouselBanners = [];

  DematDetailsModel? dematDetails;
  ApiResponse dematConsent = new ApiResponse();

  // Demat overview screens client list
  ScrollController scrollController = ScrollController();

  bool termsConditionsAgreed = true;

  BrokingPlanModel? planSelected;
  BrokingPlanModel? defaultPlan;

  bool isAuthorised = false;
  ApiResponse partnerApStatusResponse = new ApiResponse();

  // bool get isAuthorised {
  //   if (Get.isRegistered<HomeController>()) {
  //     AgentModel? agent =
  //         Get.find<HomeController>().advisorOverviewModel?.agent;
  //     LogUtil.printLog(agent?.brokingApId);
  //     return (Get.find<HomeController>()
  //                 .advisorOverviewModel
  //                 ?.agent
  //                 ?.brokingApId ??
  //             "")
  //         .isNotNullOrEmpty;
  //   }
  //   return false;
  // }

  @override
  void onInit() {
    super.onInit();

    getPartnerApStatus();
    getBrokingPlans();
    getStoreDematDetails();
  }

  DematProposalController({this.client}) {
    if (client != null) {
      selectedClients.add(client!);
    }
  }

  Future<void> getDematBanners() async {
    carouselBanners.clear();

    try {
      var response = await StoreRepository().getDematBanners();

      if (response['status'] == '200') {
        final data = response['response'] as List;
        data.forEach((e) {
          BannerModel banner = BannerModel.fromJson(e);
          if (banner.isCarousel == true) {
            carouselBanners.add(banner);
          } else {
            dematBenefitsBanner = banner;
          }
        });
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void updatePlanSelected(BrokingPlanModel newPlan) {
    planSelected = BrokingPlanModel.clone(newPlan);
    update();
  }

  Future<void> getBrokingPlans() async {
    brokingPlansResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';

      QueryResult response = await BrokingRepository().getBrokingPlans(apiKey);
      if (!response.hasException) {
        response.data!["partnerAvailableWealthyBrokingApPlans"].forEach((x) {
          brokingPlans.add(BrokingPlanModel.fromJson(x));
        });

        BrokingPlanModel? selectedPlan;
        if (response.data!["partnerWealthyBrokingApData"] != null) {
          BrokingApModel brokingAp = BrokingApModel.fromJson(
              response.data!["partnerWealthyBrokingApData"]);

          if (brokingAp.defaultBrokeragePlan.isNotNullOrEmpty) {
            // getting defaultBrokeragePlan of partner
            selectedPlan = brokingPlans.firstWhereOrNull(
                (plan) => plan.planCode == brokingAp.defaultBrokeragePlan);
          } else {
            // getting isWealthyDefault plan for partner if defaultBrokeragePlan is empty
            selectedPlan = brokingPlans
                .firstWhereOrNull((plan) => plan.isWealthyDefault ?? false);
          }
        }
        if (selectedPlan == null) {
          // using BROKERAGE9 as default plan if api is not giving any data
          selectedPlan = brokingPlans
              .firstWhereOrNull((plan) => plan.planCode == "BROKERAGE9");
        }
        if (selectedPlan != null) {
          defaultPlan = BrokingPlanModel.clone(selectedPlan);
          planSelected = BrokingPlanModel.clone(selectedPlan);
        }

        brokingPlansResponse.state = NetworkState.loaded;
      } else {
        brokingPlansResponse.state = NetworkState.error;
        brokingPlansResponse.message =
            response.exception!.graphqlErrors.first.message;
      }
    } catch (error) {
      brokingPlansResponse.state = NetworkState.error;
      brokingPlansResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> getPartnerApStatus() async {
    partnerApStatusResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';
      final agentId = (await getAgentId()).toString();
      QueryResult response =
          await BrokingRepository().getPartnerApStatus(apiKey, agentId);
      if (!response.hasException) {
        final partnerApStatusData =
            Map.from(response.data?['hydra']?['partnerApStatus']);
        isAuthorised = partnerApStatusData.entries.any((partnerApData) {
          return (WealthyCast.toBool(partnerApData.value) ?? false);
        });
        partnerApStatusResponse.state = NetworkState.loaded;
      } else {
        partnerApStatusResponse.state = NetworkState.error;
        partnerApStatusResponse.message =
            response.exception!.graphqlErrors.first.message;
      }
    } catch (error) {
      partnerApStatusResponse.state = NetworkState.error;
      partnerApStatusResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> updateDefaultBrokingPlan() async {
    defaultBrokingPlanResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      String agentExternalId = await getAgentExternalId() ?? "";
      QueryResult response = await BrokingRepository().updateDefaultBrokingPlan(
          apiKey: apiKey,
          agentId: agentExternalId,
          planCode: planSelected!.planCode!);
      if (!response.hasException) {
        defaultPlan = BrokingPlanModel.clone(planSelected!);

        defaultBrokingPlanResponse.state = NetworkState.loaded;
      } else {
        defaultBrokingPlanResponse.state = NetworkState.error;
        defaultBrokingPlanResponse.message =
            response.exception!.graphqlErrors.first.message;
      }
    } catch (error) {
      defaultBrokingPlanResponse.state = NetworkState.error;
      defaultBrokingPlanResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> getStoreDematDetails() async {
    dematDetailsResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';

      var response = await StoreRepository().getStoreDematDetails(apiKey);
      if (response["status"] == "200") {
        dematDetails = DematDetailsModel.fromJson(response["response"]);
        await getDematBanners();
        dematDetailsResponse.state = NetworkState.loaded;
      } else {
        dematDetailsResponse.state = NetworkState.error;
        dematDetailsResponse.message =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (error) {
      dematDetailsResponse.state = NetworkState.error;
      dematDetailsResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<ApiResponse> updateUserBrokeragePlan() async {
    ApiResponse response = ApiResponse();
    try {
      String apiKey = await getApiKey() ?? '';

      var data = await BrokingRepository().updateUserBrokeragePlan(
          apiKey: apiKey,
          userId: selectedClients.first.taxyID!,
          planCode: planSelected!.planCode!);

      if (data.hasException) {
        response.state = NetworkState.error;
        response.message = data.exception!.graphqlErrors.first.message;
      } else {
        response.state = NetworkState.loaded;
      }
    } catch (error) {
      response.state = NetworkState.error;
      response.message = "Something went wrong. Please try again";
    }

    return response;
  }

  Future<void> createProposal() async {
    proposalApiResponse.state = NetworkState.loading;
    update(['proposal']);

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        "clients": selectedClients.map((client) => client.taxyID).toList()
      };

      ApiResponse updateUserPlanResponse = await updateUserBrokeragePlan();

      if (updateUserPlanResponse.state != NetworkState.loaded) {
        proposalApiResponse.state = NetworkState.error;
        proposalApiResponse.message = updateUserPlanResponse.message;
        return;
      }

      var response =
          await StoreRepository().createDematProposal(apiKey, payload);

      if (response["status"] == "200") {
        proposalApiResponse.state = NetworkState.loaded;
      } else {
        proposalApiResponse.state = NetworkState.error;
        proposalApiResponse.message =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (error) {
      proposalApiResponse.state = NetworkState.error;
      proposalApiResponse.message = 'Something went wrong';
    } finally {
      update(['proposal']);
    }
  }

  Future<void> auditDematConsent() async {
    try {
      dematConsent.state = NetworkState.loading;
      update(['demat-consent']);
      final apiKey = await getApiKey();
      final agentExternalId = await getAgentExternalId();
      Map<String, dynamic> payload = {
        "agent_id": agentExternalId,
        "consent": true
      };
      final data = await StoreRepository().auditDematConsent(apiKey!, payload);
      LogUtil.printLog('auditDematConsent data => ${data.toString()}');
      if (data['status'] == "200") {
        dematConsent.state = NetworkState.loaded;
      } else {
        dematConsent.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('auditDematConsent error => ${error.toString()}');
      dematConsent.state = NetworkState.error;
    } finally {
      update(['demat-consent']);
    }
  }
}

class DematDetailsModel {
  PricingPlan? pricingPlan;
  List<Incentive>? incentives;
  String? referralUrl;

  DematDetailsModel.fromJson(Map<String, dynamic> json) {
    pricingPlan = json["pricing_plan"] != null
        ? PricingPlan.fromJson(json["pricing_plan"])
        : null;
    incentives = List<Incentive>.from(
      WealthyCast.toList(json["incentives"]).map(
        (e) {
          Incentive incentive = Incentive.fromJson(e);
          return incentive;
        },
      ),
    );
    referralUrl = json["referral_url"];
  }
}

class Incentive {
  String? margin;
  String? value;

  Incentive.fromJson(Map<String, dynamic> json) {
    margin = WealthyCast.toStr(json["margin"]);
    value = WealthyCast.toStr(json["value"]);
  }
}

class PricingPlan {
  String? openingCharges;
  String? amcCharges;
  String? equityDeliveryCharges;
  String? equityCharges;
  String? equityIntradayCharges;
  String? equityOptions;

  PricingPlan.fromJson(Map<String, dynamic> json) {
    openingCharges = WealthyCast.toStr(json["opening_charges"]);
    amcCharges = WealthyCast.toStr(json["amc_charges"]);
    equityDeliveryCharges = WealthyCast.toStr(json["equity_delivery_charges"]);
    equityCharges = WealthyCast.toStr(json["equity_charges"]);
    equityIntradayCharges = WealthyCast.toStr(json["equity_intraday_charges"]);
    equityOptions = WealthyCast.toStr(json["equity_options"]);
  }
}
