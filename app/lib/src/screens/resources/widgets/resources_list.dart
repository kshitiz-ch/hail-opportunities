import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/resources/widgets/app_resources_bottomsheet.dart';
import 'package:app/src/screens/resources/widgets/poster_card.dart';
import 'package:app/src/screens/resources/widgets/recently_added_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ResourcesList extends StatelessWidget {
  final Widget? header;

  const ResourcesList({
    Key? key,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      builder: (controller) {
        if (controller.getFiltersResponse.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final resourceList = controller.isMarketingKitSelected
            ? controller.creativesList
            : controller.resources;

        final isPaginating = controller.isMarketingKitSelected
            ? controller.isCreativesPaginating
            : controller.isResourcesPaginating;

        // Show loading only on initial load (not during pagination)
        if (controller.apiResponse.isLoading && !isPaginating) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show error only if not paginating
        if (controller.apiResponse.isError && !isPaginating) {
          return Center(
            child: RetryWidget(
              genericErrorMessage,
              onPressed: () {
                controller.getData();
              },
            ),
          );
        }

        if (resourceList.isNullOrEmpty) {
          return CustomScrollView(
            slivers: [
              if (header != null) SliverToBoxAdapter(child: header),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyScreen(
                    imagePath: AllImages().resourcesEmptyIcon,
                    message: 'No results match your filters.',
                    textStyle: context.headlineMedium?.copyWith(
                      color: Color(0xff666666),
                      fontWeight: FontWeight.w500,
                    ),
                    textPadding: const EdgeInsets.only(top: 12.0, bottom: 8),
                    customActionButton: ClickableText(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: ColorConstants.primaryAppColor,
                      text: 'Clear All filters',
                      onClick: () {
                        controller.clearFilterAndSort();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            // Check if we are at the bottom of the list
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
              if (!isTop) {
                controller.loadNextPage();
              }
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              if (header != null) SliverToBoxAdapter(child: header),
              if (controller.isMarketingKitSelected)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  sliver: SliverMasonryGrid(
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final resource = resourceList[index];
                        return PosterCard(
                          model: resource,
                          onTap: () {
                            // MixPanelAnalytics.trackWithAgentId(
                            //   "resource_viewed",
                            //   screen: 'resources',
                            //   screenLocation: 'resources',
                            //   properties: {"name": resource.name},
                            // );
                            CommonUI.showBottomSheet(
                              context,
                              child: AppResourcesBottomsheet(
                                index: index,
                                source: AppResourcesSource.marketing,
                              ),
                            );
                          },
                        );
                      },
                      childCount: resourceList.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Add separator logic if needed, but SliverList doesn't support separators directly like ListView.separated.
                        // We can add padding to the item or use a delegate that inserts separators.
                        // For simplicity, let's assume RecentlyAddedCard has its own padding or we wrap it.
                        // However, ListView.separated was used before with SizedBox(height: 8).
                        // Let's add bottom padding to the card wrapper.
                        if (index.isOdd) return SizedBox(height: 8);
                        final itemIndex = index ~/ 2;
                        final resource = resourceList[itemIndex];
                        return RecentlyAddedCard(
                          model: resource,
                          onTap: () {
                            // MixPanelAnalytics.trackWithAgentId(
                            //   "resource_viewed",
                            //   screen: 'resources',
                            //   screenLocation: 'resources',
                            //   properties: {"name": resource.name},
                            // );
                            CommonUI.showBottomSheet(
                              context,
                              child: AppResourcesBottomsheet(
                                index: itemIndex,
                                source: AppResourcesSource.sales,
                              ),
                            );
                          },
                        );
                      },
                      childCount: resourceList.length * 2 - 1,
                    ),
                  ),
                ),
              if (isPaginating)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        );
      },
    );
  }
}
