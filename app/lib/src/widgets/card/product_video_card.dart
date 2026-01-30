import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/video_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class ProductVideoCard extends StatelessWidget {
  ProductVideoCard(
      {Key? key,
      this.video,
      this.title,
      this.productType,
      this.isProductVideoViewed = false,
      this.currentRoute,
      this.onTap})
      : super(key: key);

  final AdvisorVideoModel? video;
  final String? title;
  final String? productType;
  bool isProductVideoViewed;
  final String? currentRoute;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    isProductVideoViewed = true;
    return Container(
      padding: isProductVideoViewed
          ? EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: 16)
          : EdgeInsets.zero,
      child: Column(
        children: [
          if (title.isNotNullOrEmpty && isProductVideoViewed)
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                title!,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
          if (isProductVideoViewed)
            _buildVideoCard(context)
          else
            _buildAutoPlayVideoCard()
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
        AutoRouter.of(context).push(VideoRoute(videoUrl: video!.link));
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: AspectRatio(
          aspectRatio: 20 / 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      video!.thumbnail.isNotNullOrEmpty
                          ? video!.thumbnail!
                          : video!.link!.youtubeThumbnailUrl),
                  fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20.0, left: 20, bottom: 12, top: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          video!.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoPlayVideoCard() {
    return Container(
      child: _BuildPlayer(
          advisorVideo: video,
          productType: productType,
          currentRoute: currentRoute),
    );
  }
}

class _BuildPlayer extends StatefulWidget {
  const _BuildPlayer(
      {Key? key,
      required this.advisorVideo,
      this.productType,
      this.currentRoute})
      : super(key: key);

  final AdvisorVideoModel? advisorVideo;
  final String? productType;
  final String? currentRoute;

  @override
  State<_BuildPlayer> createState() => _PlayerState();
}

class _PlayerState extends State<_BuildPlayer> {
  YoutubePlayerController? _controller;
  // bool isVideoLoading = true;

  YoutubePlayerController getVideoPlayerController(videoId) {
    YoutubePlayerController _controller;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: true,
        showFullscreenButton: false,
        loop: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );

    _controller.listen((event) async {
      final hasNotPlayed = event.playerState == PlayerState.unStarted;

      if (hasNotPlayed) {
        await _controller.playVideo();
      }

      if (event.playerState == PlayerState.playing) {
        bool isRouteChanged = !isPageAtTopStack(context, widget.currentRoute);
        if (isRouteChanged) {
          await _controller.pauseVideo();
        }
      }
      final durationInMilliSeconds = (await _controller.currentTime) * 1000;
      if (!hasNotPlayed && durationInMilliSeconds == 0) {
        setProductVideoWatched(widget.productType);
      }
    });

    // _controller.setFullScreenListener((value) {
    //   if (value) {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.landscapeLeft,
    //       DeviceOrientation.landscapeRight,
    //     ]);
    //   } else {
    //     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //   }
    // });
    return _controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = getVideoPlayerController(
          YoutubePlayerController.convertUrlToId(widget.advisorVideo!.link!));
    }

    return YoutubePlayer(
      controller: _controller!,
    );
  }
}
