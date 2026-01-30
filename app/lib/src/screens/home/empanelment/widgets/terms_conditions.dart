import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'empanelment_tc_bottomsheet.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmpanelmentController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(top: 23, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonUI.buildCheckbox(
                value: controller.isTcAgreed,
                unselectedBorderColor: ColorConstants.darkGrey,
                onChanged: (bool? value) {
                  // if (controller.mfInvestmentResponse.state ==
                  //     NetworkState.loading) {
                  //   return;
                  // }
                  controller.toggleTcAgreed();
                },
              ),
              Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                  children: [
                    TextSpan(
                      text: '*Terms & Conditions',
                      style: Theme.of(context).primaryTextTheme.titleLarge,
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          CommonUI.showBottomSheet(
                            context,
                            child: EmpanelmentTcBottomSheet(
                              thirdPartyOrderId:
                                  controller.empanelmentData?.thirdPartyOrderId,
                            ),
                          );
                        },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
