import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PendingRedemptionCard extends StatelessWidget {
  const PendingRedemptionCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RewardsController>(
      id: 'rewards-balance',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ColorConstants.lightOrangeColor),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: ColorConstants.tertiaryBlack,
              ),
              SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  'Redemption of ${WealthyAmount.currencyFormat(controller.pendingRedemption?.amount, 0)} in process. Complete request to get the amount',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: ColorConstants.tertiaryBlack),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              if (controller.retryRedemptionState == NetworkState.loading)
                _buildSpinnerLoader()
              else
                ClickableText(
                  onClick: () async {
                    // Update redemption link if status is only created
                    if (controller.pendingRedemption?.redeemStatus ==
                        RewardRedemptionStatus.Created) {
                      await controller.retryRewardRedemptionRequest();

                      // Use the updated redemption link
                      if (controller.retryRedemptionState ==
                          NetworkState.loaded) {
                        _openRedemptionLink(
                          context,
                          orderId: controller.redemption!.orderId,
                          thirdPartyPaymentLink:
                              controller.redemption!.thirdPartyPaymentLink,
                        );
                      } else {
                        showToast(
                          context: context,
                          text: controller.retryRedemptionErrorMessage ??
                              'Something went wrong Please try again',
                        );
                      }
                    } else {
                      // Use the existing redemption link
                      _openRedemptionLink(
                        context,
                        orderId: controller.pendingRedemption!.orderId,
                        thirdPartyPaymentLink:
                            controller.pendingRedemption!.thirdPartyPaymentLink,
                      );
                    }
                  },
                  text: 'Redeem',
                  fontSize: 14,
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinnerLoader() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      height: 15,
      width: 15,
      child: CircularProgressIndicator(
        color: ColorConstants.primaryAppColor,
        strokeWidth: 2,
      ),
    );
  }

  void _openRedemptionLink(BuildContext context,
      {String? thirdPartyPaymentLink, String? orderId}) {
    if (!isPageAtTopStack(context, WebViewRoute.name)) {
      AutoRouter.of(context).push(
        WebViewRoute(
          url: thirdPartyPaymentLink,
          onWebViewExit: () {
            AutoRouter.of(context).popForced();
            AutoRouter.of(context).push(
              RedemptionStatusRoute(redemptionId: orderId),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("wealthy.in")) {
              AutoRouter.of(context).popForced();
              AutoRouter.of(context).push(
                RedemptionStatusRoute(redemptionId: orderId),
              );
              return NavigationDecision.prevent;
            }
          },
        ),
      );
    }
  }
}
