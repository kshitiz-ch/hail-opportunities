import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/store_home/widgets/card_list.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopularPortfoliosSection extends StatelessWidget {
  const PopularPortfoliosSection({Key? key, required this.controller})
      : super(key: key);

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<MFProductModel> products =
        controller.popularProductsResult.mfModel.products;

    return Column(
      children: [
        SectionHeader(
          title: 'Wealthy Portfolios',
          subtitle: 'Mutual Fund Portfolios curated by Wealthy experts',
          onTraiClick: () {
            AutoRouter.of(context).push(
              MfPortfolioListRoute(client: controller.selectedClient),
            );
          },
        ),
        SizedBox(
          height: 16,
        ),
        CardList(
          height: 230,
          itemCount: controller.popularProductsState == NetworkState.error
              ? 1
              : controller.popularProductsState == NetworkState.loading
                  ? 2
                  : min(5, products.length),
          viewportFraction: 0.8,
          itemBuilder: (context, index) {
            GoalSubtypeModel? goalSubtype;

            if (controller.popularProductsState == NetworkState.loaded) {
              goalSubtype = products[index].goalSubtypes![0];
            }

            return Container(
              width: controller.popularProductsState == NetworkState.error
                  ? screenWidth * 0.9
                  : screenWidth * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 6.5),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: controller.popularProductsState == NetworkState.loading
                    ? ProductCard().toShimmer(
                        baseColor: ColorConstants.lightBackgroundColor,
                        highlightColor: ColorConstants.white,
                      )
                    : controller.popularProductsState == NetworkState.error
                        ? RetryWidget(
                            controller.popularProductsErrorMessage,
                            onPressed: () =>
                                controller.getPopularProducts(isRetry: true),
                          )
                        : ProductCardNew(
                            bgColor: ColorConstants.tertiaryAppColor,
                            leadingWidget: SvgPicture.network(
                              goalSubtype!.iconSvg!,
                              width: 22,
                              height: 22,
                            ),
                            title: goalSubtype.title,
                            description: goalSubtype.description,
                            onTap: () {
                              AutoRouter.of(context).push(
                                MfPortfolioDetailRoute(
                                  client: controller.selectedClient,
                                  portfolio: goalSubtype,
                                  isTopUpPortfolio: false,
                                  isSmartSwitch: goalSubtype!.isSmartSwitch,
                                ),
                              );
                            },
                            bottomData: [
                              BottomData(
                                title: getReturnPercentageText(
                                    goalSubtype.pastOneYearReturns),
                                subtitle: "Last 1 Year",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                              BottomData(
                                title: getReturnPercentageText(
                                    goalSubtype.pastThreeYearReturns),
                                subtitle: "Last 3 Years",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                              BottomData(
                                title: getReturnPercentageText(
                                    goalSubtype.pastFiveYearReturns),
                                subtitle: "Last 5 Years",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                              BottomData(
                                title: "${goalSubtype.term} years",
                                subtitle: "Horizon",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                              BottomData(
                                title:
                                    "${(goalSubtype.avgReturns! * 100).toStringAsFixed(2)}%",
                                subtitle: "Avg Returns",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                              BottomData(
                                title: WealthyAmount.currencyFormat(
                                  goalSubtype.minAmount,
                                  goalSubtype.minAmount! % 100 == 0 ? 0 : 1,
                                ),
                                subtitle: "Min Amount",
                                flex: 1,
                                align: BottomDataAlignment.left,
                              ),
                            ],
                          ),
              ),
            );
          },
        ),
      ],
    );
  }
}
