import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MfProductCard extends StatelessWidget {
  const MfProductCard({
    Key? key,
    this.fund,
    this.basketController,
    this.index,
  }) : super(key: key);

  final SchemeMetaModel? fund;
  final BasketController? basketController;
  final int? index;

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

    return ProductCardNew(
      borderRadius: 16,
      bgColor: ColorConstants.primaryCardColor,
      leadingWidget: SizedBox(
        height: 36,
        width: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: CachedNetworkImage(
            imageUrl: getAmcLogo(fund?.displayName),
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: fund?.displayName,
      titleMaxLines: 2,
      descriptionMaxLines: 2,
      description:
          '${fundTypeDescription(fund!.fundType)} ${fund!.fundCategory != null ? "| ${fund!.fundCategory}" : ""}',

      trailingWidget: GetBuilder<BasketController>(
        id: 'basket',
        global: true,
        init: Get.find<BasketController>(),
        builder: (basketController) {
          return basketController.basket.containsKey(fund!.basketKey)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WealthyAmount.currencyFormat(
                        basketController.basket[fund!.basketKey]!.amountEntered,
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
                      child: _buildAddedWidget(
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
            viaFundList: true,
            isTopUpPortfolio: false,
            fund: fund,
            basketBottomBar: BasketBottomBar(
              controller: basketController,
              fund: fund,
            ),
          ),
        );
      },
      bottomData: getProductBottomData(
        fund,
        isTopUpPortfolio: false,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
      ),
    );
  }

  Widget _buildAddedWidget(
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

  Widget _buildAddButton(
    BuildContext context,
    SchemeMetaModel? fund,
    BasketController controller,
  ) {
    return TextButton(
      onPressed: () {
        addToBasket(controller, context);
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
  ) {
    controller.addFundToBasket(
      fund!,
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
    AutoRouter.of(context).push(
      BasketOverViewRoute(
        isUpdateProposal: controller.isUpdateProposal,
        isTopUpPortfolio: controller.isTopUpPortfolio,
        portfolioExternalId: controller.portfolio?.externalId,
      ),
    );
  }
}
