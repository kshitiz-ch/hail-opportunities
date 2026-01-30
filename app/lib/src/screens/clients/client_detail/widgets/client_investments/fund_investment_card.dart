import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_investment_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FundInvestmentCard extends StatelessWidget {
  const FundInvestmentCard({
    Key? key,
    required this.fund,
    required this.anyFundPortfolio,
    required this.showAbsoluteReturn,
  }) : super(key: key);

  final SchemeMetaModel fund;
  final PortfolioInvestmentModel? anyFundPortfolio;
  final bool showAbsoluteReturn;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            );

    Client? client = Get.find<ClientDetailController>().client;
    return GetBuilder<MfInvestmentController>(
      init: MfInvestmentController(client),
      tag: fund.wschemecode,
      builder: (controller) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: ProductCardNew(
            bgColor: ColorConstants.primaryCardColor,
            title: fund.displayName,
            titleMaxLines: 4,
            leadingWidget: SizedBox(
              height: 36,
              width: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: CachedNetworkImage(
                  imageUrl: getAmcLogo(fund.displayName),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            onTap: () {
              _navigateToGoalScreen(context);
              // _navigateToTopUpFlow(context, controller);
            },
            // trailingWidget: SizedBox(
            //   width: 80,
            //   height: 36,
            //   child: ActionButton(
            //     customLoader: SizedBox(
            //       height: 15,
            //       width: 15,
            //       child: CircularProgressIndicator(
            //         strokeWidth: 1,
            //         color: ColorConstants.primaryAppColor,
            //       ),
            //     ),
            //     showProgressIndicator:
            //         controller.fundDetailState == NetworkState.loading,
            //     showBorder: true,
            //     borderColor: ColorConstants.primaryAppColor,
            //     borderRadius: 50,
            //     margin: EdgeInsets.zero,
            //     bgColor: ColorConstants.secondaryAppColor,
            //     text: 'Top Up',
            //     textStyle:
            //         Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            //               color: ColorConstants.primaryAppColor,
            //               fontWeight: FontWeight.w700,
            //             ),
            //     onPressed: () {
            //       _navigateToTopUpFlow(context, controller, fromTopUp: true);
            //     },
            //   ),
            // ),
            description: fund.fundCategory ?? '',
            bottomData: [
              BottomData(
                  title: WealthyAmount.currencyFormat(
                      fund.currentInvestedValue, 1),
                  subtitle: "Invested",
                  align: BottomDataAlignment.left,
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  flex: 1),
              BottomData(
                  title: WealthyAmount.currencyFormat(fund.currentValue, 1),
                  subtitle: "Current",
                  align: BottomDataAlignment.left,
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  flex: 1),
              BottomData(
                title: getReturnPercentageText(showAbsoluteReturn
                    ? fund.currentAbsoluteReturns
                    : fund.currentIrr),
                subtitle: showAbsoluteReturn ? "Abs. Return" : "IRR",
                align: BottomDataAlignment.left,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                // flex: 1
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToGoalScreen(BuildContext context) {
    ClientDetailController clientDetailController =
        Get.find<ClientDetailController>();
    AutoRouter.of(context).push(
      ClientGoalRoute(
        client: clientDetailController.client!,
        goalId: anyFundPortfolio?.externalId ?? '',
        mfInvestmentType: MfInvestmentType.Funds,
        wschemecodeSelected: fund.wschemecode,
      ),
    );
  }

  // void _navigateToTopUpFlow(
  //     BuildContext context, MfInvestmentController controller,
  //     {bool fromTopUp = false}) async {
  //   ClientDetailController clientDetailController =
  //       Get.find<ClientDetailController>();

  //   if (fromTopUp && !clientDetailController.client?.isProposalEnabled) {
  //     CommonUI.showBottomSheet(
  //       context,
  //       child: ClientNonIndividualWarningBottomSheet(),
  //     );
  //   } else {
  //     GoalSubtypeModel portfolio = GoalSubtypeModel.fromJson(
  //       {
  //         "external_id": anyFundPortfolio?.externalId,
  //         "product_variant": anyFundGoalSubtype,
  //         "title": anyFundPortfolio?.productName,
  //       },
  //     );

  //     await controller.getFundDetails(fund.basketKey ?? '');
  //     controller.fundDetail?.folioOverview = fund.folioOverview;

  //     if (controller.fundDetailState == NetworkState.loaded) {
  //       _navigateToFundDetailRoute(context, clientDetailController.client!,
  //           portfolio, controller.fundDetail,
  //           showBottomBasketAppBar:
  //               clientDetailController.client?.isClientIndividual);
  //     }

  //     if (controller.fundDetailState == NetworkState.error) {
  //       return showToast(
  //           text:
  //               'Failed to fetch details of this fund. Please try after some time');
  //     }
  //   }
  // }

  // void _navigateToFundDetailRoute(BuildContext context, Client client,
  //     GoalSubtypeModel portfolio, SchemeMetaModel? fundDetail,
  //     {bool showBottomBasketAppBar = false}) {
  //   Get.put<BasketController>(
  //     BasketController(
  //       selectedClient: client,
  //       fromClientScreen: true,
  //       portfolio: portfolio,
  //       isTopUpPortfolio: true,
  //     ),
  //     tag: anyFundPortfolio?.externalId,
  //   );

  //   if (!Get.isRegistered<BasketController>(
  //       tag: anyFundPortfolio?.externalId)) {
  //     return showToast(text: "Something went wrong. Please try again");
  //   }

  //   AutoRouter.of(context).push(
  //     FundDetailRoute(
  //       viaFundList: true,
  //       isTopUpPortfolio: true,
  //       fund: fundDetail,
  //       tag: portfolio.externalId,
  //       showBottomBasketAppBar: showBottomBasketAppBar,
  //       basketBottomBar: GetBuilder<BasketController>(
  //         global: false,
  //         id: 'basket',
  //         tag: anyFundPortfolio?.externalId,
  //         init: Get.find<BasketController>(tag: anyFundPortfolio?.externalId),
  //         builder: (controller) {
  //           if (controller.basket.containsKey(fundDetail?.basketKey)) {
  //             return Container(
  //               decoration: BoxDecoration(
  //                 border: Border(
  //                   top: BorderSide(
  //                     color: ColorConstants.lightGrey,
  //                     width: 1.0,
  //                   ),
  //                 ),
  //               ),
  //               child: ActionButton(
  //                 margin: EdgeInsets.all(30),
  //                 text: 'Continue',
  //                 height: 48,
  //                 onPressed: () {
  //                   AutoRouter.of(context).push(
  //                     BasketOverViewRoute(
  //                       fromCustomPortfolios:
  //                           controller.portfolio?.productVariant !=
  //                               anyFundGoalSubtype,
  //                       showAddMoreFundButton: false,
  //                       isTopUpPortfolio: controller.isTopUpPortfolio,
  //                       portfolioExternalId: controller.portfolio?.externalId,
  //                     ),
  //                   );
  //                 },
  //                 textStyle: Theme.of(context)
  //                     .primaryTextTheme
  //                     .headlineMedium!
  //                     .copyWith(
  //                       fontWeight: FontWeight.w700,
  //                       height: 1.4,
  //                       color: ColorConstants.white,
  //                     ),
  //               ),
  //             );
  //           } else {
  //             return Container(
  //               decoration: BoxDecoration(
  //                 border: Border(
  //                   top: BorderSide(
  //                     color: ColorConstants.lightGrey,
  //                     width: 1.0,
  //                   ),
  //                 ),
  //               ),
  //               child: ActionButton(
  //                 margin: EdgeInsets.all(30),
  //                 text: 'Add Fund',
  //                 height: 56,
  //                 onPressed: () {
  //                   addToBasket(context, controller, fundDetail!);
  //                 },
  //                 textStyle: Theme.of(context)
  //                     .primaryTextTheme
  //                     .headlineMedium!
  //                     .copyWith(
  //                       fontWeight: FontWeight.w700,
  //                       height: 1.4,
  //                       color: ColorConstants.white,
  //                     ),
  //               ),
  //             );
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  void addToBasket(
      context, BasketController controller, SchemeMetaModel fundDetail) {
    controller.addFundToBasket(
      fundDetail,
      context,
      null,
      toastMessage: null,
    );

    AutoRouter.of(context).push(
      BasketOverViewRoute(
        fromCustomPortfolios:
            controller.portfolio?.productVariant != anyFundGoalSubtype,
        showAddMoreFundButton: false,
        isTopUpPortfolio: controller.isTopUpPortfolio,
        portfolioExternalId: controller.portfolio?.externalId,
      ),
    );
  }
}
