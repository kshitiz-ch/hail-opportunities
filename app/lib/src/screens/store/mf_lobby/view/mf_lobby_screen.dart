import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_lobby_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_search_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/basket_icon.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/lazy_indexed_stack.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/banners.dart';
import '../widgets/popular_portfolios_section.dart';
import '../widgets/search_bar_section.dart';
import '../widgets/search_result.dart';
import '../widgets/wealthy_select_section.dart';

@RoutePage()
class MfLobbyScreen extends StatelessWidget {
  const MfLobbyScreen({
    Key? key,
    this.client,
  }) : super(key: key);

  final Client? client;
  final searchControllerTag = 'mf-lobby';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          if (Get.isRegistered<MfSearchController>(tag: searchControllerTag)) {
            MfSearchController mfSearchController =
                Get.find<MfSearchController>(tag: searchControllerTag);

            if (mfSearchController.showSearchView) {
              mfSearchController.hideSearchView();
              return;
            } else {
              AutoRouter.of(context).popForced();
            }
          } else {
            AutoRouter.of(context).popForced();
          }
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(
          titleText: 'Mutual Funds',
          trailingWidgets: [
            _buildCartIcon(context),
          ],
        ),
        body: SafeArea(
          child: GetBuilder<MfLobbyController>(
            init: MfLobbyController(selectedClient: client),
            initState: (_) {
              Get.put(MfSearchController(), tag: searchControllerTag);
            },
            dispose: (_) {
              Get.delete<MfSearchController>(tag: searchControllerTag);
            },
            builder: (controller) {
              return Container(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarSection(tag: searchControllerTag),
                    ),
                    Expanded(
                      child: GetBuilder<MfSearchController>(
                        tag: searchControllerTag,
                        builder: (searchController) {
                          return LazyIndexedStack(
                            sizing: StackFit.loose,
                            index: searchController.showSearchView ? 1 : 0,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Banners(client: client),
                                    _buildScreeners(context, controller),
                                    _buildPopularPortfolios(),
                                    _buildCustomPortfolioCard(context),
                                    _buildDisclaimerAndBackgroundImage(context)
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: SearchResult(tag: searchControllerTag),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: CommonMfUI.buildMfLobbyBottomNavigationBar(),
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return BasketIcon(
      onTap: () {
        AutoRouter.of(context).push(
          BasketOverViewRoute(),
        );
      },
    );
  }

  Widget _buildScreeners(BuildContext context, MfLobbyController controller) {
    if (controller.screenerResponse.state == NetworkState.loading) {
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.screenerResponse.state == NetworkState.error) {
      return RetryWidget(
        controller.screenerResponse.message,
        onPressed: () {
          controller.getWealthySelectScreeners();
        },
      );
    }

    if (controller.screenerResponse.state == NetworkState.loaded &&
        (controller.screenerList?.screeners ?? []).isNotNullOrEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.screenerList!.screeners!.length,
        itemBuilder: (BuildContext context, int index) {
          ScreenerModel screener = controller.screenerList!.screeners![index];
          return WealthySelectSection(screener: screener);
        },
      );
    }

    return SizedBox();
  }

  Widget _buildCustomPortfolioCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Looking for more funds?',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineLarge!
                .copyWith(fontSize: 16),
          ),

          // Portfolio Card
          // ==============
          Container(
            margin: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              color: hexToColor("#F0E9FC"),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  AllImages().customPortfolioIcon,
                  width: 120,
                ),
                SizedBox(height: 12),
                Text(
                  'Create Custom Portfolios',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
                ActionButton(
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    // Data from store product API
                    GoalSubtypeModel portfolio = GoalSubtypeModel(
                      category: Category.INVEST,
                      categoryText: CategoryText.INVESTMENT,
                      description: "Steady return with low fluctuation",
                      expiryTime: 240,
                      externalId:
                          "PGNsYXNzICdkamFuZ28uZGIubW9kZWxzLmJhc2UuTW9kZWxCYXNlJz46MTk=",
                      goalType: 9,
                      minAddAmount: 1000.0,
                      minAmount: 1000.0,
                      productType: "MF",
                      productVariant: "20000",
                      title: "Other Funds",
                    );

                    MixPanelAnalytics.trackWithAgentId(
                      "custom_portfolio",
                      screen: 'mutual_fund_store',
                      screenLocation: "curated_mf_basket",
                    );

                    AutoRouter.of(context).push(
                      MfListRoute(isCustomPortfoliosScreen: true),
                    );
                  },
                  text: 'Add Funds',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPortfolios() {
    return GetBuilder<MfLobbyController>(
      id: 'curated-portfolios',
      builder: (controller) {
        return PopularPortfoliosSection(controller: controller);
      },
    );
  }

  Widget _buildDisclaimerAndBackgroundImage(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30, bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonMfUI.buildDisclaimerText(context),
          SizedBox(height: 50),
          Image.asset(AllImages().mfLobbyBackground)
        ],
      ),
    );
  }
}
