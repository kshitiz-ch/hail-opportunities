import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/tab_bar_view_section.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

@RoutePage()
class SalesPlanPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesPlanController>(
      builder: (controller) {
        if (controller.currentVideoPlayerController == null) {
          controller.initialiseVideoPlayerController(
            YoutubePlayerController.convertUrlToId(
                controller.videos[controller.currentVideoIndex].link!)!,
          );
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              if (controller.isFullScreenEnabled) {
                controller.toggleFullscreen();
                return;
              }
              controller.updateCurrentPlayingVideo(0);
              AutoRouter.of(context).popForced();
            });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: (controller.isFullScreenEnabled
                ? PreferredSize(
                    preferredSize: Size.zero,
                    child: SizedBox.shrink(),
                  )
                : CustomAppBar(
                    showBackButton: true,
                    onBackPress: () {
                      AutoRouter.of(context).popForced();
                      controller.updateCurrentPlayingVideo(0);
                      controller.resetPlayerConfiguration();
                    },
                    // title:
                    //     'Sales Guide (${controller.currentVideoIndex + 1}/${controller.videos.length})',
                  )) as PreferredSizeWidget?,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildPlayer(controller, context),
                    ),
                    if (!controller.isFullScreenEnabled) TabBarViewSection(),

                    // Extra space taken by player control
                    SizedBox(height: 64)
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: _buildPlayerControls(controller, context),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayer(SalesPlanController controller, BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          child: YoutubePlayerControllerProvider(
            key: Key(controller.videos[controller.currentVideoIndex].id ?? ''),
            controller: controller.currentVideoPlayerController!,
            child: Stack(
              children: [
                // fixed overflow issue for fraction of milliseconds while changing orientation
                LayoutBuilder(builder: (context, constraint) {
                  double aspectRatio =
                      constraint.maxWidth / constraint.maxHeight;
                  if (aspectRatio.isNaN || aspectRatio.isInfinite) {
                    aspectRatio = 16 / 9;
                  }
                  return SizedBox(
                    // height: constraint.maxHeight,
                    width: constraint.maxWidth,
                    child: YoutubePlayerScaffold(
                      controller: controller.currentVideoPlayerController!,
                      aspectRatio: aspectRatio,
                      builder: (context, player) {
                        return player;
                      },
                    ),
                  );
                }),
                Positioned.fill(
                  child: Center(
                    child:
                        // controller.isVideoLoading
                        //     ? CircularProgressIndicator(
                        //         color: ColorConstants.white,
                        //       )
                        //     :
                        SizedBox(
                      height: 50,
                      width: 50,
                      child: InkWell(
                        onTap: () {
                          if (controller.isVideoEnded) {
                            controller.refreshCurrentVideo();
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(
      SalesPlanController controller, BuildContext context) {
    return StreamBuilder<Duration>(
      stream: controller.checkCurrentPlayingStream(),
      builder: (context, snapshot) {
        final currentVideoDuration = (controller.currentVideoPlayerController
                ?.metadata.duration.inMilliseconds ??
            0);
        int currentPlayingPosition = (snapshot.data?.inMilliseconds ?? 0);
        if (currentVideoDuration <= 0) {
          return SizedBox();
        }

        if (currentPlayingPosition > currentVideoDuration) {
          // sometimes event.position duration is greater than video total duration
          // which throws assertion error
          currentPlayingPosition = currentVideoDuration;
        }
        return Container(
          height: 64,
          width: SizeConfig().screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            color: ColorConstants.black,
            borderRadius: !controller.isFullScreenEnabled
                ? BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (controller.isVideoEnded) {
                      controller.refreshCurrentVideo();
                    } else {
                      controller.togglePlay();
                    }
                  },
                  icon: Icon(
                    controller.isVideoEnded
                        ? Icons.refresh
                        : controller.isVideoPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                  ),
                  color: Colors.white,
                  iconSize: 32,
                ),
              ),
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    width: double.infinity,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                      ),
                      child: Slider(
                        activeColor:
                            ColorConstants.primaryAppColor.withOpacity(0.8),
                        inactiveColor:
                            ColorConstants.borderColor.withOpacity(0.5),
                        thumbColor: ColorConstants.secondaryAppColor,
                        value: currentPlayingPosition.toDouble(),
                        max: currentVideoDuration.toDouble(),
                        divisions: currentVideoDuration,
                        label: null,
                        onChanged: (double value) {
                          controller.changeVideoPosition(value.toInt());
                        },
                      ),
                    )),
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    controller.toggleFullscreen();
                  },
                  child: Image.asset(
                    controller.isFullScreenEnabled
                        ? AllImages().exitFullScreenIcon
                        : AllImages().enterFullScreenIcon,
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
