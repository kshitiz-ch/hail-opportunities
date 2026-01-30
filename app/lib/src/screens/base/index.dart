import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/controllers/common/notification_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/story_controller.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/clients/client_list/view/client_list_screen.dart';
import 'package:app/src/screens/home/view/home_screen.dart';
import 'package:app/src/screens/proposals/proposal_list/view/proposal_list_screen.dart';
import 'package:app/src/screens/resources/view/resources_screen.dart';
import 'package:app/src/screens/store/store_home/view/store_screen.dart';
import 'package:app/src/utils/handle_deeplink.dart';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/common/navigation_controller.dart';
import 'widgets/bottom_nav.dart';

@RoutePage()
class BaseScreen extends StatefulWidget {
  BaseScreen({Key? key}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  StreamSubscription<Uri?>? _deepLinkSub;

  final CommonController commonController =
      Get.put(CommonController(), permanent: true);

  final NavigationController navController = Get.find<NavigationController>();

  final HomeController homeController =
      Get.put(HomeController(), permanent: true);

  final StoryListController storyListController =
      Get.put(StoryListController(), permanent: true);

  final ShowCaseController showCaseController =
      Get.put(ShowCaseController(), permanent: true);
  final BasketController basketController =
      Get.put(BasketController(), permanent: true);
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? backButtonPressedSince;

  final NotificationController notificationController =
      Get.put<NotificationController>(NotificationController(),
          permanent: true);

  final DownloadController downloadController =
      Get.put<DownloadController>(DownloadController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _deepLinks();
    if (navController.showAppUpdateDialog) {
      updateApp(context, doFlexibleUpdate: true).then((value) {
        navController.showAppUpdateDialog = false;
      });
    }
  }

  Future<bool?> getInitialUriHandled() async {
    final SharedPreferences sharedPreferences = await prefs;
    return sharedPreferences.getBool("isInitialUriHandled");
  }

  void setInitialUrlHandled(bool isInitialUriHandled) async {
    final SharedPreferences sharedPreferences = await prefs;
    await sharedPreferences.setBool("isInitialUriHandled", isInitialUriHandled);
  }

  Future<void> _deepLinks() async {
    // deep links
    try {
      final uri = await AppLinks().getInitialLink();
      bool? isInitialUriHandled = await getInitialUriHandled();
      if (uri != null && isInitialUriHandled != null && !isInitialUriHandled) {
        LogUtil.printLog('getInitialUri==>${uri.toString()}');

        setInitialUrlHandled(true);
        handleDeepLink(uri, context);
      }
      // cancel old sub
      await _deepLinkSub?.cancel();

      _deepLinkSub = AppLinks().uriLinkStream.listen((uri) async {
        LogUtil.printLog('listenlistenlistenlisten==>${uri.toString()}');
        bool isInitialUriHandled = (await getInitialUriHandled())!;
        if (!isInitialUriHandled) {
          setInitialUrlHandled(true);
        }
        handleDeepLink(uri, context);
      });
    } catch (e) {
      LogUtil.printLog("_deepLinks error");
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (navController.fromPushNotificationHandler) {
      navController.fromPushNotificationHandler = false;

      final widgetToNavigate = navController.pushNotificationHandler(
          navController.pushNotificationData,
          advisorOverview: homeController.advisorOverviewModel,
          context: context,
          viaLaunch: false);

      if (widgetToNavigate != null) {
        Future.delayed(Duration(seconds: 2), () {
          if (Get.isRegistered<ShowCaseController>()) {
            if (Get.find<ShowCaseController>().activeShowCaseId ==
                showCaseIds.HomeSearchBar.id) {
              Get.find<ShowCaseController>().setActiveShowCase();
            }
          }
          AutoRouter.of(context).push(widgetToNavigate);
        });
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, onClickBackButton);
      },
      child: Scaffold(
        body: _buildScreen(),
        bottomNavigationBar: BaseBottomNavigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0,
          child: Obx(
            () {
              return navController.currentScreen != Screens.STORE
                  ? FloatingActionButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      heroTag: kDefaultHeroTag,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundColor: ColorConstants.primaryAppColor,
                        radius: 28,
                        child: Image.asset(
                          AllImages().storeInactive,
                          height: 32,
                          width: 32,
                        ),
                      ),
                      onPressed: () {
                        navController.setCurrentScreen(
                          Screens.STORE,
                          fromScreen: "Home",
                        );
                      },
                    )
                  : SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Obx _buildScreen() {
    return Obx(() {
      switch (navController.currentScreen) {
        case Screens.PROPOSALS:
          return ProposalListScreen();
        case Screens.STORE:
          return StoreScreen();
        case Screens.CLIENTS:
          return ClientListScreen();
        case Screens.RESOURCES:
          return ResourcesScreen();
        default:
          return HomeScreen();
      }
    });
  }

  void onClickBackButton() {
    // If keyboard is open
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      return FocusManager.instance.primaryFocus?.unfocus();
    }

    // If current screen is dashboard
    if (navController.currentScreen == Screens.HOME) {
      backButtonPressedSince =
          minimiseApplication(backButtonPressedSince, context);
      return;
    }

    // if (navController.currentScreen == Screens.SEARCH) {
    //   final searchController = Get.isRegistered<UniversalSearchController>()
    //       ? Get.find<UniversalSearchController>()
    //       : null;
    //   if (searchController != null &&
    //       searchController.searchText.isNotNullOrEmpty) {
    //     searchController.clearSearchBar();
    //     return;
    //   }
    // }

    // If current is neither search nor dashboard
    navController.setCurrentScreen(Screens.HOME);
  }
}
