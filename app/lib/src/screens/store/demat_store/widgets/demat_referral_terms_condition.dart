import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/store/demat_store/widgets/referral_term_condition_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DematReferralTermsConditions extends StatelessWidget {
  final Client? selectedClient;
  final Function onDone;

  DematReferralTermsConditions(
      {Key? key, required this.selectedClient, required this.onDone})
      : super(key: key) {
    if (Get.isRegistered<DematProposalController>()) {
      Get.find<DematProposalController>().client = selectedClient;
      // By default make it true
      Get.find<DematProposalController>().termsConditionsAgreed = true;
    } else {
      Get.put<DematProposalController>(
          DematProposalController(client: selectedClient));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(
      id: 'demat-consent',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommonUI.buildCheckbox(
                    checkColor: Colors.white,
                    fillColor: ColorConstants.primaryAppColor,
                    value: controller.termsConditionsAgreed,
                    onChanged: (bool? value) {
                      controller.termsConditionsAgreed = (value ?? false);
                      controller.update(['demat-consent']);
                    },
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By proceeding I agree to the ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium
                            ?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w500,
                            ),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: ColorConstants.primaryAppColor,
                                  fontWeight: FontWeight.w700,
                                ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                CommonUI.showBottomSheet(
                                  context,
                                  child: ReferralTermConditionBottomSheet(),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ActionButton(
                isDisabled: !controller.termsConditionsAgreed,
                showProgressIndicator:
                    controller.dematConsent.state == NetworkState.loading,
                text: 'Continue',
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                onPressed: () {
                  if (!controller.termsConditionsAgreed) {
                    showToast(
                      text:
                          'Please tick terms and conditions checkbox to explore Wealthy Broking',
                    );
                    // close t&c bottomsheet
                    AutoRouter.of(context).popForced();
                  } else {
                    onAgree(controller, context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onAgree(
      DematProposalController controller, BuildContext context) async {
    await controller.auditDematConsent();
    // close t&c bottomsheet
    AutoRouter.of(context).popForced();
    if (controller.dematConsent.state == NetworkState.loaded) {
      onDone();
      // update dematTncConsentAt
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController());
      homeController.getAdvisorOverview();
    } else if (controller.dematConsent.state == NetworkState.error) {
      showToast(text: genericErrorMessage);
    }
  }
}
