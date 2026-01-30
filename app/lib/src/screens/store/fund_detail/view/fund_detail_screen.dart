import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/chart_controller.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/basket_icon.dart';
import 'package:app/src/screens/store/fund_detail/widgets/edit_delete_action.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/fund_detail_screen_screenshot_service.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_overview_section.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_performance.dart';
import 'package:app/src/screens/store/fund_detail/widgets/scroll_down_arrow_lottie.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_section.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../widgets/fund_overview_tabs.dart';
import '../widgets/fund_score_details.dart';

@RoutePage()
class FundDetailScreen extends StatelessWidget {
  // Used for deeplinks
  final String? wschemecode;

  final SchemeMetaModel? fund;
  final bool isMicroSIP;

  /// Make this null to do not show the Add Button
  final Widget? basketBottomBar;

  /// Whether to show the Bottom Basket AppBar
  final bool showBottomBasketAppBar;

  final bool? isTopUpPortfolio;
  final bool? fromCustomPortfolios;
  final bool viaFundList;
  final String? tag;

  final bool fromSearch;

  // Constructor
  FundDetailScreen({
    Key? key,
    this.fund,
    this.isTopUpPortfolio = false,
    @pathParam this.wschemecode,
    this.basketBottomBar,
    this.viaFundList = false,
    this.fromCustomPortfolios = false,
    this.showBottomBasketAppBar = true,
    this.tag,
    this.fromSearch = false,
    this.isMicroSIP = false,
  }) : super(key: key) {
    MixPanelAnalytics.trackWithAgentId(
      "page_viewed",
      properties: {
        "source": "Mutual Fund",
        "scheme_name": fund?.schemeName ?? '',
        "display_name": fund?.displayName,
        "page_name": "Fund Detail"
      },
    );
  }

  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    bool fromProductList = isRouteNameInStack(
      context,
      FundListRoute.name,
    );

