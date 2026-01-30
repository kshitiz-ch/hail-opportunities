import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/card/pms_provider_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PMSProductSection extends StatelessWidget {
  final PMSProductController pmsProductController =
      Get.put<PMSProductController>(PMSProductController());

  @override
  Widget build(BuildContext context) {
    return (pmsProductController.getPMSProductDataState ==
                NetworkState.loaded &&
            (pmsProductController.pmsProductModel?.products?.isNullOrEmpty ??
                true))
        ? SizedBox()
        : Column(
            children: [
              SectionHeader(
                title: 'Popular PMS Providers',
                onTraiClick: () {
                  AutoRouter.of(context).push(PmsProviderListRoute());
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.toHeight, bottom: 30.toHeight),
                child: SizedBox(
                  height: 200,
                  child: GetBuilder<PMSProductController>(
                    id: GetxId.pmsProducts,
                    init: pmsProductController,
                    builder: (controller) {
                      return ListView.builder(
                        // in iOS default scroll behaviour is BouncingScrollPhysics
                        // in android its ClampingScrollPhysics Setting
                        //ClampingScrollPhysics explicitly for both
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 14.toWidth),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.getPMSProductDataState ==
                                NetworkState.error
                            ? 1
                            : controller.getPMSProductDataState ==
                                    NetworkState.loading
                                ? 3
                                : min(
                                    5,
                                    controller
                                        .pmsProductModel!.products!.length),
                        itemBuilder: (context, index) {
                          return Container(
                            width: controller.getPMSProductDataState ==
                                    NetworkState.error
                                ? SizeConfig().screenWidth! * 0.8
                                : 149.toWidth,
                            child: controller.getPMSProductDataState ==
                                    NetworkState.loading
                                ? PMSProviderCard.empty().toShimmer(
                                    baseColor:
                                        ColorConstants.lightBackgroundColor,
                                    highlightColor: ColorConstants.white,
                                  )
                                : controller.getPMSProductDataState ==
                                        NetworkState.error
                                    ? RetryWidget(
                                        controller
                                            .getPMSProductDataErrorMessage,
                                        onPressed: () =>
                                            controller.getPMSProductData(),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            right: 10.0.toWidth),
                                        child: PMSProviderCard(
                                          iconUrl: controller.pmsProductModel!
                                              .products![index].iconSvg,
                                          productCount: controller
                                              .pmsProductModel!
                                              .products![index]
                                              .variants!
                                              .length,
                                          title: controller
                                                  .pmsProductModel!
                                                  .products![index]
                                                  .productManufacturer ??
                                              notAvailableText,
                                          onPressed: () {
                                            AutoRouter.of(context).push(
                                              PmsProductListRoute(
                                                pmsProduct: controller
                                                    .pmsProductModel!
                                                    .products![index],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }
}
