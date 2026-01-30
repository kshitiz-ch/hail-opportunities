import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_section.dart';
import 'package:app/src/screens/store/store_home/widgets/card_list.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/card/responsive_card_container.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFundsSection extends StatelessWidget {
  const PopularFundsSection({Key? key, required this.controller})
      : super(key: key);

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<SchemeMetaModel> products =
        controller.popularProductsResult.fundsModel.products;

    final basketController = Get.isRegistered<BasketController>()
        ? Get.find<BasketController>()
        : Get.put(
            BasketController(),
          );

    return (controller.popularProductsState == NetworkState.loaded &&
            products.isEmpty)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                SectionHeader(
                  title: 'Popular Funds',
                  subtitle: 'Top selling funds',
                  onTraiClick: () {
                    AutoRouter.of(context).push(
                      MfLobbyRoute(client: controller.selectedClient),
                    );
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                CardList(
                  height: 230,
                  itemCount: controller.popularProductsState ==
                          NetworkState.error
                      ? 1
                      : controller.popularProductsState == NetworkState.loading
                          ? 2
                          : min(5, products.length),
                  viewportFraction: 0.8,
                  itemBuilder: (context, index) {
                    return ResponsiveCardContainer(
                      width:
                          controller.popularProductsState == NetworkState.error
                              ? screenWidth * 0.9
                              : screenWidth * 0.8,
                      constraints: BoxConstraints(
                        maxWidth: SizeConfig().screenWidth! * 0.65,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: controller.popularProductsState ==
                                  NetworkState.loading
                              ? ProductCard().toShimmer(
                                  baseColor:
                                      ColorConstants.lightBackgroundColor,
                                  highlightColor: ColorConstants.white,
                                )
                              : controller.popularProductsState ==
                                      NetworkState.error
                                  ? RetryWidget(
                                      controller.popularProductsErrorMessage,
                                      onPressed: () => controller
                                          .getPopularProducts(isRetry: true),
                                    )
                                  : _buildProductCard(products[index], context,
                                      basketController),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }

  ProductCardNew _buildProductCard(
    SchemeMetaModel fund,
    BuildContext context,
    BasketController basketController,
  ) {
    return ProductCardNew(
      bgColor: ColorConstants.primaryCardColor,
      leadingWidget: CommonUI.buildRoundedFullAMCLogo(
          radius: 20, amcName: fund.displayName),
      title: fund.displayName,
      titleMaxLines: 2,
      description:
          '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "| ${fund.fundCategory}" : ""}',
      trailingWidget: GetBuilder<BasketController>(
        id: 'basket',
        builder: (basketController) {
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
      onTap: () {
        _handleOnPressed(context, fund, basketController);
      },
      bottomData: getProductBottomData(fund),
    );
  }

  void _handleOnPressed(BuildContext context, SchemeMetaModel fund,
      BasketController basketController) {
    AutoRouter.of(context).push(
      FundDetailRoute(
        isTopUpPortfolio: basketController.isTopUpPortfolio,
        fund: fund,
        basketBottomBar: BasketBottomBar(
          fund: fund,
          controller: basketController,
        ),
      ),
    );
  }

  Widget _buildAddButton(
      BuildContext context, SchemeMetaModel fund, BasketController controller) {
    return TextButton(
      onPressed: () {
        _handleOnPressed(context, fund, controller);
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
}
