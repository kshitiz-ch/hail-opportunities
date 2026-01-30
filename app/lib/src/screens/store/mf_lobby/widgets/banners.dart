import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_lobby_controller.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Banners extends StatelessWidget {
  const Banners({
    Key? key,
    this.client,
  }) : super(key: key);

  final Client? client;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 20, right: 20),
      child: GetBuilder<MfLobbyController>(
        id: 'curated-funds',
        builder: (controller) {
          if (controller.fetchCuratedFundScreenerState ==
              NetworkState.loading) {
            return Row(
              children: [
                Expanded(
                  child: SkeltonLoaderCard(height: 80),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeltonLoaderCard(height: 80),
                ),
              ],
            );
          }

          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              if (controller.curatedFundScreeners.isNotEmpty)
                _buildBanner(
                  context,
                  text: controller.curatedFundScreeners.first.name ?? '-',
                  image: AllImages().topPerformerFunds,
                  bgColor: ColorConstants.manilaTint,
                  onTap: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "top_performers",
                      screen: 'mutual_fund_store',
                      screenLocation: 'collections',
                    );
                    AutoRouter.of(context).push(
                      CuratedFundsRoute(
                        screener: controller.curatedFundScreeners.first,
                      ),
                    );
                  },
                ),
              _buildBanner(
                context,
                text: 'Curated Mutual\nFund Basket',
                image: AllImages().topPortfolios,
                bgColor: ColorConstants.daylightBlue,
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "curated_mf_basket",
                    screen: 'mutual_fund_store',
                    screenLocation: 'collections',
                  );
                  AutoRouter.of(context).push(
                    MfPortfolioListRoute(client: client),
                  );
                },
              ),
              _buildBanner(
                context,
                text: 'NFOs',
                image: AllImages().nfoBadge,
                bgColor: hexToColor("#FFE3FB"),
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "nfo",
                    screen: 'mutual_fund_store',
                    screenLocation: 'collections',
                  );

                  AutoRouter.of(context).push(
                    TopFundsNfoRoute(),
                  );
                },
              ),
              if (controller.curatedFundScreeners.length > 1)
                _buildBanner(
                  context,
                  text: controller.curatedFundScreeners[1].name ?? '-',
                  image: AllImages().fundIdeas,
                  bgColor: hexToColor("#FFE8DB"),
                  onTap: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "fund_ideas",
                      screen: 'mutual_fund_store',
                      screenLocation: 'collections',
                    );

                    AutoRouter.of(context).push(
                      CuratedFundsRoute(
                        screener: controller.curatedFundScreeners[1],
                        fromFundIdeasScreen: true,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required String text,
    required String image,
    required Color bgColor,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: ColorConstants.darkBlack.withOpacity(0.1),
              offset: Offset(0.0, 4.0),
              spreadRadius: 0.0,
              blurRadius: 12.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 34,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w500, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
    // return Expanded(
    //   child: InkWell(
    //     onTap: onTap,
    //     child: Container(
    //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         color: bgColor,
    //         boxShadow: [
    //           BoxShadow(
    //             color: ColorConstants.darkBlack.withOpacity(0.1),
    //             offset: Offset(0.0, 4.0),
    //             spreadRadius: 0.0,
    //             blurRadius: 12.0,
    //           ),
    //         ],
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Image.asset(
    //             image,
    //             height: 60,
    //           ),
    //           Padding(
    //             padding: EdgeInsets.only(top: 12, bottom: 12),
    //             child: Text(
    //               text,
    //               style: Theme.of(context)
    //                   .primaryTextTheme
    //                   .headlineSmall!
    //                   .copyWith(fontWeight: FontWeight.w500, height: 1.5),
    //             ),
    //           ),
    //           Container(
    //             padding: EdgeInsets.symmetric(
    //               horizontal: 12,
    //               vertical: 5,
    //             ),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(40),
    //             ),
    //             child: Text(
    //               'Explore',
    //               style: Theme.of(context)
    //                   .primaryTextTheme
    //                   .headlineMedium!
    //                   .copyWith(
    //                       fontSize: 13,
    //                       color: ColorConstants.primaryAppColor,
    //                       height: 1),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
