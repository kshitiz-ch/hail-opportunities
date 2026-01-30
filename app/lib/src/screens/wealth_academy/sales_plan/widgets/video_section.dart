import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/video_utils.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesPlanController>(
      builder: (controller) {
        if (controller.creativesListState == NetworkState.loading) {
          return _buildShimmerLoader();
        }
        if (controller.creativesListState == NetworkState.error) {
          return Center(
            child: RetryWidget(
              genericErrorMessage,
              onPressed: () {
                controller.getCreatives();
              },
            ),
          );
        }

        if (controller.creativesListState == NetworkState.loaded &&
            controller.videos.isNotNullOrEmpty) {
          final video = controller.videos.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0)
                    .copyWith(bottom: 20),
                child: Text(
                  'Here are some videos by 100+ Cr AUM experts to help you close sales faster',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.subtitleColor,
                      ),
                ),
              ),
              InkWell(
                onTap: () {
                  AutoRouter.of(context).push(SalesPlanPlayerRoute());
                },
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      height: 200,
                      width: SizeConfig().screenWidth,
                      fit: BoxFit.fill,
                      imageUrl:
                          video.thumbnail ?? video.link!.youtubeThumbnailUrl,
                      placeholder: (cxt, val) {
                        return _buildShimmerLoader();
                      },
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 235,
      width: SizeConfig().screenWidth,
      color: Colors.white,
    ).toShimmer(
      baseColor: ColorConstants.lightBackgroundColor,
      highlightColor: ColorConstants.white,
    );
  }
}
