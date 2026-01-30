import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class KycWarningBottomSheet extends StatelessWidget {
  final int? kycStatus;

  KycWarningBottomSheet({this.kycStatus});

  @override
  Widget build(BuildContext context) {
    String title;
    String text;
    if (kycStatus == AgentKycStatus.SUBMITTED) {
      title = 'KYC waiting!';
      text = 'Your KYC is not approved. Please wait till it’s processed';
    } else {
      title = 'Complete KYC to redeem!';
      text =
          'Your KYC is not complete. Please complete your KYC before redeeming';
    }
    return Container(
      padding: EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displayLarge!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: ColorConstants.black,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(text,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      // TODO: Replace with action button
                      child: kycStatus != AgentKycStatus.SUBMITTED
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 30),
                                    child: CommonUI.secondoryButton(
                                        context,
                                        Text(
                                          'Cancel',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headlineLarge!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: ColorConstants
                                                      .primaryAppColor,
                                                  fontWeight: FontWeight.w600),
                                        ), () {
                                      AutoRouter.of(context).popForced();
                                    }, ColorConstants.secondaryAppColor, 110),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: CommonUI.secondoryButton(
                                        context,
                                        Text(
                                          'Submit KYC',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headlineLarge!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                        ), () {
                                      try {
                                        // AutoRouter.of(context).push(
                                        //   CompleteKycRoute(
                                        //     agent: null,
                                        //     fromScreen: 'create-proposal',
                                        //   ),
                                        // );
                                        AutoRouter.of(context)
                                            .push(ProfileUpdateRoute());
                                      } catch (error) {
                                        showToast(
                                          context: context,
                                          text: 'Something went wrong',
                                        );
                                      }
                                    }, ColorConstants.primaryAppColor, 110),
                                  ),
                                )
                              ],
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
