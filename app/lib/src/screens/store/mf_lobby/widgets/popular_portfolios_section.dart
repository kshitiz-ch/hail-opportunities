import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_lobby_controller.dart';
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

class PopularPortfoliosSection extends StatelessWidget {
  const PopularPortfoliosSection({Key? key, required this.controller})
      : super(key: key);

  final MfLobbyController controller;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<GoalSubtypeModel> products = controller.mfPortfolios;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Curated Mutual Fund Basket',
            subtitle:
                'Mutual fund portfolios curated based on investment objectives',
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
            height: 200,
            itemCount: controller.fetchCuratedPortfolioState ==
                    NetworkState.error
                ? 1
                : controller.fetchCuratedPortfolioState == NetworkState.loading
                    ? 2
                    : min(4, products.length),
            viewportFraction: 0.9,
            itemBuilder: (context, index) {
              GoalSubtypeModel? goalSubtype;

              if (controller.fetchCuratedPortfolioState ==
                  NetworkState.loaded) {
                goalSubtype = products[index];
              }

              bool showSipTag = goalSubtype?.productVariant == "203";

              return Container(
                width:
                    controller.fetchCuratedPortfolioState == NetworkState.error
                        ? screenWidth * 0.9
                        : screenWidth * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 6.5),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: controller.fetchCuratedPortfolioState ==
                          NetworkState.loading
                      ? ProductCard().toShimmer(
                          baseColor: ColorConstants.lightBackgroundColor,
                          highlightColor: ColorConstants.white,
                        )
                      : controller.fetchCuratedPortfolioState ==
                              NetworkState.error
                          ? RetryWidget(
                              'Something went wrong. Please try again',
                              onPressed: () =>
                                  controller.getCuratedMfPortfolios(),
                            )
                          : ProductCardNew(
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
                              bgColor: ColorConstants.tertiaryAppColor,
                              borderRadius: 16,
                              leadingWidget: Image.asset(
                                AllImages().portfolioDefaultIcon,
                                width: 36,
                              ),
                              title: goalSubtype?.title,
                              description: goalSubtype?.description,
                              descriptionMaxLines: 3,
                              bottomData: [
                                BottomData(
                                  title: "${goalSubtype?.term} years",
                                  subtitle: "Horizon",
                                  flex: 1,
                                  align: BottomDataAlignment.left,
                                ),
                                BottomData(
                                  title: getReturnPercentageText(
                                      goalSubtype?.avgReturns),
                                  subtitle: "Avg Returns",
                                  flex: 1,
                                  align: BottomDataAlignment.left,
                                ),
                                BottomData(
                                  title: WealthyAmount.currencyFormat(
                                    goalSubtype?.minAmount,
                                    (goalSubtype?.minAmount ?? 0) % 100 == 0
                                        ? 0
                                        : 1,
                                  ),
                                  subtitle: "Min Amount",
                                  flex: 1,
                                  align: BottomDataAlignment.left,
                                ),
                              ],
                              additionalBottomData: showSipTag
                                  ? Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 15),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Text(
                                          'Top Choice for SIP',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
