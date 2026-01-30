import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'become_ap_bottomsheet.dart';

class DematApBanners extends StatelessWidget {
  const DematApBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(
      builder: (controller) {
        Color backgroundColor;
        Color accentColor;

        String revenueSharing;
        String openingIncentive;

        if (controller.isAuthorised) {
          backgroundColor = hexToColor("#CAF7C8");
          accentColor = hexToColor("#A4D1A2");

          revenueSharing = '70%';
          openingIncentive = '600';
        } else {
          backgroundColor = hexToColor("#FFF1C1");
          accentColor = hexToColor("#F7BA76");

          revenueSharing = '35%';
          openingIncentive = '200';
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20)
              .copyWith(top: 20, bottom: 20),
          padding: EdgeInsets.all(10).copyWith(bottom: 20),
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: accentColor, width: 2),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      backgroundColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    'For ${controller.isAuthorised ? "" : "Non "}Authorised Person',
                    style: context.titleLarge,
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 30, left: 10),
                    child: Image.asset(
                      controller.isAuthorised
                          ? AllImages().apAvatar
                          : AllImages().nonApAvatar,
                      width: 44,
                      height: 44,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(''),
                        Text(
                          revenueSharing,
                          style: context.headlineLarge!.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'revenue sharing of brokerage',
                          style: context.titleLarge!
                              .copyWith(fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: EdgeInsets.only(right: 12),
                    color: accentColor,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upto',
                          style: context.titleLarge,
                        ),
                        Text(
                          '₹$openingIncentive',
                          style: context.headlineLarge!.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text('Account activation incentive',
                            style: context.titleLarge!
                                .copyWith(fontWeight: FontWeight.w600))
                      ],
                    ),
                  )
                ],
              ),
              if (!controller.isAuthorised)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Boost your earnings as an Authorised Partner - unlock exclusive higher payouts and amazing rewards!\n',
                          style: context.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack, height: 1.4),
                        ),
                        TextSpan(
                          text: 'Click here ',
                          style: context.titleLarge!.copyWith(
                              color: ColorConstants.primaryAppColor,
                              fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              CommonUI.showBottomSheet(
                                context,
                                child: BecomeApBottomSheet(),
                              );
                            },
                        ),
                        TextSpan(
                          text: 'to learn how to start the process today.',
                          style: context.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
