import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/insurance/insurance_home_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class InsuranceBannerCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceHomeController>(
      builder: (controller) {
        if (controller.isAgentFixed) {
          return SizedBox();
        }

        if (controller.insuranceBannerState == NetworkState.loading) {
          return buildInsuranceBannerShimmer();
        }
        if (controller.insuranceBannerState == NetworkState.error) {
          return Center(
            child: RetryWidget(
              controller.insuranceBannerErrorMessage ?? genericErrorMessage,
              onPressed: () {
                controller.getInsuranceBanner();
              },
            ),
          );
        }
        final bannerList = controller.insuranceBanners
            .where((banner) => banner.isCarousel!)
            .toList();

        if (bannerList.isNullOrEmpty) {
          return SizedBox();
        }
        final hasMultipleBanners =
            bannerList.isNotNullOrEmpty && bannerList.length > 1;
        final bannerSwiperCards = <Widget>[];
        bannerSwiperCards
          ..addAll(
            bannerList
                .map((banner) => _buildBanners(
                      context: context,
                      banner: banner,
                      hasMultipleBanners: hasMultipleBanners,
                    ))
                .toList(),
          );
        return Container(
          margin: hasMultipleBanners
              ? EdgeInsets.only(
                  right: SizeConfig().isTabletDevice ? 30 : 6,
                  top: 16,
                )
              : EdgeInsets.symmetric(
                  horizontal: SizeConfig().isTabletDevice
                      ? SizeConfig().screenWidth! * 0.1
                      : 16,
                ).copyWith(top: 24),
          height: SizeConfig().screenHeight * (180 / 720),
          child: Swiper.children(
            autoplay: !hasMultipleBanners ? false : true,
            viewportFraction: hasMultipleBanners ? 0.9 : 1,
            outer: false,
            loop: false,
            // Dot Indicator
            // pagination: SwiperPagination(
            //   margin: EdgeInsets.only(left: 4, right: 4, top: 8),
            //   builder: DotSwiperPaginationBuilder(
            //     size: 5,
            //     activeSize: 5,
            //     activeColor: bannerSwiperCards.length <= 1
            //         ? Colors.transparent
            //         : ColorConstants.primaryAppColor,
            //     color: bannerSwiperCards.length <= 1
            //         ? Colors.transparent
            //         : ColorConstants.primaryAppColor.withOpacity(0.16),
            //   ),
            // ),
            children: bannerSwiperCards,
          ),
        );
      },
    );
  }

  Widget _buildBanners({
    BuildContext? context,
    required BannerModel banner,
    bool? hasMultipleBanners,
  }) {
    return InkWell(
      onTap: () {
        if (banner.actionUrl.isNotNullOrEmpty) {
          if (banner.isDeepLink!) {
            try {
              AutoRouter.of(context!).pushNamed(banner.actionUrl!);
            } catch (error) {
              LogUtil.printLog('error==>${error.toString()}');
              launch(banner.actionUrl!);
            }
          } else {
            launch(banner.actionUrl!);
          }
        }
      },
      child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: banner.image!,
            fit: BoxFit.fill,
          )),
    );
    //
  }
}

Widget buildInsuranceBannerShimmer() {
  return Container(
    margin: EdgeInsets.symmetric(
      horizontal:
          SizeConfig().isTabletDevice ? SizeConfig().screenWidth! * 0.1 : 20,
    ).copyWith(top: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    height: SizeConfig().screenHeight * (180 / 720),
    width: double.infinity,
  ).toShimmer(
    baseColor: ColorConstants.lightBackgroundColor,
    highlightColor: ColorConstants.white,
  );
}
