import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_lobby_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_search_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/widgets/loader/search_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({
    Key? key,
    required this.tag,
    this.fromListScreen = false,
    this.isCustomPortfolioScreen = false,
  }) : super(key: key);

  final String tag;
  final bool fromListScreen;
  final bool isCustomPortfolioScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackToListButton(context),
        // These categories are already present in equity listing
        if (!fromListScreen) _buildEquityCategories(context),
        SizedBox(height: 20),
        Text(
          'Search Results',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
        Expanded(
          child: GetBuilder<MfSearchController>(
            tag: tag,
            builder: (controller) {
              if (controller.searchState == NetworkState.loading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.searchState == NetworkState.loaded &&
                  controller.fundsResult.isEmpty) {
                return EmptyScreen(message: 'No Fund Found');
              }

              if (controller.searchText.isEmpty) {
                return SearchLoader(
                  text: 'Search for your favourite funds',
                );
              }

              if (controller.searchState == NetworkState.loaded &&
                  controller.fundsResult.isNotEmpty) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.fundsResult.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: ColorConstants.borderColor,
                    );
                  },
                  itemBuilder: (context, index) {
                    SchemeMetaModel scheme = controller.fundsResult[index];
                    return _buildFundTile(context, scheme);
                  },
                );
              }

              return SizedBox();
            },
          ),
        )
      ],
    );
  }

  Widget _buildBackToListButton(BuildContext context) {
    return GetBuilder<MfSearchController>(
      tag: tag,
      builder: (controller) {
        return Container(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              controller.hideSearchView();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      Icons.arrow_right_alt,
                      color: ColorConstants.primaryAppColor,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Back to Listing',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            color: ColorConstants.primaryAppColor, height: 1),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFundTile(BuildContext context, SchemeMetaModel scheme) {
    if (scheme.displayName == null) return SizedBox();
    return InkWell(
      onTap: () {
        Widget basketBottomBar = BasketBottomBar(
            controller: Get.find<BasketController>(),
            fund: scheme,
            fromCustomPortfolios: isCustomPortfolioScreen);

        if (scheme.isNfoFund) {
          AutoRouter.of(context).push(
            NfoDetailRoute(wschemecode: scheme.wschemecode),
          );
        } else {
          AutoRouter.of(context).push(
            FundDetailRoute(
              fund: scheme,
              isTopUpPortfolio: false,
              basketBottomBar: basketBottomBar,
              fromCustomPortfolios: isCustomPortfolioScreen,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 16, 10, 12),
        child: Row(
          children: [
            CommonUI.buildRoundedFullAMCLogo(
              radius: 18,
              amcName: scheme.displayName,
              amcCode: scheme.amc,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                scheme.displayName!,
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEquityCategories(BuildContext context) {
    return GetBuilder<MfLobbyController>(
      builder: (controller) {
        ScreenerModel? equityScreener =
            (controller.screenerList?.screeners.isNotNullOrEmpty ?? false)
                ? controller.screenerList?.screeners![0]
                : null;
        List<Choice> categories = equityScreener?.categoryParams?.choices ?? [];
        if (equityScreener != null && categories.isNotEmpty) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...categories
                      .mapIndexed(
                        (Choice category, index) => _buldCategoryPill(
                            context, category, equityScreener, index),
                      )
                      .toList()
                ],
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget _buldCategoryPill(
      BuildContext context, Choice choice, ScreenerModel screener, int index) {
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "pill_click",
          screen: 'search_screen',
          screenLocation: 'mutual_fund_store',
          properties: {
            "category": choice.value,
          },
        );

        if (AutoRouter.of(context).currentPath == AppRouteName.mfListScreen) {
          AutoRouter.of(context).popAndPush(
            MfListRoute(
              screener: screener,
              categorySelected: [choice],
              categorySelectedIndex: index,
            ),
          );
        } else {
          AutoRouter.of(context).push(
            MfListRoute(
              screener: screener,
              categorySelected: [choice],
              categorySelectedIndex: index,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: ColorConstants.secondarySeparatorColor,
          ),
        ),
        child: Text(
          choice.displayName!,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
      ),
    );
  }
}
