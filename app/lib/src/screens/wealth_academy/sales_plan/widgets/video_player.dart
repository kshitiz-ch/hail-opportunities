import 'package:api_sdk/log_util.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key, required this.advisorVideo}) : super(key: key);

  final AdvisorVideoModel advisorVideo;

  @override
  State<VideoPlayer> createState() => _PlayerState();
}

class _PlayerState extends State<VideoPlayer> {
  bool isFullScreen = false;
  // bool isVideoLoading = true;

  YoutubePlayerController? _controller;

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
      //   setState(() {
      //     isVideoLoading = false;
      //   });
      // }

      final durationInMilliSeconds = (await _controller.currentTime) * 1000;
    });

    _controller.setFullScreenListener((value) {
      if (value) {
        isFullScreen = true;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        LogUtil.printLog('Entered Fullscreen');
      } else {
        isFullScreen = false;
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });

    // _controller.onEnterFullscreen = () {
    //   isFullScreen = true;
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.landscapeLeft,
    //     DeviceOrientation.landscapeRight,
    //   ]);
    //   LogUtil.printLog('Entered Fullscreen');
    // };

    // _controller.onExitFullscreen = () {
    //   isFullScreen = false;
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // };
    return _controller;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = getVideoPlayerController(
          YoutubePlayerController.convertUrlToId(widget.advisorVideo.link!));
    }

    return YoutubePlayerScaffold(
      controller: _controller!,
      builder: (context, player) {
        return YoutubePlayerControllerProvider(
          key: Key(widget.advisorVideo.id ?? ''),
          controller: _controller!,
          child: Stack(
            children: [
              Container(
                  // height: double.maxFinite, width: double.maxFinite,
                  child: player),
              // isVideoLoading
              //     ? Positioned.fill(
              //         child: Center(
              //           child: CircularProgressIndicator(
              //               color: ColorConstants.white),
              //         ),
              //       )
              //     :
              // SizedBox()
            ],
          ),
        );
      },
    );
  }
}
