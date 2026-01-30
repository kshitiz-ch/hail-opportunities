import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/floating_action_button_section.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/micro_sip_basket_view.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/sip_day_selector_section_new.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/switch_period_selector.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/overview_card.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/investment_type_switch_section.dart';

@RoutePage()
class MfPortfolioFormScreen extends StatelessWidget {
  const MfPortfolioFormScreen(
      {Key? key,
      this.fromClientInvestmentScreen = false,
      this.portfolioInvestment})
      : super(key: key);

  final bool fromClientInvestmentScreen;
  final PortfolioInvestmentModel? portfolioInvestment;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MFPortfolioDetailController>();
    final portfolio = controller.portfolio;
    final bool isSmartSwitch = controller.isSmartSwitch!;
    final bool isMicroSIP = controller.isMicroSIP;

    int noOfFunds;
    if (isSmartSwitch) {
      noOfFunds = controller.portfolio.schemes!.length ~/ 2;
    } else {
      noOfFunds = controller.portfolio.schemes!.length;
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,

      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        maxLine: 2,
        titleText: controller.portfolio.title,
        trailingWidgets: buildTrailing(context),
        subtitleHeight: 20,
        customSubtitleWidget: buildSubtitle(context, noOfFunds),
      ),

      // Body
      body: SingleChildScrollView(
        controller: controller.scrollController,
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.portfolio.description.isNotNullOrEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(
                  left: 62,
                ),
                child: Text(
                  controller.portfolio.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            SizedBox(height: 32),
            if (fromClientInvestmentScreen && portfolioInvestment != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0)
                    .copyWith(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI.buildColumnText(context,
                        value: WealthyAmount.currencyFormat(
                            portfolioInvestment!.currentInvestedValue, 0),
                        label: 'Invested Value'),
                    CommonUI.buildColumnText(context,
                        value: WealthyAmount.currencyFormat(
                            portfolioInvestment!.currentValue, 0),
                        label: 'Current Value'),
                    CommonUI.buildColumnText(context,
                        value: getReturnPercentageText(
                            portfolioInvestment!.currentAbsoluteReturns),
                        label: 'Absolute Returns')
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0)
                    .copyWith(bottom: 24),
                child: OverviewCard(
                  portfolio: controller.portfolio,
                  isTopUpPortfolio: controller.isTopUpPortfolio,
                ),
              ),
            Divider(
              color: ColorConstants.lightGrey,
            ),
            if (!isMicroSIP)
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 24.0, 16.0, 0.0),
                child: Text(
                  "Enter Investment Amount",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.tertiaryGrey),
                ),
              ),

            // Amount TextField
            if (!isMicroSIP)
              GetBuilder<MFPortfolioDetailController>(
                id: 'investment-type',
                builder: (controller) {
                  return Form(
                    key: controller.formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: AmountTextField(
                        validator: (val) {
                          return validateAmountTextField(controller);
                        },
                        showAmountLabel: false,
                        controller: controller.amountController,
                        minAmount:
                            controller.investmentType == InvestmentType.SIP &&
                                    portfolio.minSipAmount.isNotNullOrZero
                                ? portfolio.minSipAmount
                                : controller.isTopUpPortfolio
                                    ? portfolio.minAddAmount
                                    : portfolio.minAmount,
                        labelStyle: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontSize: 12,
                                color: ColorConstants.primaryAppColor),
                        scrollPadding: const EdgeInsets.only(bottom: 100),
                        onChanged: (_) {
                          controller
                              .update(['action-button', 'investment-type']);
                        },
                      ),
                    ),
                  );
                },
              ),

            // Investment Type Switch
            InvestmentTypeSwitchSection(
              isSmartSwitch: isSmartSwitch,
            ),

            // SIP Day Selector ButtonBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30)
                  .copyWith(bottom: 20),
              child: SipDaySelectorSectionNew(),
            ),
            if (isMicroSIP)
              Form(
                key: controller.microSipFormKey,
                child: MicroSipBasketView(),
              ),
            // Switch Period Selector Dropdown
            if (isSmartSwitch && portfolio.possibleSwitchPeriods!.isNotEmpty)
              SwitchPeriodSelector(),
          ],
        ),
      ),

      // floatingActionButtonLocation: FixedCenterDockedFabLocation(),

      bottomNavigationBar: FloatingActionButtonSection(
        isMicroSIP: isMicroSIP,
        portfolio: portfolio,
        isSmartSwitch: isSmartSwitch,
      ),
    );
  }

  String? validateAmountTextField(MFPortfolioDetailController controller) {
    double minAmount = 0;
    if (controller.investmentType == InvestmentType.SIP &&
        controller.portfolio.minSipAmount.isNotNullOrZero) {
      minAmount = controller.portfolio.minSipAmount!;
    } else {
      minAmount = controller.isTopUpPortfolio
          ? (controller.portfolio.minAddAmount ?? 0)
          : (controller.portfolio.minAmount ?? 0);
    }

    double amountEntered = controller.isMicroSIP
        ? controller.totalMicroSIPAmount
        : controller.allotmentAmount;

    if (amountEntered == 0) {
      return 'Amount should not be zero';
    }

    if (amountEntered < minAmount) {
      return 'Min Amount should be ₹${minAmount.toStringAsFixed(0)}';
    }

    if (controller.portfolio.goalType == GoalType.TAX_SAVER &&
        amountEntered % (controller.portfolio.minAmount ?? 0) != 0) {
      return 'Amount should be a multiple of ₹${(controller.portfolio.minAmount ?? 0).toStringAsFixed(0)}';
    }
    return null;
  }

  Widget buildSubtitle(BuildContext context, int noOfFunds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mutual fund portfolio ',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontSize: 14,
              ),
        ),
        Text(
          "$noOfFunds Fund${noOfFunds == 1 ? '' : 's'}",
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  List<Widget> buildTrailing(BuildContext context) {
    List<Widget> data = <Widget>[];
    data.add(
      SizedBox(
        width: SizeConfig().screenWidth! / 5,
        child: Align(
          alignment: Alignment.centerRight,
          child: CommonUI.buildPortfolioAMCLogos(),
        ),
      ),
    );
    return data;
  }
}
