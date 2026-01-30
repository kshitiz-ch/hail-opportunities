import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'empanelment_form_bottomsheet.dart';

class PaymenFailedDialog extends StatelessWidget {
  const PaymenFailedDialog({Key? key, required this.controller})
      : super(key: key);

  final EmpanelmentController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 100,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      InkWell(
                        onTap: () {
                          AutoRouter.of(context).popForced();
                        },
                        child: Icon(
                          Icons.close,
                          color: ColorConstants.tertiaryBlack,
                          size: 24,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 45),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: hexToColor("#fbf4f7"),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          AllImages().paymentFailed,
                          width: 108,
                        ),
                        SizedBox(height: 32),
                        Text(
                          'Payment Failed!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineLarge!
                              .copyWith(fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your payment has failed! Retry after some time',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ActionButton(
                  text: 'Retry',
                  onPressed: () {
                    if (controller.empanelmentData?.thirdPartyOrderId
                            ?.isNotNullOrEmpty ??
                        false) {
                      AutoRouter.of(context).popForced();
                      controller.initRazorPay();
                    } else {
                      CommonUI.showBottomSheet(
                        context,
                        child: EmpanelmentFormBottomsheet(),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
