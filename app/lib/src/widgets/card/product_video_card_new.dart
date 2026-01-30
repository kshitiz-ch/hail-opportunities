import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/video_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class ProductVideoCard extends StatelessWidget {
  ProductVideoCard(
      {Key? key,
      this.video,
      this.productType,
      this.onTap,
      this.allowHorizontalPadding = true})
      : super(key: key);

  final AdvisorVideoModel? video;
  final Function? onTap;
  final String? productType;
  final bool allowHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: allowHorizontalPadding ? 20 : 0, vertical: 16),
      child: _buildVideoCard(context),
    );
  }

  Widget _buildVideoCard(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: AspectRatio(
        aspectRatio: 20 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                video!.thumbnail.isNotNullOrEmpty
                    ? video!.thumbnail!
                    : video!.link!.youtubeThumbnailUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.06),
                  ColorConstants.primaryAppColor.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(
                right: 20.0, left: 20, bottom: 12, top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Learn @ Wealthy',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      margin: EdgeInsets.only(right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                        ),
                      ),
                    ),
                    Text(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductVideoPlayer extends StatefulWidget {
  final YoutubePlayerController youtubePlayerController;
  final Widget player;
  final bool allowHorizontalPadding;

  const ProductVideoPlayer({
    Key? key,
    required this.advisorVideo,
    this.productType,
    this.updatePlayerState,
    required this.player,
    required this.youtubePlayerController,
    this.allowHorizontalPadding = true,
  }) : super(key: key);
  final AdvisorVideoModel? advisorVideo;
  final String? productType;
  final Function(PlayerState)? updatePlayerState;

  @override
  State<ProductVideoPlayer> createState() => ProductVideoPlayerState();
}

class ProductVideoPlayerState extends State<ProductVideoPlayer> {
  @override
  void initState() {
    widget.youtubePlayerController.loadVideo(widget.advisorVideo!.link!);
    youtubeControllerListener();
    super.initState();
  }

  void youtubeControllerListener() {
    widget.youtubePlayerController.listen((event) async {
      final hasNotPlayed = event.playerState == PlayerState.unStarted;

      if (hasNotPlayed) {
        await widget.youtubePlayerController.playVideo();
      }

      if (widget.updatePlayerState != null) {
        widget.updatePlayerState!(event.playerState);
      }
    });

    // widget.youtubePlayerController.setFullScreenListener((value) {
    //   if (value) {
    //     widget.youtubePlayerController.enterFullScreen();
    //   } else {
    //     widget.youtubePlayerController.exitFullScreen();
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.allowHorizontalPadding ? 20 : 0, vertical: 16),
      child: widget.player,
    );
  }
}
