import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/screens/resources/widgets/app_resources_bottomsheet.dart';
import 'package:app/src/screens/resources/widgets/category_chips_row.dart';
import 'package:app/src/screens/resources/widgets/language_selector.dart';
import 'package:app/src/screens/resources/widgets/recently_added_carousel.dart';
import 'package:app/src/screens/resources/widgets/resources_list.dart';
import 'package:app/src/screens/resources/widgets/resources_tabs.dart';
import 'package:app/src/screens/resources/widgets/sliver_header_delegate.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ResourcesScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool? showDailyCreative;
  final String daily;
  final TagModel? defaultCategory;
  final TagModel? defaultLanguage;
  final CreativeNewModel? creative;

  ResourcesScreen({
    this.initialTabIndex = 0,
    this.showDailyCreative,
    @queryParam this.daily = '',
    this.defaultCategory,
    this.defaultLanguage,
    this.creative,
  });

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  late bool? showDailyCreative;

  @override
  void initState() {
    super.initState();
    showDailyCreative = widget.showDailyCreative;
    if (widget.daily == "true") {
      showDailyCreative = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.creative != null) {
        CommonUI.showBottomSheet(
          context,
          child: AppResourcesBottomsheet(
            index: 0,
            creative: widget.creative,
            source: AppResourcesSource.single,
          ),
        );
      } else if (showDailyCreative == true) {
        // Reset the flag so it doesn't show again if we come back to this screen in a way that doesn't rebuild
        showDailyCreative = false;
        CommonUI.showBottomSheet(
          context,
          child: AppResourcesBottomsheet(
            index: 0,
            source: AppResourcesSource.marketing,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      init: AppResourcesController(
        initialTabIndex: widget.initialTabIndex,
        defaultCategory: widget.defaultCategory,
        defaultLanguage: widget.defaultLanguage,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: isPageAtTopStack(context, ResourcesRoute.name),
            titleText: 'Resources',
            trailingWidgets: [
              LanguageSelector(
                selectedLanguage: controller.languageSelected,
                availableLanguages: controller.activeLanguages,
                onLanguageChanged: (TagModel language) {
                  controller.languageSelected = language;
                  controller.getRecentlyAdded();
                  controller.getData();
                },
              )
            ],
          ),
          // Use NestedScrollView to allow the app bar to float and tabs to pin
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              final showCarousel = controller.recentlyAddedResponse.isLoading ||
                  controller.recentlyAddedList.isNotNullOrEmpty;

              return <Widget>[
                // Recently Added Carousel as a floating SliverAppBar
                // This will scroll out of view when scrolling down and appear when scrolling up
                if (showCarousel)
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    snap: false,
                    expandedHeight:
                        230, // Increased to 240 to accommodate loader height (200 + ~30 text)
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RecentlyAddedCarousel(),
                        ],
                      ),
                    ),
                    backgroundColor: ColorConstants.white,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    toolbarHeight:
                        0, // Hide standard toolbar to use expanded height
                  ),

                // Tabs pinned to the top below the app bar (or status bar when scrolled)
                SliverPersistentHeader(
                  delegate: SliverHeaderDelegate(
                    child: ResourcesTabs(),
                    maxHeight: 54,
                    minHeight: 54,
                  ),
                  pinned: true,
                ),
              ];
            },
            // The body of the NestedScrollView (the list)
            body: ResourcesList(
              header: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
                child: _buildTabCTA(context, controller),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: controller.getFiltersResponse.isLoaded
                ? Padding(
                    key: ValueKey('category_chips'),
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(bottom: 30),
                    child: CategoryChipsRow(),
                  )
                : SizedBox.shrink(key: ValueKey('empty')),
          ),
        );
      },
    );
  }

  Widget _buildTabCTA(
    BuildContext context,
    AppResourcesController controller,
  ) {
    final isEmpanelmentDone = controller.homeController.isKycDone &&
        controller.homeController.isEmpanelmentCompleted;

    if (controller.isMarketingKitSelected && !isEmpanelmentDone) {
      return buildPostersEmpanelmentSection(
        context,
        pageName: 'Posters Gallery',
      );
    }

    if (!controller.isMarketingKitSelected &&
        controller.languageSelected?.tag != salesKitAllTag.tag) {
      return Row(
        children: [
          Text(
            'Also available in other languages . ',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4),
          ClickableText(
            text: 'View all',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            suffixIcon: Icon(
              Icons.arrow_forward_outlined,
              size: 16,
              color: ColorConstants.primaryAppColor,
            ),
            onClick: () {
              controller.languageSelected = salesKitAllTag;
              controller.getRecentlyAdded();
              controller.getData();
            },
          )
        ],
      );
    }

    return SizedBox();
  }
}

Map<String, String> getFileMetaData(String url) {
  String fileType = 'Document';
  String fileIcon = AllImages().genericDocumentIcon;
  if (url.isPDFFileName) {
    fileType = 'PDF File';
    fileIcon = AllImages().pdfFileIcon;
  } else if (url.isExcelFileName) {
    fileType = 'Excel File';
    fileIcon = AllImages().excelFileIcon;
  } else if (url.toLowerCase().endsWith('.csv')) {
    fileType = 'CSV File';
    fileIcon = AllImages().csvFileIcon;
  }
  return {
    'fileType': fileType,
    'fileIcon': fileIcon,
  };
}

Widget buildPostersEmpanelmentSection(
  BuildContext context, {
  CreativeNewModel? creative,
  String? pageName,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
    decoration: BoxDecoration(
      color: ColorConstants.secondaryAppColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Unlock 300+ posters in 9 languages with your own branding.',
          textAlign: TextAlign.center,
          style: context.headlineMedium?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        ActionButton(
          text: 'Empanel Now',
          margin: EdgeInsets.zero,
          onPressed: () {
            // if (!homeController.isKycDone) {
            //   AutoRouter.of(context).push(
            //     CompleteKycRoute(fromScreen: 'creatives'),
            //   );
            // } else if (homeController.isEmpanelmentPending) {
            //   AutoRouter.of(context).push(
            //     EmpanelmentRoute(
            //         advisorOverview: homeController.advisorOverviewModel),
            //   );
            // }
            AutoRouter.of(context).push(ProfileUpdateRoute());
            EventTracker.trackResourcesCTAClicked(
              ctaName: 'Empanel Now',
              resource: creative,
              pageName: pageName,
            );
          },
        )
      ],
    ),
  );
}
