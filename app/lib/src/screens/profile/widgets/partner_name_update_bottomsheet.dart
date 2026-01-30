import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PartnerNameUpdateBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: 'name',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.toHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Updating your name will result in the complete reset of your ',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                          ),
                          TextSpan(
                            text: 'KYC, ARN, GST and Bank Details',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                  color: ColorConstants.primaryAppColor,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                          ),
                          TextSpan(
                            text: '. Continue?',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Text(
                  //   'Are you sure you want to logout?',
                  //   style: Theme.of(context).textTheme.headline3.copyWith(
                  //       fontSize: 20.toFont,
                  //       color: Colors.black,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ActionButton(
                          responsiveButtonMaxWidthRatio: 0.4,
                          bgColor: ColorConstants.secondaryAppColor,
                          text: 'Cancel',
                          borderRadius: 25.toWidth,
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge!
                              .copyWith(
                                  color: ColorConstants.primaryAppColor,
                                  fontSize: 14),
                          onPressed: () {
                            AutoRouter.of(context).popForced();
                          },
                          margin: EdgeInsets.zero,
                        ),
                        SizedBox(width: 30),
                        ActionButton(
                          responsiveButtonMaxWidthRatio: 0.4,
                          text: 'Yes',
                          showProgressIndicator:
                              controller.updatePartnerState ==
                                  NetworkState.loading,
                          borderRadius: 25.toWidth,
                          margin: EdgeInsets.zero,
                          onPressed: () async {
                            final response =
                                await controller.updatePartnerDetails('name');

                            if (controller.updatePartnerState ==
                                NetworkState.loaded) {
                              if (response['changeRequestUrl'] != null ||
                                  response['changeRequestUrl']
                                      .toString()
                                      .isNotEmpty) {
                                final homeController =
                                    Get.isRegistered<HomeController>()
                                        ? Get.find<HomeController>()
                                        : Get.put(HomeController());

                                if (!isPageAtTopStack(
                                    context, WebViewRoute.name)) {
                                  try {
                                    final cookieManager =
                                        WebViewCookieManager();
                                    cookieManager.clearCookies();
                                  } catch (error) {
                                    LogUtil.printLog(error);
                                  }

                                  AutoRouter.of(context).push(WebViewRoute(
                                    url: response['changeRequestUrl'],
                                    onWebViewExit: () {
                                      AutoRouter.of(context)
                                          .popUntilRouteWithName(
                                              ProfileRoute.name);

                                      controller.getAdvisorOverview();
                                      homeController.getAdvisorOverview();
                                    },
                                  ));
                                }
                              } else {
                                showToast(
                                    text:
                                        "request to update failed please try again");
                              }
                            } else {
                              return showToast(
                                  text: controller
                                      .updatePartnerDetailsErrorMessage);
                            }
                          },
                        )
                      ],
                    ),
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
