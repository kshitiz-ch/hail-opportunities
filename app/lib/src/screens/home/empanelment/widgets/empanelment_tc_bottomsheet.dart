import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/empanelment_terms_conditions.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'empanelment_form_bottomsheet.dart';

class EmpanelmentTcBottomSheet extends StatelessWidget {
  const EmpanelmentTcBottomSheet({Key? key, required this.thirdPartyOrderId})
      : super(key: key);

  final String? thirdPartyOrderId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmpanelmentController>(
      builder: (controller) {
        return Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineLarge!
                              .copyWith(fontSize: 18),
                        ),
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
                    SizedBox(height: 12),
                    Text(
                      'Please accept the Terms & Conditions of Empaneled Partner Service',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                    )
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorConstants.secondarySeparatorColor,
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: empanelmentTc.length,
                      itemBuilder: (context, index) {
                        // String tc = getBulletListText(empanelmentTc[index]);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}.  ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    height: 18 / 12,
                                  ),
                            ),
                            Expanded(
                              child: HtmlWidget(
                                empanelmentTc[index]["content"],
                                textStyle: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      height: 18 / 12,
                                    ),
                              ),
                            )
                            // Expanded(
                            //   child: Text(
                            //     '${text}',
                            //     style: Theme.of(context)
                            //         .primaryTextTheme
                            //         .titleLarge!
                            //         .copyWith(
                            //           fontWeight: FontWeight.w400,
                            //           color: ColorConstants.tertiaryBlack,
                            //           height: 18 / 12,
                            //         ),
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // empanelmentTc
                SizedBox(height: 48),
                ActionButton(
                  text: 'Accept & Proceed',
                  onPressed: () {
                    controller.toggleTcAgreed();
                    AutoRouter.of(context).popForced();
                    if (thirdPartyOrderId?.isNotNullOrEmpty ?? false) {
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
        );
      },
    );
  }
}
