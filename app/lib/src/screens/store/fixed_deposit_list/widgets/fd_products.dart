import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/fd_amount_field.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/interest_tenure_input_field_form.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/product_graph_view.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class FDProducts extends StatelessWidget {
  final Key? widgetKey;
  const FDProducts({Key? key, this.widgetKey}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        if (controller.fdsState == NetworkState.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (controller.fdsState == NetworkState.error) {
          return Center(
            child: RetryWidget(
              controller.fdsErrorMessage.isNotNullOrEmpty
                  ? controller.fdsErrorMessage
                  : genericErrorMessage,
              onPressed: () {
                controller.getFds();
              },
            ),
          );
        }
        if (controller.fdsState == NetworkState.loaded) {
          if (controller.fdListModel!.available.isNullOrEmpty) {
            return EmptyScreen(
              message: 'No Fixed Deposits Products available ',
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(
                    bottom: 16,
                  ),
                  child: Text(
                    'FD Rate Calculator',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
                  ),
                ),
                _buildProductPlans(context, controller),
              ],
            );
          }
        }
        return SizedBox();
      },
    );
  }

  Widget _buildProductPlans(
      BuildContext context, FixedDepositsController controller) {
    final isDisabled =
        controller.selectedProduct == null || !controller.isMonthInputValid();
    return Card(
      key: widgetKey,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.07),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ColorConstants.secondaryWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              offset: Offset(0, 3),
              blurRadius: 10,
            )
          ],
          // border: Border.all(
          //   width: 0.5,
          //   color: ColorConstants.tertiaryBlack.withOpacity(0.5),
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20).copyWith(bottom: 12),
              child: FDAmountField(),
            ),
            // Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 12),
              child: InterestTenureInputFieldForm(),
            ),
            // Products Graph View
            Container(
              padding: EdgeInsets.only(top: 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Availability Label
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20).copyWith(
                      bottom: 8,
                    ),
                    child: _buildProductAvailabilityLabel(context),
                  ),
                  // Disclaimer
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20).copyWith(
                      bottom: 16,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: '*Interest rate are for cumulative options ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              height: 16 / 12,
                            ),
                      ),
                    ),
                  ),

                  ProductGraphView(),
                ],
              ),
            ),
            // Action Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ActionButton(
                // we are pushing screen loader for this as per other web views
                // showProgressIndicator:
                //     controller.proposalUrlState == NetworkState.loading,
                isDisabled: isDisabled,
                text: 'Proceed',
                margin: EdgeInsets.zero,
                onPressed: () async {
                  onProceed(controller, context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 20, top: 10),
              child: Text.rich(
                TextSpan(
                  text: 'Tap on ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            height: 16 / 12,
                          ),
                  children: [
                    TextSpan(
                      text: 'Proceed',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            height: 16 / 12,
                          ),
                    ),
                    TextSpan(
                      text: ' to create proposal for the selected product ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            height: 16 / 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onProceed(
      FixedDepositsController controller, BuildContext context) async {
    // Validate amount
    if (controller.amountFormKey.currentState?.validate() == false) {
      String? errorToast =
          controller.validateAmount(controller.amountController.text);
      if (errorToast.isNotNullOrEmpty) {
        showToast(text: errorToast);
        return;
      }
    }

    int? agentKycStatus = await getAgentKycStatus();
    if (agentKycStatus != AgentKycStatus.APPROVED) {
      CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
      return;
    }

    if (controller.isMonthInputValid() && controller.selectedProduct != null) {
      if (controller.selectedProduct!.isOnline!) {
        await controller.getProposalUrl();
        if (controller.proposalUrlState == NetworkState.loaded &&
            controller.proposalUrl.isNotNullOrEmpty &&
            !isPageAtTopStack(
              context,
              InsuranceWebViewRoute.name,
            )) {
          AutoRouter.of(context).push(
            InsuranceWebViewRoute(
              onNavigationRequest: (
                InAppWebViewController controller,
                NavigationAction action,
              ) async {
                final navigationUrl = action.request.url.toString();
                if (navigationUrl.contains("applinks.buildwealth.in")) {
                  if (navigationUrl ==
                      "https://applinks.buildwealth.in/proposals") {
                    navigateToProposalScreen(context);
                  } else {
                    AutoRouter.of(context).popForced();
                  }
                  return NavigationActionPolicy.CANCEL;
                } else {
                  return NavigationActionPolicy.ALLOW;
                }
              },
              url: controller.proposalUrl,
              shouldHandleAppBar: false,
            ),
          );
        }
      } else {
        AutoRouter.of(context).push(
          FixedDepositOfflineListRoute(
            selectedProduct: controller.selectedProduct,
          ),
        );
      }
    }
  }

  Widget _buildProductAvailabilityLabel(BuildContext context) {
    Widget _buildLabel(String text, bool isOnline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 12,
            child: Center(
              child: Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isOnline
                      ? ColorConstants.greenAccentColor
                      : ColorConstants.errorTextColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                  color: ColorConstants.black,
                  letterSpacing: 0.8,
                ),
          )
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabel('Online plans', true),
          SizedBox(width: 12),
          _buildLabel('Offline plans', false),
        ],
      ),
    );
  }
}
