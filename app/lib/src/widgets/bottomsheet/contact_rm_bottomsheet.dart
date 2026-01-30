import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

@RoutePage()
class ContactRmBottomSheetScreen extends StatelessWidget {
  final String fromScreen;
  final AdvisorOverviewModel? advisorModel;

  ContactRmBottomSheetScreen(
      {required this.advisorModel, this.fromScreen = ''});

  Future<void> _makePhoneCall(String url) async {
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30).copyWith(top: 50),
      child: Wrap(
        children: [
          Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Connect with ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.normal,
                            color: ColorConstants.black,
                          ),
                    ),
                    TextSpan(
                      text: '${advisorModel?.agent?.pst?.name ?? 'RM'} ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.black,
                          ),
                    ),
                    TextSpan(
                      text: 'via:',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.normal,
                            color: ColorConstants.black,
                          ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 34),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionButton(
                    responsiveButtonMaxWidthRatio: 0.4,
                    text: 'Whatsapp',
                    margin: EdgeInsets.zero,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16,
                        ),
                    bgColor: ColorConstants.secondaryAppColor,
                    onPressed: () async {
                      String? pstPhoneNumber =
                          advisorModel?.agent?.pst?.phoneNumber;
                      if (pstPhoneNumber.isNotNullOrEmpty) {
                        bool isCountryCodeMissing = pstPhoneNumber != null &&
                            pstPhoneNumber.length == 10;

                        final link = WhatsAppUnilink(
                          phoneNumber:
                              '${isCountryCodeMissing ? '+91' : ''}$pstPhoneNumber',
                          text:
                              "Hey, ${advisorModel?.agent?.pst?.name ?? 'there'}",
                        );

                        await launch('$link');

                        MixPanelAnalytics.trackWithAgentId(
                          "rm_whatsapp",
                          properties: {
                            "screen_location": "rm_card",
                            "screen": "Home",
                          },
                        );
                      } else {
                        showToast(text: 'Phone number not available');
                      }
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  ActionButton(
                    responsiveButtonMaxWidthRatio: 0.4,
                    text: 'Call',
                    margin: EdgeInsets.zero,
                    onPressed: () async {
                      MixPanelAnalytics.trackWithAgentId(
                        "rm_call_now",
                        properties: {
                          "screen_location": "rm_card",
                          "screen": "Home",
                        },
                      );
                      _makePhoneCall(
                          'tel:${advisorModel!.agent?.pst?.phoneNumber}');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
