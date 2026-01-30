import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_filters_bottomsheet.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_button_show_case.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'basket_bottom_bar.dart';

class FundListSection extends StatelessWidget {
  // Fields
  final String? tag;

  final List<SchemeMetaModel>? funds;
  final bool? showBottomBasketAppBar;
  final bool? isTopUpPortfolio;

  const FundListSection({
    Key? key,
    this.tag,
    this.showBottomBasketAppBar,
    this.isTopUpPortfolio,
    required this.funds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BasketController basketController = Get.find<BasketController>(tag: tag);

    // TODO: Refactor this widget
    return GetBuilder<FundsController>(
      id: 'funds',
      initState: (_) async {
        FundsController controller = Get.find<FundsController>();

        // If [funds] is null or empty, fetch data from API
        // else use [funds] to render data
        if (funds == null || funds!.isEmpty) {
          await controller.getMutualFunds(isRetry: true);
        } else {
          if (isTopUpPortfolio!) {
            List<SchemeMetaModel> nonDeprecatedFunds = funds!
                .where((SchemeMetaModel fund) => !fund.isDeprecated!)
                .toList();
            controller.fundsResult = nonDeprecatedFunds;
            controller.customPortfolioFunds = nonDeprecatedFunds;
          } else {
            controller.fundsResult = funds;
            controller.customPortfolioFunds = funds;
          }

          controller.fundsState = NetworkState.loaded;
        }
      },
      builder: (controller) {
        String headerText = "Wealthy Select Funds";
        if (controller.isTopUpPortfolio) {
          headerText = 'Funds in the portfolio';
        } else if (controller.searchText.isNotEmpty ||
            controller.filtersSaved.isNotEmpty) {
          headerText = "Your Search Results";
        }
        return Column(
          children: [
            SectionHeader(
              padding: EdgeInsets.symmetric(horizontal: 30),
              title: headerText,
              titleStyle:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.tertiaryBlack,
                      ),
              onTraiClick: () {},
              trailingTextStyle: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(
                      color: ColorConstants.tertiaryBlack,
                      fontWeight: FontWeight.w400,
                      fontSize: 11),
              trailingText: controller.fundsMetaData.totalCount != null
                  ? '${controller.fundsMetaData.totalCount} of 1000+ MUTUAL FUND${controller.fundsMetaData.totalCount == 1 ? '' : 'S'}'
                  : '',
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView(
                // in iOS default scroll behaviour is BouncingScrollPhysics
                // in android its ClampingScrollPhysics Setting
                //ClampingScrollPhysics explicitly for both
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                controller: controller.scrollController,
                children: [
                  // Title
                  if (controller.fundsResult!.length == 0 &&
                      controller.fundsState == NetworkState.loaded)
                    _buildEmptyState(context, controller)
                  else if (controller.fundsState == NetworkState.error)
                    _buildRetryWidget(controller)
                  else if (controller.fundsState == NetworkState.loading &&
                      !controller.isPaginating)
                    ..._buildShimmerCards(context, controller)
                  else if (controller.fundsState == NetworkState.loaded)
                    ..._buildFundCards(context, controller, basketController),
                  // Bottom Padding
                  SizedBox(
                    height: 26.0,
                  ),
                ],
              ),
            ),
            _buildInfiniteLoader()
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(context, FundsController controller) {
    if (controller.searchText.isEmpty && controller.filtersSaved.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AllImages().fundSearchIcon,
              width: 104,
            ),
            SizedBox(height: 24),
            Text(
              'Sorry! No funds found',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(
                      color: ColorConstants.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 8,
            ),
            if (!isTopUpPortfolio!)
              Text(
                'start searching for your favourite funds',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 13,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AllImages().fundSearchIcon,
              width: 104,
            ),
            Text(
              'Sorry! No result found',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(
                      color: ColorConstants.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'we couldn\'t find any match for that',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontSize: 13,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            if (controller.searchText.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 24),
                width: 150,
                child: ActionButton(
                  height: 40,
                  margin: EdgeInsets.zero,
                  text: 'Search all funds',
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                  onPressed: () {
                    controller.resetFilter();
                    controller.saveFiltersAndSorting();
                    controller.clearSearchBar();
                  },
                ),
              ),
            if (controller.filtersSaved.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: ClickableText(
                  text: 'CHANGE FILTERS',
                  fontSize: 12,
                  fontHeight: 2,
                  onClick: () {
                    CommonUI.showBottomSheet(
                      context,
                      borderRadius: 16.0,
                      isScrollControlled: true,
                      child: FundFiltersBottomSheet(),
                    ).then((value) {
                      controller.removeNonSavedFilters();
                    });
                  },
                ),
              )
          ],
        ),
      );
    }
  }

  Widget _buildRetryWidget(FundsController controller) {
    return SizedBox(
      height: 500,
      child: RetryWidget(
        controller.fundsErrorMessage,
        onPressed: () => controller.getMutualFunds(),
      ),
    );
  }

  List<Container> _buildShimmerCards(context, FundsController controller) {
    List shimmerList = List.filled(
      3,
      SchemeMetaModel(),
    );

    return shimmerList.map(
      (fund) {
        return Container(
          height: 260,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProductCard().toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          ),
        );
      },
    ).toList();

    // return  ...List.filled(
    //                     3,
    //                     SchemeMeta(),
    //                   ).map(
    //                     (fund) {
    //                       return Container(
    //                         height: 250,
    //                         padding:
    //                             const EdgeInsets.symmetric(horizontal: 16.0),
    //                         child: AnimatedSwitcher(
    //                           duration: Duration(milliseconds: 500),
    //                           child: controller.fundsState ==
    //                                       NetworkState.loading &&
    //                                   !controller.isPaginating
    //                               ? ProductCard().toShimmer(
    //                                   baseColor:
    //                                       ColorConstants.lightBackgroundColor,
    //                                   highlightColor: ColorConstants.white,
    //                                 )
    //                               : _buildProductCard(
    //                                   context, fund, basketController),
    //                         ),
    //                       );
    //                     },
    //                   ).toList();
  }

  List<Container> _buildFundCards(
    context,
    FundsController controller,
    BasketController basketController,
  ) {
    return controller.fundsResult!.mapIndexed((fund, index) {
      bool showAdditionaBottomData =
          isTopUpPortfolio! && (fund.folioOverview?.exists ?? false);
      return Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 12),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: _buildProductCard(context, fund, basketController, index,
              showAdditionalBottomData: showAdditionaBottomData),
        ),
      );
    }).toList();
  }

  Widget _buildInfiniteLoader() {
    return GetBuilder<FundsController>(
        id: 'pagination-loader',
        builder: (controller) {
          if (controller.isPaginating) {
            return Container(
              height: 30,
              margin: EdgeInsets.only(bottom: 10, top: 10),
              alignment: Alignment.center,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }

          return SizedBox();
        });
  }

  Widget _buildProductCard(
    BuildContext context,
    SchemeMetaModel fund,
    BasketController basketController,
    int index, {
    required bool showAdditionalBottomData,
  }) {
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
    final Key textFieldKey = UniqueKey();
    ShowCaseController? showCaseController;
    if (Get.isRegistered<ShowCaseController>()) {
      showCaseController = Get.find<ShowCaseController>();
    }

    return ProductCardNew(
      borderRadius: 16,
      bgColor: ColorConstants.primaryCardColor,
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
      title: fund.displayName,
      titleMaxLines: 2,
      descriptionMaxLines: 2,
      description: '${getFundDescription(fund)}',
      trailingWidget: GetBuilder<BasketController>(
        id: 'basket',
        global: !isTopUpPortfolio!,
        init: Get.find<BasketController>(tag: tag),
        builder: (basketController) {
          if (index == 0 &&
              !basketController.basket.containsKey(fund.basketKey) &&
              showCaseIds.MutualFundAddButton.id ==
                  showCaseController!.activeShowCaseId) {
            return FundListButtonShowCase(
              textFieldKey: textFieldKey,
              showCaseController: showCaseController,
              child: _buildAddButton(context, fund, basketController),
              onTargetClick: () {
                AutoRouter.of(context).push(
                  FundDetailRoute(
                    viaFundList: true,
                    isTopUpPortfolio: isTopUpPortfolio,
                    fund: fund,
                    tag: tag,
                    fromCustomPortfolios: true,
                    basketBottomBar: BasketBottomBar(
                      tag: tag,
                      controller: basketController,
                      fromCustomPortfolios: true,
                      fund: fund,
                    ),
                  ),
                );
              },
            );
          }
          return basketController.basket.containsKey(fund.basketKey)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WealthyAmount.currencyFormat(
                        basketController.basket[fund.basketKey]!.amountEntered,
                        0,
                        showSuffix: false,
                      ),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.black,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: buildAddedWidget(
                        context,
                        iconColor: ColorConstants.greenAccentColor,
                        fillColor: Color(0xffE9FFEF),
                      ),
                    ),
                  ],
                )
              : _buildAddButton(context, fund, basketController);
        },
      ),

      // shadowSize : CardShadowSize.small,
      onTap: () {
        AutoRouter.of(context).push(
          FundDetailRoute(
            tag: tag,
            viaFundList: true,
            isTopUpPortfolio: isTopUpPortfolio,
            fund: fund,
            fromCustomPortfolios: true,
            basketBottomBar: BasketBottomBar(
              controller: basketController,
              tag: tag,
              fromCustomPortfolios: true,
              fund: fund,
            ),
          ),
        );
      },
      bottomData: getProductBottomData(
        fund,
        isTopUpPortfolio: isTopUpPortfolio,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
      ),
      additionalBottomData: showAdditionalBottomData
          ? Container(
              // height: additionalBottomDataHeight,
              padding: EdgeInsets.symmetric(vertical: 10),
              // color: ColorConstants.primaryAppColor.withOpacity(0.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                color: ColorConstants.lavenderColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Invested Value',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 13, color: ColorConstants.darkGrey),
                        ),
                        SizedBox(height: 2),
                        Text(
                          WealthyAmount.currencyFormat(
                              fund.folioOverview!.investedValue, 0),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 25,
                    color: ColorConstants.secondarySeparatorColor,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Current Value',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 13, color: ColorConstants.darkGrey),
                        ),
                        SizedBox(height: 2),
                        Text(
                          WealthyAmount.currencyFormat(
                              fund.folioOverview!.currentValue, 0),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    SchemeMetaModel fund,
    BasketController controller,
  ) {
    return TextButton(
      onPressed: () {
        addToBasket(controller, context, fund);
      },
      child: Text('+ Add'),
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.primaryAppColor,
              ),
        ),
        fixedSize: MaterialStateProperty.all<Size>(Size(72, 32)),
        backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.white),
        alignment: Alignment.center,
      ),
    );
  }

  void addToBasket(
    BasketController controller,
    BuildContext context,
    SchemeMetaModel fund,
  ) {
    controller.addFundToBasket(
      fund,
      context,
      null,
      toastMessage: null,
    );

    // show toast
    showCustomToast(
      context: context,
      child: Container(
        width: SizeConfig().screenWidth,
        margin: const EdgeInsets.only(bottom: 0),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: ColorConstants.black.withOpacity(0.9),
        ),
        child: Text(
          "Fund Added to Basket ✅",
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.white,
              ),
        ),
      ),
    );
    // AutoRouter.of(context).push(
    //   BasketOverViewRoute(
    //     fromCustomPortfolios: true,
    //     isUpdateProposal: controller.isUpdateProposal,
    //     isTopUpPortfolio: controller.isTopUpPortfolio,
    //     portfolioExternalId: controller.portfolio?.externalId,
    //   ),
    // );
  }
}

Widget buildAddedWidget(
  BuildContext context, {
  Color? fillColor,
  Color? iconColor,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor ?? ColorConstants.greenAccentColor,
        ),
        child: Icon(
          Icons.done_rounded,
          size: 10,
          color: iconColor ?? ColorConstants.white,
        ),
      ),
      Text(
        ' Added',
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.greenAccentColor,
            ),
      )
    ],
  );
}
