import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/store/demat_store/widgets/demat_referral_terms_condition.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyWealthyDemat extends StatelessWidget {
  final clientDematController = Get.find<ClientDematController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wealthy Demat',
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.primaryAppv3Color,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  AllImages().wealthyDematIcon,
                  width: 180,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(top: 12, bottom: 20),
                child: Text(
                  '${clientDematController.client.name.toCapitalized()} has not created their Demat Account. Please ask Client to open their Wealthy Demat account from Wealthy Client App to get started with their Trading Journey.',
                  // '${clientDematController.client.name.toCapitalized()} has not created their Demat Account. Share proposal to your client to open their Wealthy Demat account to get started with their Trading Journey.',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w500,
                            height: 18 / 12,
                          ),
                ),
              ),
              GetBuilder<DematProposalController>(
                init: DematProposalController(
                    client: clientDematController.client),
                id: 'proposal',
                builder: (controller) {
                  return ActionButton(
                    text: 'Share Proposal',
                    showProgressIndicator:
                        controller.proposalApiResponse.state ==
                            NetworkState.loading,
                    margin: EdgeInsets.zero,
                    onPressed: () async {
                      checkDematConsent(context, controller);
                    },
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onShareProposal(
      BuildContext context, DematProposalController controller) async {
    int? agentKycStatus = await getAgentKycStatus();
    if (agentKycStatus != AgentKycStatus.APPROVED) {
      CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
      return null;
    }

    await controller.createProposal();

    if (controller.proposalApiResponse.state == NetworkState.error) {
      return showToast(
        context: context,
        text: controller.proposalApiResponse.message,
      );
    }

    if (controller.proposalApiResponse.state == NetworkState.loaded) {
      AutoRouter.of(context).push(DematProposalSuccessRoute());
    }
  }

  void checkDematConsent(
      BuildContext context, DematProposalController controller) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final isDematConsentDone =
        homeController.advisorOverviewModel?.agent?.dematTncConsentAt != null;

    if (isDematConsentDone) {
      onShareProposal(context, controller);
      return;
    }

    CommonUI.showBottomSheet(
      context,
      isDismissible: false,
      child: DematReferralTermsConditions(
        onDone: () {
          onShareProposal(context, controller);
        },
        selectedClient: controller.client,
      ),
    );
  }
}
