import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketBottomBar extends StatelessWidget {
  BasketBottomBar({
    Key? key,
    this.tag,
    required this.fund,
    this.fromCustomPortfolios = false,
    required this.controller,
  }) : super(key: key);

  final String? tag;
  final SchemeMetaModel? fund;
  final bool fromCustomPortfolios;
  final BasketController? controller;

  // void navigateToBasketScreen(context) {
  //   AutoRouter.of(context).push(
  //     SelectClientRoute(
  //       checkIsClientIndividual: true,
  //       lastSelectedClient: controller?.selectedClient,
  //       onClientSelected: (client, isClientNew) {
  //         // If client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
  //         if (isClientNew ||
  //             (client?.isSourceContacts ?? false) ||
  //             client?.taxyID != controller?.selectedClient?.taxyID) {
  //           controller?.similarProposalsList = [];
  //           controller?.hasCheckedSimilarProposals = false;
  //         }

  //         if (isClientNew) {
  //           AutoRouter.of(context).popForced();
  //         }

  //         AutoRouter.of(context).popForced();
  //         AutoRouter.of(context).push(BasketOverViewRoute(
  //           fromCustomPortfolios: fromCustomPortfolios,
  //           isTopUpPortfolio: controller!.isTopUpPortfolio,
  //           portfolioExternalId: controller!.portfolio?.externalId,
  //         ));

  //         controller?.selectedClient = client;
  //         controller?.update(['basket']);
  //       },
  //     ),
  //   );
  //   // AutoRouter.of(context).push(
  //   //   BasketOverViewRoute(
  //   //     fromCustomPortfolios: fromCustomPortfolios,
  //   //     isTopUpPortfolio: controller!.isTopUpPortfolio,
  //   //     portfolioExternalId: controller!.portfolio?.externalId,
  //   //   ),
  //   // );
  // }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: GetBuilder<BasketController>(
        id: 'basket',
        global: tag != null ? false : true,
        init: Get.find<BasketController>(tag: tag),
        builder: (controller) {
          ShowCaseController? showCaseController;
          if (Get.isRegistered<ShowCaseController>()) {
            showCaseController = Get.find<ShowCaseController>();
          }

          Widget dynamicWidget;
          if (fund == null) {
            dynamicWidget = addedToBasketWidget(
                context: context,
                controller: controller,
                showCaseController: showCaseController,
                fromCustomPortfolios: fromCustomPortfolios);
          } else if (controller.basket.isEmpty) {
            dynamicWidget =
                addToEmptyBasketWidget(context, showCaseController!);
          } else if (controller.basket.containsKey(fund?.basketKey)) {
            dynamicWidget = addedToBasketWidget(
                context: context,
                controller: controller,
                showCaseController: showCaseController,
                canDisplayShowCase: true,
                fromCustomPortfolios: fromCustomPortfolios);
          } else {
            dynamicWidget = addToNonEmptyBasketWidget(
                context: context, controller: controller);
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: dynamicWidget,
          );
        },
      ),
    );
  }

  Widget addToEmptyBasketWidget(
      BuildContext context, ShowCaseController showCaseController) {
    if (showCaseController.activeShowCaseId ==
        showCaseIds.AddFundMainButton.id) {
      return ShowCaseWrapper(
        currentShowCaseId: showCaseIds.AddFundMainButton.id,
        minRadius: 24,
        maxRadius: 44,
        constraints: BoxConstraints(
          maxHeight: 68,
          minHeight: 48,
          maxWidth: deviceSpecificValue(
              context,
              MediaQuery.of(context).size.width - 30,
              MediaQuery.of(context).size.width / 2 + 40),
          minWidth: deviceSpecificValue(
              context,
              MediaQuery.of(context).size.width - 60,
              MediaQuery.of(context).size.width / 2),
        ),
        onTargetClick: () async {
          await showCaseController.setActiveShowCase();
          controller!.update(['basket']);
          addToBasket(context);
        },
        child: InkWell(
          onTap: () async {
            if (showCaseController.activeShowCaseId ==
                showCaseIds.AddFundMainButton.id) {
              await showCaseController.setActiveShowCase();
              controller!.update(['basket']);
              addToBasket(context);
            }
          },
          child: IgnorePointer(
            ignoring: true,
            child: addFundButton(context),
          ),
        ),
      );
    }

    return addFundButton(context);
  }

  Widget addFundButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ColorConstants.lightGrey,
            width: 1.0,
          ),
        ),
      ),
      child: ActionButton(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        text: 'Add Fund',
        height: 56,
        onPressed: () {
          MixPanelAnalytics.trackWithAgentId(
            "add_fund",
            screen: 'bottom_bar',
            screenLocation: 'bottom_bar',
            properties: {"fund_name": fund?.displayName ?? "-"},
          );
          addToBasket(context);
        },
        textStyle: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: ColorConstants.white,
            ),
      ),
    );
  }

  Widget addedToBasketWidget(
      {required BuildContext context,
      required BasketController controller,
      ShowCaseController? showCaseController,
      bool canDisplayShowCase = false,
      bool fromCustomPortfolios = false}) {
    bool displayViewBasketShowCase = false;
    if (canDisplayShowCase &&
        showCaseController != null &&
        showCaseController.activeShowCaseId ==
            showCaseIds.ViewBasketButton.id) {
      displayViewBasketShowCase = true;
    }

    if (displayViewBasketShowCase) {
      showCaseController!.setShowCaseVisibleCurrently(true);
    }

    return Container(
      decoration: BoxDecoration(
          border: Border(
        top: BorderSide(
          color: ColorConstants.lightGrey,
          width: 1.0,
        ),
      )),
      padding: EdgeInsets.fromLTRB(30, 12, 30, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.itemCount.toString() +
                        ' Fund' +
                        (controller.itemCount > 1 ? 's' : ''),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                  Text(
                    WealthyAmount.currencyFormat(controller.totalAmount, 2),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: ColorConstants.black,
                        ),
                  )
                ],
              ),
              Spacer(),
              SizedBox(
                width: 180,
                child: ActionButton(
                  margin: EdgeInsets.zero,
                  text: controller.selectedClient != null
                      ? 'View Basket'
                      : 'Continue',
                  prefixWidget: Padding(
                    padding: EdgeInsets.only(right: 5, top: 2),
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                  ),
                  height: 56,
                  onPressed: () {
                    navigateToBasketScreen(context, controller,
                        fromCustomPortfolios: fromCustomPortfolios);
                  },
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: ColorConstants.white,
                      ),
                ),
              )
            ],
          ),
          if (fund != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 18.0,
              ),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.separatorColor,
              ),
            ),
          if (fund != null)
            Center(
              child: ClickableText(
                text: 'Add more funds',
                padding: EdgeInsets.only(top: 10),
                fontWeight: FontWeight.w700,
                fontSize: 16,
                onClick: () {
                  if (fromCustomPortfolios) {
                    if (controller.isTopUpPortfolio) {
                      if (isRouteNameInStack(context, FundListRoute.name)) {
                        AutoRouter.of(context)
                            .popUntilRouteWithName(FundListRoute.name);
                      } else {
                        AutoRouter.of(context).push(FundListRoute());
                      }
                    } else {
                      if (isRouteNameInStack(context, FundListRoute.name)) {
                        AutoRouter.of(context)
                            .popUntilRouteWithName(MfListRoute.name);
                      } else {
                        AutoRouter.of(context)
                            .push(MfListRoute(isCustomPortfoliosScreen: true));
                      }
                    }
                  } else if (isRouteNameInStack(context, MfListRoute.name)) {
                    AutoRouter.of(context)
                        .popUntilRouteWithName(MfListRoute.name);
                  } else if (isRouteNameInStack(context, MfLobbyRoute.name)) {
                    AutoRouter.of(context).popUntilRouteWithName(
                      MfLobbyRoute.name,
                    );
                  } else {
                    AutoRouter.of(context).popForced();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget addToNonEmptyBasketWidget(
      {required BuildContext context, required BasketController controller}) {
    return Container(
      decoration: BoxDecoration(
          color: ColorConstants.white,
          border: Border(
            top: BorderSide(
              color: ColorConstants.lightGrey,
            ),
          )),
      padding: const EdgeInsets.symmetric(horizontal: 14)
          .copyWith(top: 20, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                margin: EdgeInsets.zero,
                text: 'Add to Basket',
                height: 48,
                onPressed: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "add_to_basket",
                    screen: 'bottom_bar',
                    screenLocation: 'bottom_bar',
                    properties: {"fund_name": fund?.displayName},
                  );

                  addToBasket(
                    context,
                  );
                },
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: ColorConstants.white,
                        ),
              ),
              SizedBox(
                width: 16,
              ),
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                margin: EdgeInsets.zero,
                bgColor: ColorConstants.secondaryAppColor,
                text: controller.selectedClient != null
                    ? 'View Basket'
                    : 'Continue',
                prefixWidget: Padding(
                  padding: EdgeInsets.only(right: 5, top: 2),
                  child: Icon(
                    Icons.shopping_cart,
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
                height: 56,
                onPressed: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "view_basket",
                    screen: 'bottom_bar',
                    screenLocation: 'bottom_bar',
                  );

                  navigateToBasketScreen(context, controller,
                      fromCustomPortfolios: fromCustomPortfolios);
                },
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: ColorConstants.primaryAppColor,
                        ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 15),
            child: CommonUI.buildProfileDataSeperator(color: Color(0xffF2F2F2)),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${controller.itemCount} Fund${controller.itemCount > 1 ? 's  ' : ' '}',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
              children: [
                if (controller.totalAmount > 0)
                  TextSpan(
                    text:
                        WealthyAmount.currencyFormat(controller.totalAmount, 2),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: ColorConstants.black,
                        ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  void addToBasket(BuildContext context) {
    validateAndAddFund(context, controller!, fund!, () {
      controller!.addFundToBasket(
        fund!,
        context,
        null,
        toastMessage: null,
      );

      navigateToBasketScreen(context, controller,
          fromCustomPortfolios: fromCustomPortfolios);
    });

    // AutoRouter.of(context).popForced();

    // show toast
    // showCustomToast(
    //   context: context,
    //   child: Container(
    //     width: SizeConfig().screenWidth,
    //     margin: const EdgeInsets.only(bottom: 0),
    //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    //     decoration: BoxDecoration(
    //       color: ColorConstants.black.withOpacity(0.9),
    //     ),
    //     child: Text(
    //       "Fund Added to Basket ✅",
    //       style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
    //             color: ColorConstants.white,
    //           ),
    //     ),
    //   ),
    // );
  }
}
