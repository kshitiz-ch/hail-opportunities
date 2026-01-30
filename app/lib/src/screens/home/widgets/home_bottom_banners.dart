import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class HomeBottomBanners extends StatelessWidget {
  const HomeBottomBanners({Key? key, required bool this.showSgbBanner})
      : super(key: key);

  final bool showSgbBanner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              'Explore Demat Account',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                        height: 19 / 16,
                      ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: SizeConfig().screenHeight * (174 / 720),
            child: Swiper.children(
              autoplay: !showSgbBanner ? false : true,
              viewportFraction: 0.9,
              loop: false,
              outer: true,
              // Dot Indicator
              pagination: showSgbBanner
                  ? SwiperPagination(
                      margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                      builder: DotSwiperPaginationBuilder(
                        size: 6,
                        activeSize: 6,
                        activeColor: ColorConstants.primaryAppColor,
                        color: ColorConstants.primaryAppColor.withOpacity(0.16),
                      ),
                    )
                  : null,
              children: [
                if (showSgbBanner)
                  _buildBanner(
                    context,
                    image: AllImages().sgbBanner,
                    onClick: () {
                      AutoRouter.of(context).push(SgbRoute());
                    },
                  ),
                _buildBanner(
                  context,
                  image: AllImages().dematHomeBanner,
                  onClick: () {
                    AutoRouter.of(context).push(DematStoreRoute());
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required String image,
    void Function()? onClick,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: showSgbBanner ? 20 : 0),
      child: InkWell(
        onTap: onClick,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
