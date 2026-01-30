import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_list_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MFPortfoliosSection extends StatelessWidget {
  const MFPortfoliosSection({
    Key? key,
    required this.products,
    this.portfolioInvestmentData,
    this.client,
    this.showProductVideo = true,
    this.showTitle = true,
  }) : super(key: key);

  final List<MFProductModel>? products;
  final Client? client;
  final bool showProductVideo;
  final bool showTitle;
  final PortfolioInvestmentModel? portfolioInvestmentData;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GetBuilder<MfPortfoliosListController>(
      id: 'mutual-funds',
      initState: (_) async {
        MfPortfoliosListController controller =
            Get.find<MfPortfoliosListController>();

        // If [products] is null or empty, fetch data from API
        // else use [products] to render data
        if (products == null || products!.isEmpty) {
          controller.mutualFundsResult.products = List.filled(
            4,
            MFProductModel(),
          );
        } else {
          controller.mutualFundsResult.products = products;
          controller.mutualFundsState = NetworkState.loaded;
        }
      },
      builder: (controller) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 24),
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              // if (showProductVideo)
              // GetBuilder<MfPortfoliosListController>(
              //   id: 'product-video',
              //   builder: (controller) {
              //     if (controller.productVideoState == NetworkState.loaded &&
              //         controller.productVideo != null) {
              //       return ProductVideoCard(
              //         title:
              //             'Watch the video below to learn more about Wealthy Portfolios',
              //         video: controller.productVideo,
              //         productType: ProductVideosType.MF_PORTFOLIO,
              //         isProductVideoViewed: controller.isProductVideoViewed,
              //         currentRoute: MFPortfolioListRoute.name,
              //       );
              //     }
              //     return SizedBox();
              //   },
              // ),

              // ...controller.mutualFundsResult.products!.map((product) {
              if (controller.mutualFundsState == NetworkState.loading)
                ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 15);
                  },
                  itemBuilder: (context, index) {
                    return SkeltonLoaderCard(height: 150);
                  },
                )
              else if (controller.mutualFundsState == NetworkState.loading)
                RetryWidget(
                  '',
                  onPressed: () {
                    controller.getMututalFunds();
                  },
                )
              else
                ...controller.wealthyPortfolios.map((GoalSubtypeModel product) {
                  bool showSipTag = product.productVariant == "203";
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 5.0),
                    child: ProductCardNew(
                      onTap: () {
                        AutoRouter.of(context).push(MfPortfolioDetailRoute(
                          client: client,
                          portfolio: product,
                          isSmartSwitch: product.isSmartSwitch,
                        ));
                      },
                      bgColor: ColorConstants.tertiaryAppColor,
                      borderRadius: 16,
                      leadingWidget: Image.asset(
                        AllImages().portfolioDefaultIcon,
                        width: 36,
                      ),
                      title: product.title,
                      description: product.description,
                      descriptionMaxLines: 3,
                      bottomData: [
                        BottomData(
                          title: "${product.term} years",
                          subtitle: "Horizon",
                          flex: 1,
                          align: BottomDataAlignment.left,
                        ),
                        BottomData(
                          title: getReturnPercentageText(product.avgReturns),
                          subtitle: "Avg Returns",
                          flex: 1,
                          align: BottomDataAlignment.left,
                        ),
                        BottomData(
                          title: WealthyAmount.currencyFormat(
                            product.minAmount,
                            product.minAmount! % 100 == 0 ? 0 : 1,
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
                                margin: EdgeInsets.only(left: 15, bottom: 20),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  'Top Choice for SIP',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                  // List<GoalSubtypeModel>? goalSubtypes = product.goalSubtypes;

                  // return Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 10.0),
                  //       child: controller.mutualFundsState != NetworkState.loaded
                  //           ? SectionHeader(title: 'Loading...').toShimmer()
                  //           : SectionHeader(
                  //               title: product.name,
                  //               titleStyle: Theme.of(context)
                  //                   .primaryTextTheme
                  //                   .headlineMedium!
                  //                   .copyWith(
                  //                     fontWeight: FontWeight.w600,
                  //                     color: ColorConstants.tertiaryBlack,
                  //                   ),
                  //               leading: SvgPicture.network(
                  //                 product.iconSvg!,
                  //               ),
                  //               onTraiClick: () {
                  //                 AutoRouter.of(context).push(
                  //                   MFPortfolioSubtypeListRoute(
                  //                       client: client,
                  //                       title: product.name,
                  //                       portfolios: goalSubtypes),
                  //                 );
                  //               },
                  //             ),
                  //     ),

                  //     // Card List
                  //     Padding(
                  //       padding: const EdgeInsets.only(top: 16.0, bottom: 22.0),
                  //       child: CardList(
                  //         height: 230,
                  //         itemCount:
                  //             controller.mutualFundsState == NetworkState.error
                  //                 ? 1
                  //                 : controller.mutualFundsState ==
                  //                         NetworkState.loading
                  //                     ? 2
                  //                     : min(5, goalSubtypes!.length),
                  //         viewportFraction: 0.85,
                  //         itemBuilder: (context, index) {
                  //           return Container(
                  //             width: controller.mutualFundsState ==
                  //                     NetworkState.error
                  //                 ? screenWidth * 0.9
                  //                 : screenWidth * 0.85,
                  //             padding: const EdgeInsets.symmetric(
                  //               horizontal: 6.5,
                  //             ),
                  //             child: controller.mutualFundsState ==
                  //                     NetworkState.loading
                  //                 ? ProductCard().toShimmer(
                  //                     baseColor:
                  //                         ColorConstants.lightBackgroundColor,
                  //                     highlightColor: ColorConstants.white,
                  //                   )
                  //                 : controller.mutualFundsState ==
                  //                         NetworkState.error
                  //                     ? RetryWidget(
                  //                         controller.mutualFundsErrorMessage,
                  //                         onPressed: () =>
                  //                             controller.getMututalFunds(),
                  //                       )
                  //                     : ProductCardNew(
                  //                         bgColor:
                  //                             ColorConstants.primaryCardColor,
                  //                         // padding: EdgeInsets.fromLTRB(
                  //                         //   18.0,
                  //                         //   smartIndexProductVariants.contains(
                  //                         //           goalSubtypes[index]
                  //                         //               .productVariant)
                  //                         //       ? 32.0
                  //                         //       : 20.0,
                  //                         //   18.0,
                  //                         //   16.0,
                  //                         // ),
                  //                         title: goalSubtypes![index].title,
                  //                         description:
                  //                             goalSubtypes[index].description,
                  //                         onTap: () {
                  //                           bool isCustomPortfolio =
                  //                               goalSubtypes[index]
                  //                                       .productVariant ==
                  //                                   otherFundsGoalSubtype;
                  //                           if (isCustomPortfolio) {
                  //                             AutoRouter.of(context).push(
                  //                                 FundListRoute(
                  //                                     client: client,
                  //                                     portfolio:
                  //                                         goalSubtypes[index],
                  //                                     isCustomPortfolio: true));
                  //                           } else {
                  //                             AutoRouter.of(context)
                  //                                 .push(MFPortfolioDetailRoute(
                  //                               client: client,
                  //                               portfolio: goalSubtypes[index],
                  //                               isSmartSwitch: goalSubtypes[index]
                  //                                   .isSmartSwitch,
                  //                             ));
                  //                           }
                  //                         },
                  //                         bottomData: [
                  //                           BottomData(
                  //                             title: getReturnPercentageText(
                  //                                 goalSubtypes[index]
                  //                                     .pastOneYearReturns),
                  //                             subtitle: "Last 1 Year",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                           BottomData(
                  //                             title: getReturnPercentageText(
                  //                                 goalSubtypes[index]
                  //                                     .pastThreeYearReturns),
                  //                             subtitle: "Last 3 Years",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                           BottomData(
                  //                             title: getReturnPercentageText(
                  //                                 goalSubtypes[index]
                  //                                     .pastFiveYearReturns),
                  //                             subtitle: "Last 5 Years",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                           BottomData(
                  //                             title:
                  //                                 "${goalSubtypes[index].term} years",
                  //                             subtitle: "Horizon",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                           BottomData(
                  //                             title:
                  //                                 "${(goalSubtypes[index].avgReturns! * 100).toStringAsFixed(2)}%",
                  //                             subtitle: "Avg Returns",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                           BottomData(
                  //                             title: WealthyAmount.currencyFormat(
                  //                               goalSubtypes[index].minAmount,
                  //                               goalSubtypes[index].minAmount! %
                  //                                           100 ==
                  //                                       0
                  //                                   ? 0
                  //                                   : 1,
                  //                             ),
                  //                             subtitle: "Min Amount",
                  //                             flex: 1,
                  //                             align: BottomDataAlignment.left,
                  //                           ),
                  //                         ],
                  //                       ),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // );
                }).toList(),

              // Bottom Padding
              SizedBox(
                height: 22.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
