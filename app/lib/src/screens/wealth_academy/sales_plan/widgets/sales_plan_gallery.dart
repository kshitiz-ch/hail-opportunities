import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/creative_bottomsheet.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/creative_card.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesPlanGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isHomeScreen = isPageAtTopStack(context, SalesPlanRoute.name);

    return GetBuilder<SalesPlanController>(
      builder: (controller) {
        if (controller.creativesListState == NetworkState.loading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.creativesListState == NetworkState.error) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: RetryWidget(
                genericErrorMessage,
                onPressed: () {
                  controller.getCreatives();
                },
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((t) {
          if (!controller.isCheckedForNewCreatives) {
            controller.checkForNewCreatives();
          }
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30)
                  .copyWith(top: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Images (${controller.creatives.length})',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.black,
                        ),
                  ),
                  if (isHomeScreen)
                    ClickableText(
                      text: 'View all',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      onClick: () {
                        AutoRouter.of(context)
                            .push(SalesPlanGalleryListRoute());
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 24),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                crossAxisCount: 2,
                childAspectRatio: SizeConfig().isTabletDevice ? 1.4 : 150 / 220,
                children: List<Widget>.generate(
                  isHomeScreen
                      ? min(controller.creatives.length, 4)
                      : controller.creatives.length,
                  (index) => CreativeCard(
                    onTap: () {
                      controller.initPageController(index);
                      CommonUI.showBottomSheet(
                        context,
                        backgroundColor: Colors.transparent,
                        child: GetBuilder<SalesPlanController>(
                          id: GetxId.creativesCarousel,
                          builder: (controller) {
                            return CreativeBottomSheet(
                              creatives: controller.creatives,
                              pageController: controller.pageController,
                              moveToNextCarousel: () {
                                int creativesItemCount =
                                    controller.creatives.length;

                                if ((controller.currentCarouselIndex + 1) <
                                    creativesItemCount) {
                                  controller.moveToNextCarousel();
                                } else {
                                  controller.moveToNextCarousel(index: 0);
                                }
                              },
                              moveToPrevCarousel: () {
                                int creativesItemCount =
                                    controller.creatives.length;

                                if (controller.currentCarouselIndex != 0) {
                                  controller.moveToPreviousCarousel();
                                } else {
                                  controller.moveToPreviousCarousel(
                                    index: creativesItemCount - 1,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                    creativeModel: controller.creatives[index],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
