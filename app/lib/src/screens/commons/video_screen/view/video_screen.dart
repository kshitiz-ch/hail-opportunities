import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

@RoutePage()
class VideoScreen extends StatelessWidget {
  VideoScreen({Key? key, this.videoUrl, @pathParam this.videoId})
      : super(key: key);

  String? videoUrl;
  String? videoId;

  @override
  Widget build(BuildContext context) {
    if (videoUrl.isNullOrEmpty && videoId.isNotNullOrEmpty) {
      videoUrl = "https://www.youtube.com/watch?v=$videoId";
    }

    AdvisorVideoModel advisorVideo =
        AdvisorVideoModel.fromJson({"link": videoUrl});
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: 20,
              child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  iconSize: 24),
            ),
            Center(
              child: _BuildPlayer(advisorVideo: advisorVideo),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildPlayer extends StatefulWidget {
  const _BuildPlayer({Key? key, required this.advisorVideo}) : super(key: key);
  final AdvisorVideoModel advisorVideo;

  @override
  State<_BuildPlayer> createState() => _PlayerState();
}

class _PlayerState extends State<_BuildPlayer> {
  YoutubePlayerController? _controller;
  // bool isVideoLoading = true;
  bool isError = false;

  YoutubePlayerController getVideoPlayerController(videoId) {
    YoutubePlayerController _controller;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: true,
        showFullscreenButton: true,
        // desktopMode: false,
        // privacyEnhanced: true,
        loop: false,
        mute: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );

    _controller.listen((event) async {
      final hasNotPlayed = event.playerState == PlayerState.unStarted;

      if (hasNotPlayed) {
        // _controller.hidePauseOverlay();
        // _controller.hideTopMenu();
        // _controller.hideYoutubeLogo();
        await _controller.playVideo();
      }

      // if (event.isReady && isVideoLoading) {
      //   // setState(() {
      //   //   isVideoLoading = false;
      //   // });
      // }

      final durationInMilliSeconds = (await _controller.currentTime) * 1000;

      if (!hasNotPlayed && durationInMilliSeconds == 0) {
        if (event.metaData.author.isNotNullOrEmpty) {
          if (event.metaData.author == "Wealthy") {
            // setState(() {
            //   isVideoLoading = false;
            // });
            _controller.unMute();
          } else {
            setState(() {
              isError = true;
            });
            await _controller.stopVideo();
          }
        }
      }
    });

    // _controller.onEnterFullscreen = () {
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.landscapeLeft,
    //     DeviceOrientation.landscapeRight,
    //   ]);
    //   LogUtil.printLog('Entered Fullscreen');
    // };

    // _controller.onExitFullscreen = () {
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // };

    _controller.setFullScreenListener((value) {
      if (value) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });

    return _controller;
  }

  @override
  void dispose() {
    // if (_controller != null) {
    //   _controller!.close();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = getVideoPlayerController(
          YoutubePlayerController.convertUrlToId(widget.advisorVideo.link!));
    }

    if (_controller == null) {
      return Center(
        child: Text(
          'Video not found',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.white),
        ),
      );
    }

    return YoutubePlayerScaffold(
        controller: _controller!,
        builder: (context, player) {
          return YoutubePlayerControllerProvider(
            key: Key(widget.advisorVideo.id ?? ''),
            controller: _controller!,
            child: Stack(
              children: [
                player,
                isError
                    ? Positioned.fill(
                        child: Container(
                          color: Colors.black,
                          // color: Colors.white,
                          // padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'This video cannot be played',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    :
                    // isVideoLoading
                    //     ? Positioned.fill(
                    //         child: Container(
                    //           color: Colors.black,
                    //           child: Center(
                    //             child: CircularProgressIndicator(
                    //                 color: ColorConstants.white),
                    //           ),
                    //         ),
                    //       )
                    //     :
                    SizedBox()
              ],
            ),
          );
        });
  }
}
