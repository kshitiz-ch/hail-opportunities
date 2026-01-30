import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/story_controller.dart';
import 'package:app/src/screens/home/widgets/notification_icon.dart';
import 'package:app/src/screens/home/widgets/story_icon.dart';
import 'package:app/src/screens/home/widgets/universal_search_container.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/festive_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader({Key? key, this.tag}) : super(key: key);

  final String? tag;

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    if (controller.authenticationBloc?.showFestiveAssets ?? false) {
      return Container(
        color: ColorConstants.secondaryAppColor,
        child: SafeArea(
          child: Container(
            color: ColorConstants.secondaryAppColor,
            height: 90,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                  height: 90,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              child: Image.asset(
                                AllImages().diwaliBg,
                                width: 140,
                                height: 140,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Positioned(
                              left: 35,
                              top: 20,
                              height: 50,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      MixPanelAnalytics.trackWithAgentId(
                                        "page_viewed",
                                        properties: {
                                          "source": "Home",
                                          "page_name": "Profile",
                                        },
                                      );
                                      AutoRouter.of(context).push(
                                        ProfileRoute(
                                          advisorOverview:
                                              controller.advisorOverviewModel,
                                        ),
                                      );
                                    },
                                    child: GetBuilder<HomeController>(
                                      id: 'profile-picture',
                                      builder: (controller) {
                                        final picUrl = controller
                                            .advisorOverviewModel
                                            ?.profilePictureUrl;
                                        final errorWidget = Image.asset(
                                          AllImages().profileIcon,
                                          width: 42,
                                          height: 42,
                                        );

                                        return InkWell(
                                          onTap: () {
                                            MixPanelAnalytics.trackWithAgentId(
                                              "page_viewed",
                                              properties: {
                                                "source": "Home",
                                                "page_name": "Profile",
                                              },
                                            );
                                            AutoRouter.of(context).push(
                                              ProfileRoute(
                                                advisorOverview: controller
                                                    .advisorOverviewModel,
                                                // advisorModel: advisorModel,
                                              ),
                                            );
                                          },
                                          child: controller
                                                      .getImageResponse.state ==
                                                  NetworkState.loading
                                              ? CommonUI.buildProfilePicLoader(
                                                  21)
                                              : CachedNetworkImage(
                                                  imageUrl: picUrl ?? '',
                                                  imageBuilder:
                                                      (context, imageProvider) {
                                                    return Container(
                                                      height: 42,
                                                      width: 42,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  placeholder: (_, __) =>
                                                      CommonUI
                                                          .buildProfilePicLoader(
                                                              21),
                                                  errorWidget: (_, __, ___) =>
                                                      errorWidget,
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  FestiveText(
                                    festiveText: 'Happy Diwali',
                                    festiveIcon: AllImages().diyaIcon,
                                    agent:
                                        controller.advisorOverviewModel?.agent,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 30, top: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GetBuilder<StoryListController>(
                              builder: (controller) {
                                return StoryIcon(controller: controller);
                              },
                            ),
                            SizedBox(width: 18),
                            NotificationIcon()
                          ],
                        ),
                      ),
                      UniversalSearchContainer(),
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   width: MediaQuery.of(context).size.width,
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 20),
                //     child: controller.showSearchShowCase
                //         ? ShowCaseSearchBar()
                //         : SearchBarContainer(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: ColorConstants.secondaryAppColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderIcons(context),
            UniversalSearchContainer(),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 20),
            //   child: controller.showSearchShowCase
            //       ? ShowCaseSearchBar()
            //       : SearchBarContainer(),
            // )
          ],
        ),
      );
    }
  }

  Widget _buildHeaderIcons(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: getSafeTopPadding(55, context), bottom: 25),
      padding: const EdgeInsets.only(left: 20, right: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildProfileIcon(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<StoryListController>(
                builder: (controller) {
                  return StoryIcon(controller: controller);
                },
              ),
              SizedBox(width: 18),
              NotificationIcon()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'profile-picture',
      builder: (controller) {
        final picUrl = controller.advisorOverviewModel?.profilePictureUrl ??
            controller.advisorOverviewModel?.agent?.imageUrl;
        final errorWidget = Image.asset(
          AllImages().profileIcon,
          width: 42,
          height: 42,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                MixPanelAnalytics.trackWithAgentId(
                  "page_viewed",
                  properties: {
                    "source": "Home",
                    "page_name": "Profile",
                  },
                );
                AutoRouter.of(context).push(
                  ProfileRoute(
                    advisorOverview: controller.advisorOverviewModel,
                    // advisorModel: advisorModel,
                  ),
                );
              },
              child: controller.getImageResponse.state == NetworkState.loading
                  ? CommonUI.buildProfilePicLoader(21)
                  : CachedNetworkImage(
                      imageUrl: picUrl ?? '',
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                      placeholder: (_, __) =>
                          CommonUI.buildProfilePicLoader(21),
                      errorWidget: (_, __, ___) => errorWidget,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: MarqueeWidget(
                  child: Text(
                    'Hello! ${controller.advisorOverviewModel?.agent?.displayName ?? 'Agent'}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShowCaseSearchBar extends StatefulWidget {
  const ShowCaseSearchBar({Key? key}) : super(key: key);

  @override
  _ShowCaseSearchBarState createState() => _ShowCaseSearchBarState();
}

class _ShowCaseSearchBarState extends State<ShowCaseSearchBar> {
  final GlobalKey _showcaseKey = GlobalKey();
  BuildContext? myContext;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(const Duration(milliseconds: 200), () {
        ShowCaseWidget.of(myContext!).startShowCase([_showcaseKey]);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    // return ShowCaseWidget(
    //   disableScaleAnimation: true,
    //   disableBarrierInteraction: false,
    //   onFinish: () async {
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setBool(SharedPreferencesKeys.showSearchShowCase, false);
    //   },
    //   builder: (context) {
    //     myContext = context;
    //     return Showcase(
    //       key: _showcaseKey,
    //       title: 'New Universal Search 👆',
    //       description: '',
    //       tooltipBackgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       titleAlignment: TextAlign.center,
    //       tooltipBorderRadius: BorderRadius.all(Radius.circular(12)),
    //       targetBorderRadius: BorderRadius.all(Radius.circular(12)),
    //       titleTextStyle: Theme.of(context)
    //           .primaryTextTheme
    //           .headlineSmall!
    //           .copyWith(color: ColorConstants.white),
    //       descTextStyle:
    //           TextStyle(fontSize: 12, color: Colors.white, height: 0),
    //       onToolTipClick: () async {
    //         AutoRouter.of(context).push(UniversalSearchRoute());
    //         SharedPreferences prefs = await SharedPreferences.getInstance();
    //         prefs.setBool(SharedPreferencesKeys.showSearchShowCase, false);
    //       },
    //       onTargetClick: () async {
    //         AutoRouter.of(context).push(UniversalSearchRoute());
    //         SharedPreferences prefs = await SharedPreferences.getInstance();
    //         prefs.setBool(SharedPreferencesKeys.showSearchShowCase, false);
    //       },
    //       disposeOnTap: true,
    //       child: SearchBarContainer(),
    //     );
    //   },
    // );
  }
}

class SearchBarContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "universal_search",
          properties: {"screen_location": "search", "screen": "Home"},
        );
        AutoRouter.of(context).push(UniversalSearchRoute());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.darkBlack.withOpacity(0.1),
              offset: Offset(0.0, 4.0),
              spreadRadius: 0.0,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: true,
          // child: Container(
          //   // padding: E,
          //   height: 56,
          //   decoration: BoxDecoration(
          //       color: Colors.white, borderRadius: BorderRadius.circular(12)),
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: SvgPicture.asset(
          //           AllImages().searchIcon,
          //           width: 24,
          //           height: 24,
          //         ),
          //         onPressed: null,
          //       ),
          //       Text(
          //         'Search for ',
          //         style: Theme.of(context)
          //             .primaryTextTheme
          //             .headlineSmall!
          //             .copyWith(
          //                 height: 1.4, color: ColorConstants.tertiaryBlack),
          //       ),
          //       SizedBox(width: 0.0, height: 100.0),
          //       DefaultTextStyle(
          //         style: Theme.of(context)
          //             .primaryTextTheme
          //             .headlineSmall!
          //             .copyWith(
          //                 height: 1.4, color: ColorConstants.tertiaryBlack),
          //         child: AnimatedTextKit(
          //           repeatForever: true,
          //           pause: Duration(milliseconds: 1000),
          //           animatedTexts: [
          //             RotateAnimatedText(
          //               '\"Mutual Funds\"',
          //               duration: Duration(milliseconds: 800),
          //             ),
          //             RotateAnimatedText(
          //               '\"Clients\"',
          //               duration: Duration(milliseconds: 800),
          //             ),
          //             RotateAnimatedText(
          //               '\"Reports\"',
          //               duration: Duration(milliseconds: 800),
          //             ),
          //             RotateAnimatedText(
          //               '\"Anything\"',
          //               duration: Duration(milliseconds: 800),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          child: SearchBox(
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
            labelStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      height: 1.4,
                      color: ColorConstants.tertiaryBlack,
                    ),
            height: 56,
            // textEditingController: storeSearchController!.searchController,
            fillColor: ColorConstants.white,
            labelText: 'Search for \"Anything\"',
            textColor: ColorConstants.secondaryBlack,
            customBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFFEEE7FF),
              ),
            ),
            prefixIcon: new IconButton(
              icon: SvgPicture.asset(
                AllImages().searchIcon,
                width: 24,
                height: 24,
              ),
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }
}
