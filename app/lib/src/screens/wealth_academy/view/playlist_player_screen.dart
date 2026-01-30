import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/playlist_controller.dart';
import 'package:app/src/screens/wealth_academy/widgets/video_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

@RoutePage()
class PlaylistPlayerScreen extends StatefulWidget {
  PlaylistPlayerScreen({
    Key? key,
    this.videos,
    this.videoIndex,
    this.initialVideo,
    @pathParam this.playlistId,
  }) : super(key: key);

  final List<AdvisorVideoModel>? videos;
  final int? videoIndex;
  final AdvisorVideoModel? initialVideo;
  final String? playlistId;

  @override
  State<PlaylistPlayerScreen> createState() => _PlaylistPlayerScreenState();
}

class _PlaylistPlayerScreenState extends State<PlaylistPlayerScreen> {
  late PlaylistPlayerController playlistController;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PlaylistPlayerController>()) {
      playlistController = Get.find<PlaylistPlayerController>();
    } else {
      playlistController = Get.put(PlaylistPlayerController());
    }

    if (widget.videos.isNullOrEmpty) {
      if (widget.initialVideo != null) {
        playlistController.playVideo(widget.initialVideo!);
      }
      if (widget.playlistId.isNotNullOrEmpty) {
        playlistController.getPlaylist(
            playlistId: widget.playlistId!,
            initalVideoUrl: widget.initialVideo?.link);
      }
    } else {
      if (widget.videoIndex != null) {
        playlistController.playVideo(widget.videos![widget.videoIndex!]);
      } else {
        playlistController.playVideo(widget.videos!.first);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _controller = YoutubePlayerController.fromVideoId(
      videoId: 'G9s455ZHf3M',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
        showControls: false,
      ),
    );
    return YoutubePlayerScaffold(
      controller: playlistController.youtubePlayerController,
      builder: (context, player) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              Get.delete<PlaylistPlayerController>();
              AutoRouter.of(context).popForced();
            });
          },
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: CustomAppBar(
              showBackButton: true,
              titleText: 'Wealth Academy',
              onBackPress: () {
                Get.delete<PlaylistPlayerController>();
                AutoRouter.of(context).popForced();
              },
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //* VIDEO view
                  GetBuilder<PlaylistPlayerController>(
                    builder: (controller) {
                      if (controller.playlistState == NetworkState.loading) {
                        return Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ProductCardNew(
                            bgColor: ColorConstants.white,
                          ).toShimmer(
                            baseColor: ColorConstants.lightBackgroundColor,
                            highlightColor: ColorConstants.white,
                          ),
                        );
                      }

                      if (controller.currentVideo != null) {
                        return player;
                      }

                      return Container(
                        height: 150,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Text('No Video Found'),
                        ),
                      );
                    },
                  ),

                  //* show available videos list
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: BuildPlaylist(videos: widget.videos),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BuildPlaylist extends StatelessWidget {
  const BuildPlaylist({
    Key? key,
    this.videos,
  }) : super(key: key);

  final List<AdvisorVideoModel>? videos;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistPlayerController>(
      builder: (controller) {
        if (controller.playlistState == NetworkState.loading) {
          return Center(child: CircularProgressIndicator());
        }

        List<AdvisorVideoModel>? playlistVideos = [];

        if (controller.currentVideo == null) {
          return SizedBox();
        }

        if (videos.isNotNullOrEmpty) {
          playlistVideos = videos;
        } else if (controller.playlistState == NetworkState.loaded &&
            controller.playlist != null &&
            controller.playlist!.videos.isNotNullOrEmpty) {
          playlistVideos = controller.playlist!.videos;
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          shrinkWrap: true,
          itemCount: playlistVideos!.length + 1,
          itemBuilder: (_, index) {
            //? shows available videos count header
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0)
                        .copyWith(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.currentVideo!.title ?? ''}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                  color: ColorConstants.black,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4),
                        ),
                        if (controller
                            .currentVideo!.description.isNotNullOrEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ReadMoreText(
                              '${controller.currentVideo!.description}',
                              trimCollapsedText: 'Read More',
                              trimExpandedText: 'Show Less',
                              trimMode: TrimMode.Line,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontSize: 12,
                                      color: ColorConstants.tertiaryBlack,
                                      height: 1.4),
                              moreStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 12,
                                    color: ColorConstants.primaryAppColor,
                                  ),
                              lessStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 12,
                                    color: ColorConstants.primaryAppColor,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  if (playlistVideos.isNotNullOrEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '${playlistVideos!.length} video(s)',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              );
            }

            //? get current Video by Index
            final video = playlistVideos![index - 1];
            return VideoCard(
              advisorVideo: video,
              isCurrentVideo: controller.currentVideo?.title == video.title,
              isVideoPlaying: controller.isVideoPlaying,
              onPressed: () {
                //? notify playlistController for selected video.
                //? required to play video.
                controller.playVideo(video);
              },
            );
          },
          separatorBuilder: (_, index) => SizedBox(height: 16),
        );
      },
    );
  }
}
