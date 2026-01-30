import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/screens/resources/view/resources_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AppResourcesHorizontalList extends StatelessWidget {
  final String? tag;
  AppResourcesHorizontalList({this.tag});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      tag: tag,
      builder: (controller) {
        final currentResourceList = controller.activeList;

        bool isWhiteLabelLoading = controller.whiteLabelResponse.isLoading;
        bool isCreativesLoading = controller.apiResponse.isLoading;

        if (currentResourceList.length < 2) {
          return SizedBox();
        }

        return Container(
          height: 110,
          child: Row(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.horizontal,
                  itemScrollController:
                      controller.creativesHorizScrollController,
                  itemPositionsListener:
                      controller.creativesHorizPositionsListener,
                  itemCount: currentResourceList.length,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  initialScrollIndex: controller.currentIndex,
                  itemBuilder: (context, index) {
                    final resource = currentResourceList[index];

                    String resourceUrl = resource.url ?? "";

                    if (!resourceUrl.startsWith("http")) {
                      resourceUrl = "https://$resourceUrl?width=120&height=160";
                    }

                    final isResourceSelected = controller.currentIndex == index;

                    return Container(
                      padding: EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          if (isWhiteLabelLoading) return;
                          controller.updateCurrentIndex(index);
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: _buildIcon(resource),
                            ),
                            if (isWhiteLabelLoading ||
                                isResourceSelected ||
                                isCreativesLoading)
                              Container(
                                height: 80,
                                width: 60,
                                decoration: BoxDecoration(
                                  color:
                                      isWhiteLabelLoading || isCreativesLoading
                                          ? Colors.black.withOpacity(0.8)
                                          : Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: isResourceSelected
                                    ? Center(
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 24,
                                        ),
                                      )
                                    : null,
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (isCreativesLoading)
                Container(
                  height: 80,
                  width: 60,
                  margin: EdgeInsets.only(right: 10),
                  child: Center(
                    child: Container(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(CreativeNewModel model) {
    if (model.blur == true) {
      return Image.asset(
        AllImages().blurPoster,
        fit: BoxFit.contain,
        height: 80,
        width: 60,
      );
    }

    return CachedNetworkImage(
      imageUrl: model.isImage
          ? 'https://${model.url}?width=120&height=140'
          : 'https://${model.thumbnailUrl}?width=120&height=140',
      fit: BoxFit.cover,
      height: 80,
      width: 60,
      errorWidget: (context, error, stackTrace) {
        if (model.isImage) {
          return Container(
            color: Color(0xFFF0F0F0),
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey,
            ),
          );
        }
        final fileMetaData = getFileMetaData('https://${model.url!}');
        return SizedBox(
          height: 80,
          width: 60,
          child: Image.asset(fileMetaData['fileIcon']!),
        );
      },
      placeholder: (context, url) {
        return Container(
          color: Color(0xFFF0F0F0),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}
