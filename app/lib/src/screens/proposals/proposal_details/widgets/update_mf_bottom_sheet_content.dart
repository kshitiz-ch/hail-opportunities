import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    as stringConstants;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/investment_type_switch_section.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/sip_day_selector_section_new.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/switch_period_selector.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateMfBottomSheetContent extends StatelessWidget {
  // Fields
  final ProposalModel proposal;
  final bool isTopUpPortfolio;

  const UpdateMfBottomSheetContent(
      {Key? key, required this.proposal, this.isTopUpPortfolio = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final portfolio = GoalSubtypeModel(
      title: proposal.displayName,
      minAddAmount: proposal.productInfo?.minAddAmount,
      minAmount: proposal.productInfo?.minAmount,
      productVariant: proposal.productTypeVariant,
    );

    Get.put(
      MFPortfolioDetailController(
        portfolio: portfolio,
        isUpdateProposal: true,
        proposal: proposal,
        isTopUpPortfolio: isTopUpPortfolio,
        isSmartSwitch: proposal.productInfo?.isSmartSwitch ?? false,
      ),
    );

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          GetBuilder<MFPortfolioDetailController>(
            initState: (_) {
              _initController(Get.find<MFPortfolioDetailController>());
            },
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Investment Type Switch
                  Padding(
                    padding: const EdgeInsets.only(top: 21.0),
                    child: InvestmentTypeSwitchSection(
                      isSmartSwitch:
                          proposal.productInfo?.isSmartSwitch ?? false,
                    ),
                  ),

                  // Switch Period Selector Dropdown
                  if (proposal.productInfo?.isSmartSwitch ?? false)
                    SwitchPeriodSelector(),

                  // SIP Day Selector ButtonBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SipDaySelectorSectionNew(),
                  ),

                  // "ENTER ALLOTMENT AMOUNT" Text
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32).copyWith(top: 28),
                    child: Text(
                      "Enter Investment Amount",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),

                  // Amount TextField
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                    child: AmountTextField(
                      showAmountLabel: false,
                      minAmount: isTopUpPortfolio
                          ? controller.portfolio.minAddAmount
                          : controller.portfolio.minAmount,
                      controller: controller.amountController,
                      onChanged: (_) {
                        controller.update(['update-proposal']);
                      },
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: GetBuilder<MFPortfolioDetailController>(
                      id: 'update-proposal',
                      dispose: (_) {
                        Get.delete<MFPortfolioDetailController>();
                      },
                      builder: (controller) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            margin: EdgeInsets.zero,
                            bgColor: ColorConstants.secondaryAppColor,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.primaryAppColor,
                                  fontSize: 16,
                                ),
                            text: 'Discard',
                            onPressed: () {
                              AutoRouter.of(context).popForced(true);
                            },
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            isDisabled:
                                controller.amountController!.text.isEmpty,
                            text: 'Save Changes',
                            margin: EdgeInsets.zero,
                            showProgressIndicator:
                                controller.updateProposalState ==
                                    NetworkState.loading,
                            onPressed: () async {
                              double? minAmount = isTopUpPortfolio
                                  ? portfolio.minAddAmount
                                  : portfolio.minAmount;

                              if (checkMinAmountValidation(
                                  amountEntered: controller.allotmentAmount,
                                  minAmount: minAmount,
                                  isTaxSaver: portfolio.productVariant ==
                                      stringConstants.taxSaverProductVariant)) {
                                return;
                              }

                              await controller.updateProposal();

                              if (controller.updateProposalState ==
                                  NetworkState.error) {
                                return showToast(
                                  text: controller.updateProposalErrorMessage,
                                );
                              }

                              if (controller.updateProposalState ==
                                  NetworkState.loaded) {
                                AutoRouter.of(context).push(
                                  ProposalSuccessRoute(
                                    client: proposal.customer,
                                    productName: controller.portfolioName ??
                                        controller.portfolio.title,
                                    proposalUrl: controller.proposalUrl,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0, right: 32.0),
              child: IconButton(
                iconSize: 24,
                splashRadius: 20.0,
                icon: Icon(
                  Icons.close,
                  color: ColorConstants.black,
                ),
                onPressed: () {
                  AutoRouter.of(context).popForced(true);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _initController(MFPortfolioDetailController controller) {
    final preFilledAmount = proposal.lumsumAmount;

    // If preFilledAmount is not null, initialize
    // the amountController with preFilledAmount
    if (preFilledAmount != null) {
      String string = preFilledAmount.toStringAsFixed(0);

      if (string.length > 1 && double.parse(string) > 9999)
        string = '${WealthyAmount.formatNumber(string)}';

      controller.amountController!.value =
          controller.amountController!.value.copyWith(
        text: '${string}',
        selection: TextSelection.collapsed(offset: string.length + 2),
      );
    }

    controller.investmentType = getInvestmentTypeFromString(
      proposal.productExtrasJson!['order_type'] ?? InvestmentType.oneTime,
    );
    controller.selectedSipDay = proposal.productExtrasJson!['sip'] != null
        ? proposal.productExtrasJson!['sip']['sip_day']
        : 5;
    controller.selectedSwitchPeriod =
        proposal.productExtrasJson!['switch_period'];
  }
}
