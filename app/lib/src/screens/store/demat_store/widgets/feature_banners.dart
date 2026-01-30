import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class FeatureBanners extends StatelessWidget {
  const FeatureBanners({Key? key, required this.controller}) : super(key: key);

  final double viewportFraction = 0.8;
  final double paginationDotsHeight = 40;
  final DematProposalController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.carouselBanners.isEmpty) {
      return SizedBox();
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    // As per the design
    double bannerContainerRatio = 210 / 260;

    double bannerContainerWidth = screenWidth * viewportFraction;
    double bannerContainerHeight = bannerContainerWidth / bannerContainerRatio;

    final bannersList = controller.carouselBanners.map((BannerModel banner) {
      return _buildBanner(context, banner.image!);
    }).toList();

    return Container(
      color: ColorConstants.secondaryAppColor,
      padding: EdgeInsets.only(top: 36, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: bannerContainerHeight + paginationDotsHeight,
            child: Swiper.children(
              autoplay: false,
              viewportFraction: viewportFraction,
              loop: false,
              outer: true,
              // Dot Indicator
              pagination: SwiperPagination(
                margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                builder: DotSwiperPaginationBuilder(
                  size: 6,
                  activeSize: 6,
                  activeColor: ColorConstants.primaryAppColor,
                  color: ColorConstants.primaryAppColor.withOpacity(0.16),
                ),
              ),
              children: bannersList,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String image) {
    return Container(
      margin: EdgeInsets.only(right: SizeConfig().isTabletDevice ? 30 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              String? shareText =
                  getDematShareText(controller.dematDetails?.referralUrl);

              await shareImage(
                context: context,
                creativeUrl: image,
                text: shareText,
              );
            },
            child: Container(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share,
                    color: ColorConstants.primaryAppColor,
                    size: 22,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Share',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(
                            fontWeight: FontWeight.w700,
                            color: ColorConstants.primaryAppColor),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
