import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/screens/wealth_academy/view/intro_sales_plan_screen.dart';
import 'package:app/src/screens/wealth_academy/widgets/events_section.dart';
import 'package:app/src/screens/wealth_academy/widgets/playlist_section.dart';
import 'package:app/src/screens/wealth_academy/widgets/sales_plan_reminder_bottomsheet.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class WealthAcademyScreen extends StatefulWidget {
  final String? videoUrl;
  final String? playlistId;
  final bool fromPushNotification;

  static const route = '/wealth-academy';

  WealthAcademyScreen({
    this.videoUrl,
    this.playlistId,
    this.fromPushNotification = false,
  });

  @override
  _WealthAcademyScreenState createState() => _WealthAcademyScreenState();
}

class _WealthAcademyScreenState extends State<WealthAcademyScreen>
    with TickerProviderStateMixin {
  final tabs = ['Playlists'];

  bool showBackButton = false;
  bool showSalesPlanCard = false;
  late TabController tabController;

  late SharedPreferences sharedPreferences;

  ScrollController openScrollController = ScrollController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // checkSalesPlanViewed();

    tabController = TabController(
      initialIndex: 0,
      length: tabs.length,
      vsync: this,
    );
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {});
      }
    });

    super.initState();
  }

  Future<void> checkSalesPlanViewed() async {
    String salesPlanId = await getSalesPlanId();
    // Exit if sales plan id is not present
    if (salesPlanId.isNullOrEmpty) {
      return;
    }

    sharedPreferences = await prefs;
    bool isSalesPlanIntroViewed = sharedPreferences
            .getBool(SharedPreferencesKeys.isSalesPlanIntroViewed) ??
        false;

    bool isSalesPlanScreenViewed = sharedPreferences
            .getBool(SharedPreferencesKeys.isSalesPlanScreenViewed) ??
        false;

    if (!isSalesPlanScreenViewed) {
      showSalesPlanCard = true;
      if (mounted) {
        setState(() {});
      }
    }

    if (!isSalesPlanIntroViewed) {
      WidgetsBinding.instance.addPostFrameCallback((t) async {
        sharedPreferences.setBool(
            SharedPreferencesKeys.isSalesPlanIntroViewed, true);

        AutoRouter.of(context).pushNativeRoute(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                IntroSalesPlanScreen(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Wealth Academy',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventsSection(),
          // if (true) _buildSalesPlanCard(),
          _buildTabs(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _buildTabBarView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPlanCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorConstants.secondaryCardColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Image.asset(AllImages().salesPlanMore, width: 64),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Custom Sales Guide',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: ColorConstants.lightGreenBackgroundColor,
                                border: Border.all(
                                    color: ColorConstants.greenAccentColor),
                                borderRadius: BorderRadius.circular(2)),
                            child: Text(
                              'New',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.greenAccentColor,
                                      height: 1),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Achieve 10x more sales!',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 90,
                        child: ActionButton(
                          height: 30,
                          margin: EdgeInsets.zero,
                          text: 'Explore now',
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge!
                              .copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                          onPressed: () {
                            AutoRouter.of(context).push(SalesPlanUnboxRoute());
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: InkWell(
              onTap: () {
                CommonUI.showBottomSheet(
                  context,
                  child: SalesPlanReminderBottomSheet(),
                ).then((value) {
                  setState(() {
                    Get.find<NavigationController>()
                        .enableShowSalesPlanOnMoreScreen();

                    sharedPreferences.setBool(
                        SharedPreferencesKeys.isSalesPlanScreenViewed, true);
                    showSalesPlanCard = false;
                  });
                });
              },
              child: Container(
                padding: EdgeInsets.only(left: 3, top: 3),
                child: Icon(
                  Icons.close,
                  color: ColorConstants.tertiaryBlack,
                  size: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return GetBuilder<EventsController>(
      initState: (_) {
        EventsController _controller = Get.isRegistered<EventsController>()
            ? Get.find<EventsController>()
            : Get.put(EventsController());

        _controller.getEventSchedules();
      },
      builder: (controller) {
        if (controller.eventSchedulesState == NetworkState.loading) {
          return _buildEventLoader();
        }

        if (controller.eventSchedulesState == NetworkState.loaded &&
            controller.eventSchedules.length > 0) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0)
                      .copyWith(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Events',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.tertiaryBlack),
                      ),
                      // ClickableText(
                      //   padding: const EdgeInsets.only(left: 10.0),
                      //   text: 'View All',
                      //   fontWeight: FontWeight.w500,
                      //   fontSize: 12,
                      //   onClick: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //           return EventsListScreen();
                      //         },
                      //       ),
                      //     );
                      //   },
                      // )
                    ],
                  ),
                ),
                EventsSection(
                  eventSchedules: controller.eventSchedules,
                )
              ],
            ),
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildEventLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.filled(3, 0)
                .map(
                  (e) => Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ProductCard().toShimmer(
                        baseColor: ColorConstants.lightBackgroundColor,
                        highlightColor: ColorConstants.white,
                      )),
                )
                .toList()
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Color(0xff9B9B9B),
            );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.tertiaryCardColor,
            ColorConstants.tertiaryCardColor.withOpacity(0),
          ],
        ),
      ),
      height: 60,
      child: TabBar(
        dividerHeight: 0,
        labelPadding: EdgeInsets.symmetric(horizontal: 30),
        indicatorPadding: EdgeInsets.zero,
        indicatorColor: ColorConstants.primaryAppColor,
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelStyle: textStyle,
        labelStyle: textStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: ColorConstants.black,
        ),
        tabs: List.generate(
          tabs.length,
          (index) {
            return Tab(
              child: MarqueeWidget(
                child: Text(
                  tabs[index],
                  maxLines: 1,
                ),
              ),
              iconMargin: EdgeInsets.zero,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildTabBarView() {
    return PlaylistSection();
  }
}
