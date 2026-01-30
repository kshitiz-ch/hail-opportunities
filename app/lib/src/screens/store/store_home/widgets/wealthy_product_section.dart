import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/store_home/widgets/card_list.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart' show IterableNullableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WealthyProductSection extends StatelessWidget {
  const WealthyProductSection({Key? key, this.controller}) : super(key: key);

  final StoreController? controller;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    List products =
        controller!.popularProductsResult.wealthyStoreProducts.products;

    products = products.whereNotNull().toList();

    // remove demat product for employee
    if (isEmployeeLoggedIn()) {
      products.removeWhere((product) =>
          product?.productType?.toLowerCase() == ProductType.DEMAT);
    }

    return (controller!.popularProductsState == NetworkState.loaded &&
            products.isEmpty)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                // Section Header
                SectionHeader(
                  title: 'Popular Investment Products',
                  subtitle: 'Top products from Wealthy',
                ),
                SizedBox(
                  height: 16,
                ),
                // Card List
                CardList(
                  height: 230,
                  viewportFraction: 0.8,
                  itemCount: controller!.popularProductsState ==
                          NetworkState.error
                      ? 1
                      : controller!.popularProductsState == NetworkState.loading
                          ? 2
                          : min(4, products.length),
                  itemBuilder: (context, index) {
                    bool isInsurance = false;
                    bool isDemat = false;
                    var product;

                    if (products.length > 0) {
                      product = products[index];
                    }

                    return Container(
                      width:
                          controller!.popularProductsState == NetworkState.error
                              ? screenWidth * 0.9
                              : screenWidth * 0.8,
                      padding: const EdgeInsets.symmetric(horizontal: 6.5),
                      child: controller!.popularProductsState ==
                              NetworkState.loading
                          ? ProductCard().toShimmer(
                              baseColor: ColorConstants.lightBackgroundColor,
                              highlightColor: ColorConstants.white,
                            )
                          : controller!.popularProductsState ==
                                  NetworkState.error
                              ? RetryWidget(
                                  controller!.popularProductsErrorMessage,
                                  onPressed: () => controller!
                                      .getPopularProducts(isRetry: true),
                                )
                              : product != null
                                  ? _buildProductCard(context, product)
                                  : SizedBox.shrink(),
                    );
                  },
                )
              ],
            ),
          );
  }

  Widget _buildProductCard(BuildContext context, product) {
    String? productType = product?.productType?.toLowerCase();
    bool isInsurance = productType == ProductType.SAVINGS ||
        productType == ProductType.TERM ||
        productType == ProductType.HEALTH ||
        productType == ProductType.TWO_WHEELER;
    bool isDemat = productType == ProductType.DEMAT;

    if (isInsurance) {
      return _buildInsuranceProductCard(context, product);
    }

    // TODO: Temporary
    if (isDemat) {
      return _buildDematProductCard(context);
    }

    return _buildInvestmentProductCard(context, product);
  }

  Widget _buildDematProductCard(BuildContext context) {
    return ProductCardNew(
      bgColor: ColorConstants.primaryCardColor,
      title: 'Broking Demat Account',
      leadingWidget: Container(
        width: 36,
        height: 36,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Image.asset(
          AllImages().storeDematIcon,
        ),
      ),
      description: 'Open a demat account for free',
      onTap: () {
        openDematStoreScreen(
          context: context,
          selectedClient: controller?.selectedClient,
        );
      },
      bottomData: [
        BottomData(
            title: WealthyAmount.currencyFormat(0, 0),
            subtitle: "Opening Charges",
            align: BottomDataAlignment.center,
            // titleStyle: titleStyle,
            // subtitleStyle: subtitleStyle,
            flex: 1),
        BottomData(
            title: '${WealthyAmount.currencyFormat(0, 0)}*',
            customSubtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'AMC',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.secondaryBlack,
                            height: 1.4,
                            fontSize: 12,
                          ),
                ),
                Text(
                  '(*for first year)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.secondaryBlack,
                        fontWeight: FontWeight.w600,
                        height: 1.7,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
            // subtitle: "AMC",
            align: BottomDataAlignment.center,
            // titleStyle: titleStyle,
            // subtitleStyle: subtitleStyle,
            flex: 1),
      ],
    );
  }

  Widget _buildInsuranceProductCard(context, product) {
    return ProductCardNew(
      bgColor: ColorConstants.primaryCardColor,
      showSeparator: false,
      leadingWidget: product.iconSvg != null && product.iconSvg.endsWith("svg")
          ? SvgPicture.network(
              product.iconSvg,
              width: 36,
              height: 36,
            )
          : Image.network(
              product.iconSvg,
              width: 36,
              height: 36,
            ),
      title: product.title,
      description: getProductTypeDescription(product.productType),
      onTap: () async {
        AutoRouter.of(context).push(
          InsuranceDetailRoute(
              insuranceData: product,
              selectedClient: controller!.selectedClient),
        );
      },
    );
  }

  Widget _buildInvestmentProductCard(BuildContext context, product) {
    return ProductCardNew(
      bgColor: ColorConstants.primaryCardColor,
      showSeparator: false,
      bottomData: getProductBottomData(
        product,
        isShownOnStore: true,
      ),
      leadingWidget: product?.iconSvg != null && product.iconSvg.endsWith("svg")
          ? SvgPicture.network(product.iconSvg, width: 36, height: 36)
          : Image.network(
              product?.iconSvg,
              width: 36,
              height: 36,
            ),
      title: product?.title,
      description: getProductTypeDescription(product.productType),
      onTap: () async {
        var productType = product.productType.toLowerCase();
        if (productType == ProductType.MF) {
          if (product.productVariant == otherFundsGoalSubtype) {
            AutoRouter.of(context).push(FundListRoute(
              client: controller!.selectedClient,
              portfolio: product,
              isCustomPortfolio: true,
              showBottomBasketAppBar: false,
            ));
          } else {
            AutoRouter.of(context).push(
              MfPortfolioDetailRoute(
                client: controller!.selectedClient,
                portfolio: product,
                isSmartSwitch: product.isSmartSwitch,
              ),
            );
          }
        } else if (productType == ProductType.UNLISTED_STOCK) {
          AutoRouter.of(context).push(
            PreIpoDetailRoute(
              client: controller!.selectedClient,
              product: product,
            ),
          );
        } else if (productType == ProductType.DEBENTURE) {
          AutoRouter.of(context).push(DebentureDetailRoute(
            client: controller!.selectedClient,
            product: product,
          ));
        } else if (productType == ProductType.FIXED_DEPOSIT) {
          AutoRouter.of(context).push(FixedDepositListRoute(
            client: controller!.selectedClient,
          ));
        }
      },
    );
  }
}
