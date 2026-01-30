import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketIcon extends StatelessWidget {
  final bool? isTopUpPortfolio;
  final Function? onTap;
  final String? tag;
  final bool fromCustomPortfolios;
  final bool clickedFromFundDetailScreen;

  const BasketIcon(
      {Key? key,
      this.isTopUpPortfolio,
      this.tag,
      this.onTap,
      this.fromCustomPortfolios = false,
      this.clickedFromFundDetailScreen = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasketController>(
      id: 'basket',
      // global: !isTopUpPortfolio!,
      // init: Get.find<BasketController>(tag: tag),
      builder: (controller) {
        return InkWell(
          onTap: () {
            MixPanelAnalytics.trackWithAgentId(
              "cart_click",
              screen: clickedFromFundDetailScreen ? 'fund_details' : 'store',
              screenLocation:
                  clickedFromFundDetailScreen ? 'fund_details' : 'mutual_fund',
            );

            navigateToBasketScreen(
              context,
              controller,
              fromCustomPortfolios: fromCustomPortfolios,
            );
          },
          child: Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Image.asset(
                    AllImages().fundBasketIconNew,
                    width: 32,
                    height: 28,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorConstants.secondaryGrey,
                  ),
                  child: Text(
                    controller.itemCount.toString(),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(
                            height: 1,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
