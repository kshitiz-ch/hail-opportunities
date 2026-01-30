import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class BaseBottomNavigationBar extends StatefulWidget {
  BaseBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<BaseBottomNavigationBar> createState() =>
      _BaseBottomNavigationBarState();
}

class _BaseBottomNavigationBarState extends State<BaseBottomNavigationBar> {
  final NavigationController controller = Get.find<NavigationController>();
  final ShowCaseController showCaseController = Get.find<ShowCaseController>();
  bool _showcaseTriggered = false;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (showcaseContext) {
        // Trigger showcase after the widget is built, using the showcaseContext
        if (!_showcaseTriggered) {
          _showcaseTriggered = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // showCaseController.startResourcesShowcase(showcaseContext);
          });
        }

        return Obx(
          () {
            return Stack(
              children: [
                BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  notchMargin:
                      controller.currentScreen == Screens.STORE ? 0 : 10.0,
                  color: ColorConstants.white,
                  surfaceTintColor: ColorConstants.white,
                  shadowColor: ColorConstants.darkBlack,
                  elevation: 10,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      currentIndex: controller.currentScreenIndex,
                      items: _buildNavigationItems(),
                      unselectedItemColor: ColorConstants.tertiaryBlack,
                      selectedItemColor: ColorConstants.primaryAppColor,
                      type: BottomNavigationBarType.fixed,
                      selectedLabelStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.primaryAppColor,
                          ),
                      unselectedLabelStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.tertiaryBlack,
                          ),
                      onTap: (index) {
                        final isResourcesScreen =
                            controller.currentScreen == Screens.RESOURCES;
                        MixPanelAnalytics.trackWithAgentId(
                          "page_viewed",
                          properties: {
                            "screen_location": "bottom_navigation_bar",
                            "page_name": isResourcesScreen
                                ? 'Poster Gallery'
                                : controller.currentScreen.name,
                            "source": "Bottom Nav",
                            if (isResourcesScreen) "module_name": "Resources",
                          },
                          screen: isResourcesScreen ? 'Resources' : '',
                        );
                        controller.setCurrentScreenByIndex(index);
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: ColorConstants.greenAccentColor.withOpacity(0.1),
                      border:
                          Border.all(color: ColorConstants.greenAccentColor),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'New',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 6,
                              color: ColorConstants.greenAccentColor),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  /// Builds the active icon for a tab
  Widget _buildActiveIcon(Screens tab) {
    if (tab.activeIcon.endsWith('svg')) {
      return SvgPicture.asset(
        tab.activeIcon,
        height: 32,
        width: 32,
        color: ColorConstants.primaryAppColor,
      );
    }
    return Image.asset(
      tab.activeIcon,
      height: 32,
      width: 32,
    );
  }

  /// Builds the inactive icon for a tab
  Widget _buildInactiveIcon(Screens tab) {
    // Store tab has no icon (uses FAB instead)
    if (tab == Screens.STORE) {
      return SizedBox(height: 32, width: 32);
    }

    // Resources tab has showcase wrapper
    if (tab == Screens.RESOURCES) {
      return Showcase(
        key: showCaseController.resourcesShowcaseKey,
        title: 'Resources made easy',
        description:
            'Posters, client decks, and brochures\nare now easy to find.',
        overlayOpacity: 0.65,
        targetShapeBorder: const CircleBorder(),
        targetPadding: const EdgeInsets.all(24),
        tooltipBackgroundColor: Colors.white,
        tooltipBorderRadius: BorderRadius.circular(32),
        tooltipPadding: const EdgeInsets.all(16),
        titleAlignment: Alignment.centerLeft,
        descriptionAlignment: Alignment.centerLeft,
        titleTextStyle: context.headlineMedium?.copyWith(
            color: Color(0xFF6C4CF1),
            fontSize: 18,
            fontWeight: FontWeight.w600),
        descTextStyle: context.headlineSmall
            ?.copyWith(color: Color(0xFF555555), height: 1.4),
        textColor: const Color(0xFF555555),
        disposeOnTap: true,
        onTargetClick: () {
          controller.setCurrentScreen(Screens.RESOURCES);
        },
        child: SvgPicture.asset(
          tab.icon,
          height: 32,
          width: 32,
          color: ColorConstants.borderColor,
        ),
      );
    }

    // Other tabs: SVG or PNG
    if (tab.activeIcon.endsWith('svg')) {
      return SvgPicture.asset(
        tab.icon,
        height: 32,
        width: 32,
        color: ColorConstants.borderColor,
      );
    }
    return Image.asset(
      tab.icon,
      height: 32,
      width: 32,
    );
  }

  /// Builds all bottom navigation bar items
  List<BottomNavigationBarItem> _buildNavigationItems() {
    return [
      for (final tab in Screens.values)
        BottomNavigationBarItem(
          label: tab.title,
          activeIcon: _buildActiveIcon(tab),
          icon: _buildInactiveIcon(tab),
        ),
    ];
  }
}
