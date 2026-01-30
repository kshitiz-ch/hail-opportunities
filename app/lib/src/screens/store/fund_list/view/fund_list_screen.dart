import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/screens/store/fund_list/widgets/filter_action_buttons.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_section.dart';
import 'package:app/src/screens/store/fund_list/widgets/search_bar_section.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/loader/search_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class FundListScreen extends StatelessWidget {
  // Fields
  List<SchemeMetaModel>? funds;
  GoalSubtypeModel? portfolio;
  Client? client;
  bool showBottomBasketAppBar;
  bool isCustomPortfolio;
  bool isTopUpPortfolio;
  String? amc;
  bool fromClientInvestmentScreen;
  PortfolioInvestmentModel? portfolioInvestment;
  InvestmentType? investmentTypeAllowed;

  FundListScreen(
      {Key? key,
      this.funds,
      this.portfolio,
      this.client,
      this.showBottomBasketAppBar = true,
      this.isCustomPortfolio = false,
      this.isTopUpPortfolio = false,
      this.fromClientInvestmentScreen = false,
      this.portfolioInvestment,
      this.investmentTypeAllowed,
      @queryParam this.amc = ''})
      : super(key: key);

  Key showCaseWrapperKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    BasketController basketController;
    String? tag;

    // If Top-Up Flow, init new BasketController instance
    if (isTopUpPortfolio) {
      tag = portfolio?.externalId;
      basketController = Get.put(
        BasketController(
          isTopUpPortfolio: isTopUpPortfolio,
          selectedClient: client,
          fromClientScreen: client != null,
          portfolio: portfolio,
          investmentTypeAllowed: investmentTypeAllowed,
        ),
        tag: tag,
      );
    } else {
      if (Get.isRegistered<BasketController>()) {
        basketController = Get.find<BasketController>()
          ..fromClientScreen = client != null
          ..selectedClient = client
          ..portfolio = portfolio;
      } else {
        basketController = Get.put(
          BasketController(
            fromClientScreen: client != null,
            portfolio: portfolio,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        trailingWidgets: [
          if (!isTopUpPortfolio)
            FilterActionButtons(
              showCaseWrapperKey: showCaseWrapperKey,
            ),
        ],
        titleText:
            fromClientInvestmentScreen ? portfolio!.title : 'Mutual Funds',
        subtitleText:
            fromClientInvestmentScreen ? 'Mutual fund portfolio ' : '',
      ),

      // Body
      body: GetBuilder<FundsController>(
        init: FundsController(
            portfolio: portfolio,
            isCustomPortfolio: isCustomPortfolio,
            isTopUpPortfolio: isTopUpPortfolio,
            filtersSaved: amc.isNotNullOrEmpty
                ? {
                    "amc": [amc!.toUpperCase()]
                  }
                : {}),
        dispose: (_) {
          Get.delete<FundsController>();
          if (isTopUpPortfolio) {
            Get.delete<BasketController>(tag: tag);
          } else {
            basketController.clearPortfolioParams();
          }
        },
        id: 'search',
        builder: (searchController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (fromClientInvestmentScreen && portfolioInvestment != null)
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30).copyWith(
                        top: 24,
                        bottom: 16,
                      ),
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
                  : SizedBox(),
              !isTopUpPortfolio ? SearchBarSection() : SizedBox(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: searchController.searchState == NetworkState.loading
                      ? SearchLoader()
                      : searchController.searchState == NetworkState.loaded
                          ?
                          // TODO: Show Search Results
                          SizedBox()
                          : FundListSection(
                              tag: tag,
                              funds: funds,
                              showBottomBasketAppBar: showBottomBasketAppBar,
                              isTopUpPortfolio: isTopUpPortfolio,
                            ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: showBottomBasketAppBar
          ? KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              if (isKeyboardVisible) {
                return SizedBox();
              }

              return GetBuilder<BasketController>(
                id: 'basket',
                global: !isTopUpPortfolio,
                init: Get.find<BasketController>(tag: tag),
                builder: (basketController) {
                  return basketController.basket.isEmpty
                      ? SizedBox()
                      : BasketBottomBar(
                          controller: basketController,
                          tag: tag,
                          fromCustomPortfolios: true,
                          fund: null,
                        );

                  // BasketBottomAppBar(
                  //     isTopUpPortfolio: isTopUpPortfolio,
                  //     portfolioExternalId: portfolio?.externalId,
                  //     fromScreen: "fund-list",
                  //     fundsCount: basketController.itemCount,
                  //     total: basketController.totalAmount,
                  //   );
                },
              );
            })
          : SizedBox(),
    );
  }
}
