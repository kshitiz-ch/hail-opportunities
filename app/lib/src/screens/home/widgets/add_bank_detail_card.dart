import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddBankDetailCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: ColorConstants.lightBackgroundColorV2,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AllImages().bankIcon,
                color: ColorConstants.primaryAppColor,
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
                      'Get your payout now!',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'To receive your payouts directly to your bank account, please update your bank details',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 12,
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
          GetBuilder<HomeController>(
            id: 'update-bank-detail',
            builder: (controller) {
              return ActionButton(
                showProgressIndicator:
                    controller.kycSubFlowState == NetworkState.loading,
                height: 50,
                text: 'Add Bank Details',
                margin: EdgeInsets.zero,
                borderRadius: 8,
                onPressed: () {
                  // addBankDetail(context, controller);
                  AutoRouter.of(context).push(ProfileUpdateRoute());
                },
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> addBankDetail(
      BuildContext context, HomeController homeController) async {
    await homeController.initiateKycSubFlow(context, 'PARTNER_BANK');
    if (homeController.kycSubFlowState == NetworkState.loaded &&
        homeController.kycSubFlowUrl.isNotNullOrEmpty) {
      openKycSubFlowUrl(
        kycUrl: homeController.kycSubFlowUrl! + '&new_app_version=true',
        context: context,
        onExit: () {
          homeController.getAdvisorOverview();
        },
      );
    }
  }
}
