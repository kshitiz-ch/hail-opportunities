import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/screens/wealth_academy/widgets/video_card.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabBarViewSection extends StatefulWidget {
  @override
  State<TabBarViewSection> createState() => _TabBarViewSectionState();
}

class _TabBarViewSectionState extends State<TabBarViewSection>
    with TickerProviderStateMixin {
  SalesPlanController salesPlanController = Get.find<SalesPlanController>();

  @override
  void initState() {
    super.initState();
    salesPlanController.tabController = TabController(length: 2, vsync: this);
    salesPlanController.resourceTabPageController =
        PageController(viewportFraction: 0.8);
    salesPlanController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: min(SizeConfig().screenHeight / 2.2, 400),
      child: GetBuilder<SalesPlanController>(
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabs(context),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: [
                    _buildVideosTabBarView(controller),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return GetBuilder<SalesPlanController>(
      builder: (controller) {
        return Container(
          height: 45,
          color: Colors.white,
          margin: EdgeInsets.zero,
          child: TabBar(
            dividerHeight: 0,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            controller: controller.tabController,
            isScrollable: false,
            indicatorWeight: 1,
            indicatorColor: ColorConstants.primaryAppColor,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              _buildTabItem(
                'Videos ',
                controller.videos.length,
                AllImages().videoIcon,
                controller.tabController!.index == 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
      String text, int count, String imagePath, bool isActive) {
    return Container(
      width: SizeConfig().screenWidth! / 2,
      alignment: Alignment.center,
      child: Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 14,
              width: 14,
              fit: BoxFit.fill,
              color: isActive
                  ? ColorConstants.black
                  : ColorConstants.tertiaryBlack,
              // color: ,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '$text $count',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTabBarView(SalesPlanController controller) {
    return ListView.separated(
      padding: EdgeInsets.all(20),
      itemBuilder: (context, index) {
        final isCurrentVideo =
            controller.videos[controller.currentVideoIndex].id ==
                controller.videos[index].id;
        return VideoCard(
          isVideoEnded: controller.isVideoEnded,
          advisorVideo: controller.videos[index],
          isCurrentVideo: isCurrentVideo,
          isVideoPlaying: controller.isVideoPlaying,
          onPressed: () {
            if (isCurrentVideo) {
              if (controller.isVideoEnded) {
                controller.refreshCurrentVideo();
              } else {
                controller.togglePlay();
              }
            } else {
              controller.updateCurrentPlayingVideo(index);
            }
          },
        );
      },
      separatorBuilder: (_, index) => SizedBox(height: 10),
      itemCount: controller.videos.length,
    );
  }
}
