import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ProposalKycAlertBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      'Complete KYC first!',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.black,
                              fontSize: 18,
                              height: 24 / 14),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Please complete your KYC before creating proposal for client',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.tertiaryBlack,
                              fontSize: 14,
                              height: 24 / 14,
                            ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            text: 'Cancel',
                            onPressed: () {
                              AutoRouter.of(context).popForced();
                            },
                            bgColor: ColorConstants.secondaryAppColor,
                            borderRadius: 51,
                            margin: EdgeInsets.zero,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.primaryAppColor,
                                  fontSize: 16,
                                ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            text: 'Submit KYC',
                            onPressed: () {
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
                                showToast(text: 'Something went wrong');
                              }
                            },
                            borderRadius: 51,
                            margin: EdgeInsets.zero,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.white,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
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
