import 'dart:math' as math;
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:core/modules/store/models/store_search_results_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MfPortfolioResults extends StatelessWidget {
  const MfPortfolioResults({Key? key, required this.mfPortfolios})
      : super(key: key);
  final UniversalSearchDataModel mfPortfolios;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mfPortfolios.meta?.displayName ?? 'MF Portfolios',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: mfPortfolios.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = mfPortfolios.data![index];

              return InkWell(
                onTap: () {
                  final String tag = 'home_product_search';

                  AutoRouter.of(context).push(
                    ProductDetailsLoaderRoute(
                      productType: product.productType,
                      productVariant: product.productVariant,
                      category: product.category,
                      tag: tag,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          height: 32,
                          width: 32,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/store/portfolio_default_icon.png',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, right: 16),
                            child: Text(
                              product.portfolioName ?? '-',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              getReturnPercentageText(product.oneYearReturns),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '1 Year',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          ],
                        )
                      ],
                    ),
                    if (product.schemes?.isNotEmpty ?? false)
                      Container(
                        margin: EdgeInsets.only(left: 45),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: math.min(product.schemes!.length, 2),
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 5);
                          },
                          itemBuilder: (context, index) {
                            return Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // CommonUI.buildRoundedFullAMCLogo(
                                //   radius: 7,
                                //   amcName: product.schemes![index].name,
                                // ),
                                // SizedBox(width: 5),
                                Text(
                                  product.schemes![index].name,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: ColorConstants.tertiaryBlack
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    if ((product.schemes ?? []).length > 3)
                      Container(
                        padding: EdgeInsets.only(left: 45, top: 5),
                        child: Text(
                          '+ ${product.schemes!.length - 2} Funds',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack
                                    .withOpacity(0.6),
                              ),
                        ),
                      ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 45, top: 2),
                    //   child: Row(
                    //     // mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       CommonUI.buildRoundedFullAMCLogo(
                    //         radius: 8,
                    //         amcName: 'Mirae',
                    //       ),
                    //       SizedBox(width: 5),
                    //       Text(
                    //         'Mirae, Asset and ICICI fund',
                    //         style: Theme.of(context)
                    //             .primaryTextTheme
                    //             .titleLarge!
                    //             .copyWith(
                    //               color: ColorConstants.tertiaryBlack,
                    //             ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
