import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class FDBannerSection extends StatelessWidget {
  Widget _buildBanner(String imagePath, bool hasMultipleBanners) {
    return Padding(
      padding: hasMultipleBanners
          ? EdgeInsets.only(right: SizeConfig().isTabletDevice ? 30 : 6)
          : EdgeInsets.symmetric(
              horizontal: SizeConfig().isTabletDevice
                  ? SizeConfig().screenWidth! * 0.1
                  : 20,
            ),
      child: AspectRatio(
        aspectRatio: 4,
        child: imagePath.endsWith('.svg')
            ? SvgPicture.network(
                imagePath,
                fit: BoxFit.fill,
              )
            : CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.fill,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        if (controller.fetchFDBannerState == NetworkState.loading) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        }
        if (controller.fetchFDBannerState == NetworkState.error) {
          return SizedBox();
        }
        if (controller.fetchFDBannerState == NetworkState.loaded) {
          List<String?> imageList;
          if (controller.fdBannerList.isNotNullOrEmpty) {
            imageList =
                controller.fdBannerList!.map<String?>((e) => e.image).toList();
          } else {
            imageList = [];
          }
          final hasMultipleBanners = imageList.length > 1;
          final bannerSwiperCards = imageList
              .map<Widget>(
                ((e) => _buildBanner(e!, hasMultipleBanners)),
              )
              .toList();
          return bannerSwiperCards.isNullOrEmpty
              ? SizedBox()
              : SizedBox(
                  height: 90,
                  child: Swiper.children(
                    autoplay: !hasMultipleBanners ? false : true,
                    viewportFraction: hasMultipleBanners ? 0.9 : 1,
                    outer: false,
                    loop: false,
                    children: bannerSwiperCards,
                  ),
                );
        }
        return SizedBox();
      },
    );
  }
}