    return GetBuilder<FundDetailController>(
      init: FundDetailController(wschemecode, fund),
      dispose: (_) {
        Get.delete<ChartController>(tag: fund?.wschemecode ?? wschemecode);
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: controller.fetchSchemeDataState == NetworkState.loading ||
                  controller.fetchSchemeDataState == NetworkState.error
              ? CustomAppBar()
              : null,

          // Body
          body: Stack(
            children: [
              SafeArea(
                child: Container(
                  child: controller.fetchSchemeDataState == NetworkState.loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : controller.fetchSchemeDataState == NetworkState.error ||
                              controller.fund == null
                          ? Center(
                              child: Text('Failed to fetch Fund Details'),
                            )
                          // : _buildBody(context, controller),
                          : CustomScrollView(
                              controller: controller.scrollController,
                              slivers: <Widget>[
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      _buildFundTitleAndCategory(
                                        context,
                                        controller.fund!,
                                      ),
                                      if (showBottomBasketAppBar)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 10, left: 50),
                                          child: Row(
                                            children: [
                                              getAddedWidget(
                                                  context, controller.fund!),
                                              SizedBox(width: 10),
                                              EditDeleteAction(
                                                isMicroSIP: isMicroSIP,
                                                tag: tag,
                                                fund: fund,
                                              ),
                                            ],
                                          ),
                                        ),
                                      FundOverviewSection(
                                        fund: controller.fund,
                                        isTopUpPortfolio: isTopUpPortfolio,
                                      ),
                                    ],
                                  ),
                                ),
                                SliverAppBar(
                                  primary: false,
                                  automaticallyImplyLeading: false,
                                  // flexibleSpace: FundOverviewTabs(),
                                  // floating: false,
                                  backgroundColor: Colors.white,
                                  pinned: true,
                                  title: FundOverviewTabs(),
                                  toolbarHeight: 45,
                                  elevation: 0,
                                  titleSpacing: 0,
                                ),
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      VisibilityDetector(
                                        key: Key(
                                            FundNavigationTab.Overview.name),
                                        onVisibilityChanged: (visibilityInfo) {
                                          var visiblePercentage =
                                              visibilityInfo.visibleFraction *
                                                  100;
                                          bool isPortfolioNotExpanded =
                                              controller
                                                      .activeNavigationSection !=
                                                  FundNavigationTab.Portfolio;
                                          bool isPeersNotExpanded = controller
                                                  .activeNavigationSection !=
                                              FundNavigationTab.Peers;
                                          bool isSchemeDetailsNotExpanded =
                                              controller
                                                      .activeNavigationSection !=
                                                  FundNavigationTab
                                                      .Scheme_Details;

                                          if (isPortfolioNotExpanded &&
                                              isPeersNotExpanded &&
                                              isSchemeDetailsNotExpanded &&
                                              visiblePercentage >= 70) {
                                            controller.updateNavigationTab(
                                                FundNavigationTab.Overview,
                                                disableScrolling: true);
                                          }
                                        },
                                        child: new Container(
                                          key: controller.navigationKeys[
                                              FundNavigationTab.Overview.name],
                                          child: FundPerformance(
                                            fund: controller.fund!,
                                            scrollToTop: () {
                                              Scrollable.ensureVisible(
                                                controller
                                                    .navigationKeys[
                                                        FundNavigationTab
                                                            .Overview.name]!
                                                    .currentContext!,
                                                curve: Curves.easeInOut,
                                                duration:
                                                    Duration(milliseconds: 500),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      if (controller.fund != null)
                                        VisibilityDetector(
                                          key: Key('Fund-Score'),
                                          onVisibilityChanged:
                                              (VisibilityInfo visibilityInfo) {
                                            if (controller
                                                .showBottomArrowIndicator) {
                                              double visiblePercentage =
                                                  visibilityInfo
                                                          .visibleFraction *
                                                      100;

                                              if (visiblePercentage > 30) {
                                                controller
                                                    .hideBottomArrowIndicator();
                                              }
                                            }
                                          },
                                          child: FundScoreDetails(
                                            scheme: controller.fund!,
                                            navigationKeys:
                                                controller.navigationKeys,
                                            fundDetailController: controller,
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 20.0),
                                        child: Column(
                                          children: [
                                            CommonMfUI.buildDisclaimerText(
                                                context),
                                            SizedBox(height: 10),
                                            Text(
                                              'Investors are advised to consult their Legal /Tax advisors in regard to tax/legal implications relating to their investments in the scheme',
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      color: ColorConstants
                                                          .tertiaryBlack,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(height: 20),
                                            _buildSchemeDownloadButton(context)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: showBottomBasketAppBar ? 0 : 20,
                child: ScrollDownArrowLottie(),
              ),
            ],
          ),
          bottomNavigationBar: (showBottomBasketAppBar &&
                  basketBottomBar != null &&
                  controller.fetchSchemeDataState != NetworkState.loading &&
                  controller.fetchSchemeDataState != NetworkState.error)
              ? basketBottomBar!
              : SizedBox(),
        );
      },
    );
  }

  Widget _buildFundTitleAndCategory(
      BuildContext context, SchemeMetaModel fund) {
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: InkWell(
              onTap: () {
                AutoRouter.of(context).popForced();
              },
              child: Image.asset(
                AllImages().appBackIcon,
                height: 32,
                width: 32,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.displayName ?? '',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 30, top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: MarqueeWidget(
                            child: Text(
                              '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "- ${fund.fundCategory}" : ""}',
                              maxLines: 2,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' |  ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleSmall!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      if (fund != null) CommonMfUI.buildMfRating(context, fund!)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          if (isTopUpPortfolio != true)
            BasketIcon(
              fromCustomPortfolios: fromCustomPortfolios == true,
              isTopUpPortfolio: isTopUpPortfolio,
              clickedFromFundDetailScreen: true,
            ),
          InkWell(
            onTap: () {
              FundDetailScreenScreenshotService().captureScreenshot(context);
            },
            child: SizedBox(
              width: 30,
              height: 42,
              child: Center(
                child: Icon(
                  Icons.ios_share_outlined,
                  color: ColorConstants.primaryAppColor,
                  size: 24,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSchemeDownloadButton(BuildContext context) {
    return InkWell(
      onTap: () {
        launch("https://www.sebi.gov.in/filings/mutual-funds.html");
      },
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: ColorConstants.primaryAppColor,
          ),
          SizedBox(width: 5),
          Text(
            'Scheme Information Document',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget getAddedWidget(BuildContext context, SchemeMetaModel fund) {
    if (isMicroSIP) {
      return GetBuilder<MFPortfolioDetailController>(
        id: 'micro-sip',
        builder: (controller) {
          return controller.microSIPBasket.isNotEmpty &&
                  controller.microSIPBasket.containsKey(fund.basketKey)
              ? buildAddedWidget(context)
              : SizedBox();
        },
      );
    } else {
      return GetBuilder<BasketController>(
        id: 'basket',
        global: tag != null ? false : true,
        init: Get.find<BasketController>(tag: tag),
        builder: (controller) {
          return controller.basket.isNotEmpty &&
                  controller.basket.containsKey(fund.basketKey)
              ? buildAddedWidget(context)
              : SizedBox();
        },
      );
    }
  }
}
