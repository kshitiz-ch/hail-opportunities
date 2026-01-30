import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_product_investment_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/pms_product_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/client_portfolio_overview_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ProductInvestmentListScreen extends StatelessWidget {
  ProductInvestmentListScreen({
    Key? key,
    required this.productType,
    required this.portfolioOverview,
    this.productList,
    this.asOn,
    this.isMf = false,
    this.mfProducts,
  }) : super(key: key);

  final ClientInvestmentProductType productType;
  final GenericPortfolioOverviewModel portfolioOverview;
  final DateTime? asOn;
  final List? productList;
  final bool isMf;
  final MfProductsInvestmentModel? mfProducts;

  @override
  Widget build(BuildContext context) {
    Client? client = Get.find<ClientDetailController>().client;
    return GetBuilder<ClientProductInvestmentController>(
      init: ClientProductInvestmentController(
        client: client!,
        productType: productType,
      ),
      builder: (controller) {
        final isPms = productType == ClientInvestmentProductType.pms;
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: getClientInvestmentProductTitle(productType),
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 70),
            child: Column(
              children: [
                ClientProductOverviewCard(
                  overview: portfolioOverview,
                  asOn: asOn,
                  productType: productType,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: CommonClientUI.showEmptyFoliosCheckbox(
                        context,
                        controller.showEmptyFolios,
                        () {
                          if (controller.investmentDetailsResponse.state ==
                              NetworkState.loading) {
                            return;
                          }
                          controller.toggleShowEmptyFolios();
                        },
                      ),
                    ),
                    _buildProductList(controller, context),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductList(
      ClientProductInvestmentController controller, BuildContext context) {
    if (controller.investmentDetailsResponse.state == NetworkState.loading) {
      return ListView.separated(
        itemCount: 3,
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(height: 20);
        },
        itemBuilder: (context, index) {
          return SkeltonLoaderCard(
            height: 100,
          );
        },
      );
    }

    if (controller.investmentDetailsResponse.state == NetworkState.error) {
      return RetryWidget(
        'Something went wrong. Please try again',
        onPressed: controller.getProductInvestmentDetails,
      );
    }

    if (controller.investmentDetailsResponse.state == NetworkState.loaded &&
        controller.products.isEmpty) {
      return EmptyScreen(
        message: 'No Products Found',
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${getClientInvestmentProductTitle(productType)} Portfolios (${controller.products.length})',
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            if (productType == ClientInvestmentProductType.pms)
              CommonClientUI.absoluteAnnualisedSwitch(
                context,
                showAbsoluteReturn: controller.showAbsoluteReturn,
                onTap: () {
                  controller.toggleAbsoluteReturn();
                },
              ),
          ],
        ),
        SizedBox(height: 16),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.products.length,
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return SizedBox(height: 20);
          },
          itemBuilder: (context, index) {
            ProductInvestmentModel product = controller.products[index];
            if (productType == ClientInvestmentProductType.pms) {
              return PMSProductCard(
                product: product,
                showAbsoluteReturn: controller.showAbsoluteReturn,
              );
            }
            return ProductCardNew(
              bgColor: ColorConstants.primaryCardColor,
              title: product.name,
              titleMaxLines: 3,
              onTap: () async {},
              bottomData: _getGenericProductBottomData(product),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _getGenericProductBottomData(ProductInvestmentModel product) {
    return [
      BottomData(
        title: WealthyAmount.currencyFormatWithoutTrailingZero(
            product.currentValue, 2),
        subtitle: "Current Value",
        align: BottomDataAlignment.center,
        flex: 1,
      ),
      BottomData(
        title: WealthyAmount.currencyFormatWithoutTrailingZero(
            product.investedValue, 2),
        subtitle: "Invested Value",
        align: BottomDataAlignment.center,
        flex: 1,
      ),
    ];
  }
}

Widget buildReturnType({
  required bool showAbsouteReturn,
  required BuildContext context,
  Function? onTap,
}) {
  final isDisabled = onTap == null;
  return InkWell(
    onTap: () {
      if (isDisabled) return;
      onTap();
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          showAbsouteReturn ? 'Absolute' : 'XIRR',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        SizedBox(width: 2),
        if (!isDisabled)
          Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConstants.primaryAppColor,
            size: 10,
          ),
        if (!isDisabled)
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorConstants.primaryAppColor,
            size: 10,
          ),
      ],
    ),
  );
}
