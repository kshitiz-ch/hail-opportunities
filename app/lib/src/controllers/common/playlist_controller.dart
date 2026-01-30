import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlaylistPlayerController extends GetxController {
  AdvisorVideoModel? currentVideo;
  VideoPlayListModel? playlist;

  NetworkState? playlistState;

  bool isVideoPlaying = false;

  late YoutubePlayerController youtubePlayerController;

  PlaylistPlayerController({this.currentVideo});

  @override
  void onInit() {
    super.onInit();
    youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: true,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );
    youtubeControllerListener();
  }

  void youtubeControllerListener() {
    youtubePlayerController.listen((event) async {
      final hasNotPlayed = event.playerState == PlayerState.unStarted;

      if (hasNotPlayed) {
        youtubePlayerController.playVideo();
      }

      if (isVideoPlaying && event.playerState == PlayerState.paused) {
        setIsVideoPlaying(false);
      } else if (!isVideoPlaying && event.playerState == PlayerState.playing) {
        setIsVideoPlaying(true);
      }

      final durationInMilliSeconds =
          (await youtubePlayerController.currentTime) * 1000;

      if (!hasNotPlayed && durationInMilliSeconds == 0) {}
    });

    // widget.youtubePlayerController.setFullScreenListener((value) {
    //   if (value) {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.landscapeLeft,
    //       DeviceOrientation.landscapeRight,
    //     ]);
    //   } else {
    //     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //   }
    // });
  }

  Future<void> getPlaylist(
      {required String playlistId, String? initalVideoUrl}) async {
    try {
      playlistState = NetworkState.loading;

      dynamic data = await AdvisorOverviewRepository()
          .getAdvisorVideos(playlistId: playlistId);
      if (data != null && data['status'] == '200') {
        playlist = VideoPlayListModel.fromJson(data['response']);

        AdvisorVideoModel? videoFound;
        if (initalVideoUrl.isNotNullOrEmpty) {
          for (AdvisorVideoModel video in playlist!.videos!) {
            if (video.link == initalVideoUrl) {
              videoFound = video;
              break;
            }
          }
        }

        if (videoFound != null) {
          playlistState = NetworkState.loaded;
          playVideo(videoFound);
        } else if (playlist != null && playlist!.videos!.isNotEmpty) {
          playlistState = NetworkState.loaded;
          playVideo(playlist!.videos!.first);
        } else {
          playlistState = NetworkState.error;
        }
      } else {
        playlistState = NetworkState.error;
      }
    } catch (error) {
      playlistState = NetworkState.error;
    } finally {
      update();
    }
  }

  void setIsVideoPlaying(bool val) {
    if (val != isVideoPlaying) {
      isVideoPlaying = val;
      update();
    }
  }

  Future<void> playVideo(AdvisorVideoModel video) async {
    if (currentVideo != video) {
      currentVideo = video;
      await youtubePlayerController.loadVideo(currentVideo!.link!);
      update();
    }
  }

  void resetPlaylist() {
    playlist = null;
    currentVideo = null;
    playlistState = NetworkState.cancel;
  }
}
