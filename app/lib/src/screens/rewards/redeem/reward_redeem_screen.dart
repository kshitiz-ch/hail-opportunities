import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class RedeemScreen extends StatelessWidget {
  final balance;
  final String? fromScreen;
  final bool shouldDelayRetryRedemption;

  RedeemScreen(
      {this.balance, this.fromScreen, this.shouldDelayRetryRedemption = false});
  RewardsController rewardsController = Get.find<RewardsController>();

  goBackHandler(BuildContext context, RewardsController controller) async {
    if (controller.isRedemptionFailed) {
      AutoRouter.of(context).popUntil(ModalRoute.withName(RewardsRoute.name));
      rewardsController.setShouldDelayRedemption(true);
      controller.isRedemptionFailed = false;
    } else {
      AutoRouter.of(context).popForced();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RewardsController>(
      id: 'rewards-redeem',
      initState: (_) {},
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              goBackHandler(context, controller);
              AutoRouter.of(context).popForced();
            });
          },
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: CustomAppBar(
              showBackButton: true,
            ),
            body: Container(
              padding: const EdgeInsets.only(
                  bottom: 16, top: 16, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Redeem Amount',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displaySmall!
                        .copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please enter the amount you would like to withdraw',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontSize: 12, color: ColorConstants.tertiaryGrey),
                  ),
                  Form(
                    key: controller.formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: AmountTextField(
                        controller: controller.amountController,
                        showAmountLabel: false,
                        showIncrement: false,
                        validator: (value) {
                          try {
                            if (int.parse(value) < 1) {
                              return "Please enter a valid amount";
                            }
                          } catch (error) {
                            LogUtil.printLog(error);
                          }

                          if (value.isEmpty) {
                            return "Please enter a amount";
                          }

                          try {
                            if (int.parse(value) > balance) {
                              return "Please enter amount less than or equal to your balance";
                            }
                          } catch (error) {
                            LogUtil.printLog(error);
                          }

                          return null;
                        },
                        captionWidget: _buildAvailableBalanceText(context),
                        minAmount: 0,
                        labelStyle: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontSize: 12,
                                color: ColorConstants.primaryAppColor),
                        scrollPadding: const EdgeInsets.only(bottom: 100),
                        // onChanged: (_) {
                        //   // controller.update(['action-button']);
                        // },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ActionButton(
              heroTag: kDefaultHeroTag,
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              showProgressIndicator:
                  rewardsController.redemptionState == NetworkState.loading,
              text: 'Confirm',
              onPressed: () async {
                await rewardsController.redeemMoney();

                if (rewardsController.redemptionState == NetworkState.loaded) {
                  if (rewardsController.redemption?.thirdPartyPaymentLink !=
                      null) {
                    if (!isPageAtTopStack(context, WebViewRoute.name)) {
                      AutoRouter.of(context).push(
                        WebViewRoute(
                          url: rewardsController
                              .redemption?.thirdPartyPaymentLink,
                          onWebViewExit: () async {
                            AutoRouter.of(context).popForced();
                            AutoRouter.of(context).push(
                              RedemptionStatusRoute(
                                  redemptionId:
                                      rewardsController.redemption?.orderId),
                            );
                          },
                          onNavigationRequest: (NavigationRequest request) {
                            if (request.url.contains("wealthy.in")) {
                              AutoRouter.of(context).popForced();
                              AutoRouter.of(context).push(
                                RedemptionStatusRoute(
                                    redemptionId:
                                        rewardsController.redemption?.orderId),
                              );
                              return NavigationDecision.prevent;
                            }
                          },
                        ),
                      );
                    }
                  }
                } else if (rewardsController.redemptionState ==
                    NetworkState.error) {
                  showToast(
                      context: context,
                      text: rewardsController.redemptionErrorMessage);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailableBalanceText(context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Available Balance: ',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          TextSpan(
            text: WealthyAmount.currencyFormat(balance, 0),
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.black,
                ),
          )
        ],
      ),
    );
  }
}
