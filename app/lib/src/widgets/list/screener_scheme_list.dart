import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenerSchemeList extends StatelessWidget {
  const ScreenerSchemeList({
    Key? key,
    required this.controller,
    this.fromListScreen = false,
    this.showMfRating = true,
  }) : super(key: key);

  final ScreenerController controller;
  final bool fromListScreen;
  final bool showMfRating;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: fromListScreen ? 1 : 0,
      child: GestureDetector(
        onPanEnd: controller.handleSchemeTableSwipe,
        child: ListView.separated(
          shrinkWrap: true,
          controller: fromListScreen ? controller.scrollController : null,
          itemCount: controller.schemes.length,
          physics: !fromListScreen ? NeverScrollableScrollPhysics() : null,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(color: ColorConstants.borderColor);
          },
          itemBuilder: (BuildContext context, int index) {
            SchemeMetaModel scheme = controller.schemes[index];
            double? returnByYear = controller.getReturnValue(scheme.returns);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "fund_click",
                    screen: 'mutual_fund_store',
                    screenLocation: controller.screener?.name?.toSnakeCase(),
                    properties: {
                      "fund_name": scheme.displayName,
                    },
                  );

                  AutoRouter.of(context).push(
                    FundDetailRoute(
                      fund: scheme,
                      isTopUpPortfolio: false,
                      fromCustomPortfolios: controller.isCustomPortfoliosScreen,
                      basketBottomBar: BasketBottomBar(
                        fromCustomPortfolios:
                            controller.isCustomPortfoliosScreen,
                        controller: Get.find<BasketController>(),
                        fund: scheme,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Displays Amc Logo, Scheme Name, Scheme Rating and Expense Ratio
                        _buildAmcLogoNameRating(context, scheme),

                        SizedBox(width: 10),

                        // Displays return along with add basket button
                        _buildReturnColumn(context, scheme, returnByYear)
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (showMfRating)
                            CommonMfUI.buildMfRating(context, scheme),
                          Spacer(),
                          // _buildExpenseRatioText(context, scheme.expenseRatio),
                          // Spacer(),
                          CommonMfUI.buildAddBasketButton(context, scheme,
                              onTap: () {
                            MixPanelAnalytics.trackWithAgentId("fund_added",
                                screen: 'mutual_fund_store',
                                screenLocation:
                                    controller.screener?.name?.toSnakeCase(),
                                properties: {"fund_name": scheme.displayName});
                          })
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmcLogoNameRating(BuildContext context, SchemeMetaModel scheme) {
    return Expanded(
      child: Row(
        children: [
          _buildAmcLogo(scheme),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.displayName ?? '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAmcLogo(SchemeMetaModel scheme) {
    return GetBuilder<BasketController>(
      init: Get.find<BasketController>(),
      id: 'basket',
      global: true,
      builder: (controller) {
        bool isFundAddedInBasket =
            controller.basket.containsKey(scheme.basketKey);

        if (isFundAddedInBasket) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorConstants.lightGrey),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CommonUI.buildRoundedFullAMCLogo(
                  radius: 16,
                  amcName: scheme.displayName,
                  amcCode: scheme.amc,
                ),
              ),
              Positioned(
                right: 7,
                top: 0,
                child: Image.asset(
                  AllImages().cartAddedIcon,
                  width: 14,
                  height: 14,
                ),
              )
            ],
          );
        } else {
          return Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.lightGrey),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CommonUI.buildRoundedFullAMCLogo(
              radius: 16,
              amcName: scheme.displayName,
              amcCode: scheme.amc,
            ),
          );
        }
      },
    );
  }

  Widget _buildReturnColumn(
      BuildContext context, SchemeMetaModel scheme, double? returnByYear) {
    return Container(
      constraints: BoxConstraints(minWidth: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            returnByYear != null ? getReturnPercentageText(returnByYear) : '-',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
