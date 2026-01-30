import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/resources/widgets/app_resources_content_viewer.dart';
import 'package:app/src/screens/resources/widgets/app_resources_horizontal_list.dart';
import 'package:app/src/screens/resources/widgets/app_resources_image_actions.dart';
import 'package:app/src/screens/resources/widgets/app_resources_non_pdf_actions.dart';
import 'package:app/src/screens/resources/widgets/app_resources_pdf_actions.dart';
import 'package:app/src/screens/resources/widgets/app_resources_tags.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

/// A bottom sheet to display resources (Images/PDFs) with swipe support.
///
/// [index] - The initial index of the item to display from the list.
/// [source] - The source of the resources list (Marketing, Sales, RecentlyAdded, Single).
/// [creative] - Required for [AppResourcesSource.single] (deeplink) or as a fallback.
///
/// Usage Examples:
///
/// 1. Marketing Kit/Poster Gallery (Images):
/// ```dart
/// AppResourcesBottomsheet(
///   index: index,
///   source: AppResourcesSource.marketing,
/// )
/// ```
///
/// 2. Sales Kit (PDFs):
/// ```dart
/// AppResourcesBottomsheet(
///   index: index,
///   source: AppResourcesSource.sales,
/// )
/// ```
///
/// 3. Recently Added (Mixed):
/// ```dart
/// AppResourcesBottomsheet(
///   index: index,
///   source: AppResourcesSource.recentlyAdded,
/// )
/// ```
///
/// 4. Deeplink (Single Item):
/// ```dart
/// AppResourcesBottomsheet(
///   index: 0,
///   creative: model,
///   source: AppResourcesSource.single,
/// )
/// ```
class AppResourcesBottomsheet extends StatelessWidget {
  AppResourcesBottomsheet({
    Key? key,
    required this.index,
    this.creative,
    this.source,
    this.tag,
  }) : super(key: key);

  final int index;
  final CreativeNewModel? creative;
  final AppResourcesSource? source;
  final String? tag;

  final homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      tag: tag,
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final controller = Get.find<AppResourcesController>(tag: tag);
          if (source != null) {
            controller.setSource(source!, singleItem: creative);
          }
          controller.updateCurrentIndex(index);
        });
      },
      builder: (controller) {
        final targetList = controller.activeList;

        if (controller.getFiltersResponse.isLoading ||
            controller.apiResponse.isLoading) {
          return Container(
            height: 200,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.getFiltersResponse.isError ||
            controller.apiResponse.isError) {
          return Container(
            height: 200,
            color: Colors.white,
            child: Center(
              child: RetryWidget(
                controller.getFiltersResponse.isError
                    ? controller.getFiltersResponse.message
                    : controller.apiResponse.message,
                onPressed: () {
                  if (controller.getFiltersResponse.isError) {
                    controller.getCategoriesAndLanguages();
                  }

                  if (controller.apiResponse.isError) {
                    controller.getData();
                  }
                },
              ),
            ),
          );
        }

        if (targetList.isEmpty ||
            controller.currentIndex >= targetList.length) {
          return Container(
            height: 200,
            color: Colors.white,
            child: Center(
              child: Text('No creative available'),
            ),
          );
        }

        final currentResource = targetList[controller.currentIndex];
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: CommonUI.bottomsheetRoundedCloseIcon(
                  context,
                  onClose: () {
                    AutoRouter.of(context).popForced();
                  },
                ),
              ),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(15),
                  child: AppResourcesContentViewer(tag: tag),
                ),
              ),
              _buildInfo(currentResource, context),
              SizedBox(height: 16),
              AppResourcesHorizontalList(tag: tag),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 30),
                child: currentResource.isImage
                    ? AppResourcesImageActions(
                        currentResource: currentResource, tag: tag)
                    : currentResource.isPdf
                        ? AppResourcesPdfActions(
                            currentResource: currentResource, tag: tag)
                        : AppResourcesNonPdfActions(
                            currentResource: currentResource, tag: tag),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfo(CreativeNewModel currentResource, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentResource.title ?? currentResource.name ?? '',
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          AppResourcesTags(
            allTags: currentResource.allTags,
            isImage: currentResource.isImage,
          ),
          SizedBox(height: 8),
          currentResource.blur == true
              ? Text(
                  "These posters are available only to empaneled partners. Empanel with us to access 300+ posters in 9 languages.",
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                  ),
                )
              : ReadMoreText(
                  currentResource.description ?? '',
                  trimLines: 3,
                  colorClickableText: ColorConstants.primaryAppColor,
                  trimMode: TrimMode.Line,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                    inherit: true,
                  ),
                  moreStyle: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.primaryAppColor,
                    inherit: true,
                  ),
                  lessStyle: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.primaryAppColor,
                    inherit: true,
                  ),
                ),
        ],
      ),
    );
  }
}
