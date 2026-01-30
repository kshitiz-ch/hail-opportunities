import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_bank_detail_card.dart';

class CompleteEmpanelmentCard extends StatelessWidget {
  const CompleteEmpanelmentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isKycDone &&
            controller.isBankDetailAdded &&
            !controller.isEmpanelmentPending) {
          return SizedBox();
        }

        if (controller.isKycDone &&
            !controller.isBankDetailAdded &&
            !controller.isEmpanelmentPending) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: AddBankDetailCard(),
          );
        }

        return Container(
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColorV2,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    AllImages().completeKycIcon,
                    width: 50,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Empanelment Now',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'You\'re just one step away from starting your Wealth Business and receiving your payouts',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: ColorConstants.tertiaryBlack),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              getActionButton(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget getActionButton(BuildContext context, HomeController controller) {
    // String actionButtonText = 'Complete KYC';
    // if (!controller.isKycDone) {
    //   actionButtonText = 'Complete KYC';
    // } else if (!controller.isBankDetailAdded) {
    //   actionButtonText = 'Complete KYB';
    // } else if (!controller.isEmpanelmentPending) {
    //   actionButtonText = 'Complete Empanelment';
    // }

    return GetBuilder<HomeController>(
        id: 'update-bank-detail',
        builder: (controller) {
          return ActionButton(
            height: 50,
            showProgressIndicator:
                controller.kycSubFlowState == NetworkState.loading,
            text: 'Complete Now',
            margin: EdgeInsets.zero,
            borderRadius: 8,
            onPressed: () async {
              //   if (!controller.isKycDone) {
              //     AutoRouter.of(context).push(
              //       CompleteKycRoute(
              //         fromScreen: 'home',
              //       ),
              //     );
              //   } else if (!controller.isBankDetailAdded) {
              //     await controller.initiateKycSubFlow(context, 'PARTNER_BANK');
              //     if (controller.kycSubFlowState == NetworkState.loaded &&
              //         (controller.kycSubFlowUrl?.isNotNullOrEmpty ?? false)) {
              //       openKycSubFlowUrl(
              //         kycUrl: controller.kycSubFlowUrl! + '&new_app_version=true',
              //         context: context,
              //         onExit: () {
              //           controller.getAdvisorOverview();
              //         },
              //       );
              //     } else {
              //       showToast(text: "Failed to get KYC url. Please try again");
              //     }
              //   } else if (controller.isEmpanelmentPending) {
              //     AutoRouter.of(context).push(
              //       EmpanelmentRoute(
              //           advisorOverview: controller.advisorOverviewModel),
              //     );
              //   }
              AutoRouter.of(context).push(ProfileUpdateRoute());
            },
          );
        });
  }
}
