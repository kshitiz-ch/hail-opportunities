import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/screens/resources/widgets/app_resources_bottomsheet.dart';
import 'package:app/src/screens/resources/widgets/recently_added_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentlyAddedCarousel extends StatefulWidget {
  @override
  _RecentlyAddedCarouselState createState() => _RecentlyAddedCarouselState();
}

class _RecentlyAddedCarouselState extends State<RecentlyAddedCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: SizeConfig().isTabletDevice ? 0.45 : 0.9,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 12),
          child: Text(
            'Recently Added',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GetBuilder<AppResourcesController>(
          builder: (controller) {
            if (controller.recentlyAddedResponse.isLoading) {
              return _buildLoader();
            }

            final validItems = <Map<String, dynamic>>[];
            if (controller.recentlyAddedResponse.isLoaded &&
                controller.recentlyAddedList.isNotNullOrEmpty) {
              for (int i = 0; i < controller.recentlyAddedList.length; i++) {
                final model = controller.recentlyAddedList[i];
                if (model != null && model.blur != true) {
                  validItems.add({'model': model, 'index': i});
                }
              }
            }

            // Don't show if there are no banners
            if (validItems.isEmpty) {
              return SizedBox();
            }

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: SizedBox(
                key: ValueKey(validItems.length),
                height: 160,
                // SizeConfig().screenHeight * (174 / 720),
                child: validItems.length == 1
                    ? _buildBanners(
                        context: context,
                        model: validItems[0]['model'],
                        index: validItems[0]['index'],
                        controller: controller,
                      )
                    : PageView.builder(
                        controller: _pageController,
                        padEnds: false,
                        itemBuilder: (context, pageIndex) {
                          final item =
                              validItems[pageIndex % validItems.length];
                          return _buildBanners(
                            context: context,
                            model: item['model'],
                            index: item['index'],
                            controller: controller,
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBanners({
    BuildContext? context,
    CreativeNewModel? model,
    required int index,
    required AppResourcesController controller,
  }) {
    if (model == null || model.blur == true) {
      return SizedBox();
    }

    return RecentlyAddedCard(
      model: model,
      isRecentlyAdded: true,
      onTap: () {
        // MixPanelAnalytics.trackWithAgentId(
        //   "resource_viewed",
        //   screen: 'resources',
        //   screenLocation: 'recently_added',
        //   properties: {"name": model.name},
        // );
        CommonUI.showBottomSheet(
          context!,
          child: AppResourcesBottomsheet(
            index: index,
            source: AppResourcesSource.recentlyAdded,
          ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 260,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: 160,
            decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        },
      ),
    );
  }
}
