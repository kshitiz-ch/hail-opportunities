import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_detail/widgets/funds_list_section.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/overview_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/portfolio_graph.dart';

@RoutePage()
class MfPortfolioDetailScreen extends StatelessWidget {
  // Fields
  final GoalSubtypeModel? portfolio;
  final Client? client;
  final bool? isSmartSwitch;
  final bool isTopUpPortfolio;
  final bool fromSearch;
  final bool fromClientInvestmentScreen;
  final PortfolioInvestmentModel? portfolioInvestment;
  final List<SchemeMetaModel>? portfolioSchemes;
  final InvestmentType? investmentTypeAllowed;

  // Constructor
  const MfPortfolioDetailScreen(
      {Key? key,
      required this.portfolio,
      this.isSmartSwitch = false,
      this.isTopUpPortfolio = false,
      this.client,
      this.fromSearch = false,
      this.fromClientInvestmentScreen = false,
      this.portfolioSchemes,
      this.portfolioInvestment,
      this.investmentTypeAllowed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    portfolio?.minSipAmount =
        mfBasketPortfolioMinSipAmount[portfolio?.productVariant];
    final controller = Get.put(MFPortfolioDetailController(
      portfolio: portfolio!,
      isSmartSwitch: isSmartSwitch,
      selectedClient: client,
      fromClientScreen: client != null,
      investmentTypeAllowed: investmentTypeAllowed,
      isTopUpPortfolio: isTopUpPortfolio,
    ));

    int noOfFunds;
    if (isSmartSwitch!) {
      noOfFunds = controller.portfolio.schemes!.length ~/ 2;
    } else {
      noOfFunds = controller.portfolio.schemes!.length;
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: controller.portfolio.title,
        maxLine: 3,
        trailingWidgets: buildTrailing(context),
        subtitleHeight: 20,
        customSubtitleWidget: buildSubtitle(context, noOfFunds),
      ),

      // Body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
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
                            portfolioInvestment?.currentInvestedValue ?? 0, 0),
                        label: 'Invested Value'),
                    CommonUI.buildColumnText(context,
                        value: WealthyAmount.currencyFormat(
                            portfolioInvestment?.currentValue ?? 0, 0),
                        label: 'Current Value'),
                    CommonUI.buildColumnText(context,
                        value: getReturnPercentageText(
                            portfolioInvestment?.currentAbsoluteReturns ?? 0),
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
            // TODO: Check for better implementation
            // Overview Card
            // Stack(
            //   alignment: AlignmentDirectional.topStart,
            //   children: [
            //     Container(
            //       height: 80,
            //       color: ColorConstants.primaryAppColor,
            //     ),
            //     Container(
            //       height: 160,
            //     ),
            //     OverviewCard(
            //       portfolio: controller.portfolio,
            //       isTopUpPortfolio: controller.isTopUpPortfolio,
            //     ),
            //   ],
            // )

            // Divider
            // if (controller.showChart) SectionDivider(),

            // Section - Funds List
            FundsListSection(
              portfolio: controller.portfolio,
              isSmartSwitch: controller.isSmartSwitch,
              isMicroSIP: controller.isMicroSIP,
              portfolioSchemes: portfolioSchemes,
            ),

            // Historical Graph & Return Calculator
            PortfolioGraph()
            // if (controller.showChart)
            //   Chart(
            //     productVariant: controller.portfolio.productVariant,
            //     portfolio: controller.portfolio,
            //   ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GetBuilder<MFPortfolioDetailController>(
        id: 'action-button',
        initState: (_) {
          bool fromProductList = isRouteNameInStack(
            context,
            MfPortfolioListRoute.name,
          );
        },
        dispose: (_) => Get.delete<MFPortfolioDetailController>(),
        builder: (controller) {
          return ActionButton(
            heroTag: kDefaultHeroTag,
            text: "Continue",
            margin: EdgeInsets.symmetric(horizontal: 30),
            isDisabled: (controller.fundsState == NetworkState.loaded &&
                        controller.fundsResult.schemeMetas!.isEmpty) ||
                    controller.fundsState != NetworkState.loaded ||
                    controller.isMicroSIP
                ? controller.microSIPBasket.isEmpty
                : false,
            onPressed: () {
              // if (controller.isMicroSIP) {
              //   double? minAmount = controller.isTopUpPortfolio
              //       ? controller.portfolio.minAddAmount
              //       : controller.portfolio.minAmount;

              //   if (checkMinAmountValidation(
              //     minAmount: minAmount,
              //     amountEntered: controller.totalMicroSIPAmount,
              //     isTaxSaver: controller.portfolio.productVariant ==
              //         taxSaverProductVariant,
              //   )) {
              //     return null;
              //   }
              // }

              AutoRouter.of(context).push(MfPortfolioFormRoute(
                  fromClientInvestmentScreen: fromClientInvestmentScreen,
                  portfolioInvestment: portfolioInvestment));
            },
          );
        },
      ),
    );
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
