import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/home/partner_referral_controller.dart';
import 'package:app/src/screens/home/partner_referral.dart/widgets/referral_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReferralCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerReferralController>(
      init: PartnerReferralController(),
      builder: (controller) {
        return Container(
          color: Color(0xffFAF3F8),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Image.asset(
                    AllImages().referralRewardIcon,
                    height: 30,
                    width: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Refer and Earn',
                      style: context.headlineMedium?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CommonUI.buildNewTag(context)
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Earn up to ₹19,000 per empanelment on Wealthy',
                      style: context.headlineSmall?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ClickableText(
                    text: 'Refer Now',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    onClick: () {
                      CommonUI.showBottomSheet(
                        context,
                        child: ReferralBottomsheet(),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
