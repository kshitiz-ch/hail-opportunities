import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/wealth_academy/resources/events_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SalesPlanController extends GetxController {
  NetworkState creativesListState = NetworkState.loading;

  PageController? pageController;
  late int currentCarouselIndex;
  bool isSalesPlanIdExists = false;
  // String salesPlanId;

  SalesPlanController();

  // NetworkState videoState;

  List<CreativeNewModel> creatives = [];
  List<AdvisorVideoModel> videos = [];

  int currentVideoIndex = 0;
  bool isVideoPlaying = false;
  bool isVideoEnded = false;
  // bool isVideoLoading = true;
  bool isFullScreenEnabled = false;
  bool showPlayerButton = true;
  bool isCheckedForNewCreatives = false;

  YoutubePlayerController? currentVideoPlayerController;
  Duration? currentPlayingVideoPosition;

  TabController? tabController;
  PageController? resourceTabPageController;

  File? creativeCacheFile;

  void onInit() async {
    creativeCacheFile = await getCreativesCacheFile();
    bool isCreativeCacheExists = (await creativeCacheFile?.exists())!;

    if (isCreativeCacheExists) {
      getCreativesFromCache(creativeCacheFile!);
    } else {
      getCreatives();
    }
    // getVideos();
    super.onInit();
  }

  @override
  void dispose() {
    currentVideoPlayerController?.close();
    tabController?.dispose();
    resourceTabPageController?.dispose();
    super.dispose();
  }

  void initPageController(int selectedIndex) {
    currentCarouselIndex = selectedIndex;
    pageController = PageController(initialPage: selectedIndex);
  }

  void moveToNextCarousel({int? index}) {
    if (index == null) {
      pageController!
          .nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
      currentCarouselIndex++;
    } else {
      pageController!.jumpToPage(index);
      currentCarouselIndex = index;
    }
    update([GetxId.creativesCarousel]);
  }

  void moveToPreviousCarousel({int? index}) {
    if (index == null) {
      pageController!.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      currentCarouselIndex--;
    } else {
      pageController!.jumpToPage(index);
      currentCarouselIndex = index;
    }
    update([GetxId.creativesCarousel]);
  }

  Future<void> getCreatives() async {
    creativesListState = NetworkState.loading;
    if (creatives.isNotEmpty) {
      creatives.clear();
    }

    if (videos.isNotEmpty) {
      videos.clear();
    }

    update();

    try {
      String salesPlanId = await getSalesPlanId();
      if (salesPlanId.isNullOrEmpty) {
        isSalesPlanIdExists = false;
        throw Exception();
      } else {
        isSalesPlanIdExists = true;
      }

      var data = await EventsRepository().getSalesPlanCreatives(salesPlanId);
      if (data['status'] == '200') {
        // creatives = CreativesModel.fromJson(data['response']);
        data['response']['creatives'].forEach((datum) {
          creatives.add(CreativeNewModel.fromJson(datum));
        });
        data['response']['videos'].forEach((datum) {
          videos.add(AdvisorVideoModel.fromJson(datum));
        });

        creativesListState = NetworkState.loaded;

        if (creativeCacheFile != null) {
          await createCreativeCache(creativeCacheFile!, data["response"]);
        }

        // exclude videos for salesplan
        // creativesModel.creatives
        //     .removeWhere((element) => element.type != "image");
      } else {
        creativesListState = NetworkState.error;
      }
    } catch (error) {
      creativesListState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getCreativesFromCache(File creativeCacheFile) async {
    try {
      String jsonData = await creativeCacheFile.readAsString();
      Map data = json.decode(jsonData);
      data['creatives'].forEach((datum) {
        creatives.add(CreativeNewModel.fromJson(datum));
      });
      data['videos'].forEach((datum) {
        videos.add(AdvisorVideoModel.fromJson(datum));
      });
      creativesListState = NetworkState.loaded;
    } catch (error) {
      getCreatives();
    } finally {
      update();
    }
  }

  Future<void> createCreativeCache(File file, response) async {
    try {
      await file.writeAsString('${json.encode(response)}');
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<File?> getCreativesCacheFile() async {
    File? creativesCacheFile;
    try {
      final directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      creativesCacheFile = File('$path/sales-plan-creatives.json');
    } catch (error) {
      LogUtil.printLog(error);
    }

    return creativesCacheFile;
  }

  void checkForNewCreatives() async {
    isCheckedForNewCreatives = true;
    String? currentCreativesUpdatedAt =
        await getDataUpdatedAt(CloudflareContent.insuranceSalesPlan);
    Map? data = await AdvisorOverviewRepository()
        .getDataUpdatedAt(CloudflareContent.insuranceSalesPlan);

    String? newCreativesUpdatedAt = data != null ? data['response'] : '';

    if (currentCreativesUpdatedAt.isNotNullOrEmpty) {
      bool shouldFetchNewCreatives = isDataUpdatedAtExpired(
          currentUpdatedAt: currentCreativesUpdatedAt!,
          newUpdatedAt: newCreativesUpdatedAt!);

      if (shouldFetchNewCreatives) {
        await setDataUpdatedAt(
            CloudflareContent.insuranceSalesPlan, newCreativesUpdatedAt);
        getCreatives();
      }
    } else {
      await setDataUpdatedAt(
          CloudflareContent.insuranceSalesPlan, newCreativesUpdatedAt);
    }
  }

  void initialiseVideoPlayerController(String videoId) {
    currentVideoPlayerController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: false,
        showFullscreenButton: false,
        // desktopMode: false,
        // privacyEnhanced: true,
        loop: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );

    currentVideoPlayerController?.listen(
      (YoutubePlayerValue event) async {
        final hasNotPlayed = event.playerState == PlayerState.unStarted;
        if (hasNotPlayed) {
          // currentVideoPlayerController!.hidePauseOverlay();
          // currentVideoPlayerController!.hideTopMenu();
          // currentVideoPlayerController!.hideYoutubeLogo();
          await currentVideoPlayerController!.playVideo();
          showPlayerButton = true;
          startHidePlayerButtonTimer();
        }

        final durationInMilliSeconds =
            (await currentVideoPlayerController?.currentTime ?? 0) * 1000;
        currentPlayingVideoPosition =
            Duration(milliseconds: durationInMilliSeconds.toInt());

        // if (event.isReady && isVideoLoading) {
        //   isVideoLoading = false;
        // }

        if (!isVideoEnded && event.playerState == PlayerState.ended) {
          isVideoEnded = true;
          isVideoPlaying = false;
          await currentVideoPlayerController?.stopVideo();
        }

        if (isVideoPlaying && event.playerState == PlayerState.paused) {
          isVideoPlaying = false;
        } else if (!isVideoPlaying &&
            event.playerState == PlayerState.playing) {
          isVideoEnded = false;
          isVideoPlaying = true;
        }

        if (!hasNotPlayed && durationInMilliSeconds == 0) {}
        update();
      },
    );
    currentVideoPlayerController?.setFullScreenListener(
      (value) {
        if (value) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
      },
    );
  }

  Stream<Duration> checkCurrentPlayingStream() async* {
    while (true) {
      try {
        final durationInMilliSeconds =
            (await currentVideoPlayerController?.currentTime ?? 0) * 1000;
        currentPlayingVideoPosition =
            Duration(milliseconds: durationInMilliSeconds.toInt());
        yield currentPlayingVideoPosition!;
      } catch (error) {
        LogUtil.printLog('error==>${error.toString()}');
        yield Duration.zero;
      } finally {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> togglePlay() async {
    if (isVideoPlaying) {
      isVideoPlaying = false;
      await currentVideoPlayerController!.pauseVideo();
    } else {
      isVideoPlaying = true;
      if (currentPlayingVideoPosition != null) {
        // Check if video has played out its total duration
        if (currentVideoPlayerController!.metadata.duration ==
            currentPlayingVideoPosition) {
          await currentVideoPlayerController!.seekTo(
            seconds: 0,
            allowSeekAhead: true,
          );
          // currentVideoPlayerController!.reset();
        } else {
          await currentVideoPlayerController!.seekTo(
            seconds: (currentPlayingVideoPosition?.inSeconds ?? 0).toDouble(),
            allowSeekAhead: true,
          );
        }
      } else {
        await currentVideoPlayerController!.playVideo();
      }
    }
    showPlayerButton = true;
    update();
    startHidePlayerButtonTimer();
  }

  Future<void> changeVideoPosition(int milliseconds) async {
    currentPlayingVideoPosition = Duration(milliseconds: milliseconds);
    await currentVideoPlayerController!.seekTo(
      seconds: (currentPlayingVideoPosition?.inSeconds ?? 0).toDouble(),
      allowSeekAhead: true,
    );
    update();
  }

  void resetPlayerConfiguration() {
    currentVideoIndex = 0;
    isVideoPlaying = false;
    // isVideoLoading = true;
    currentVideoPlayerController = null;
    currentPlayingVideoPosition = null;
  }

  void toggleFullscreen() {
    if (isFullScreenEnabled) {
      currentVideoPlayerController!.exitFullScreen();
    } else {
      currentVideoPlayerController!.enterFullScreen();
    }
    isFullScreenEnabled = !isFullScreenEnabled;
    update();
  }

  void startHidePlayerButtonTimer() {
    Timer(Duration(seconds: 4), () {
      showPlayerButton = false;
      update();
    });
  }

  void dislayPlayerButton() {
    showPlayerButton = true;
    update();
    startHidePlayerButtonTimer();
  }

  void updateCurrentPlayingVideo(int videoIndex) {
    resetPlayerConfiguration();
    currentVideoIndex = videoIndex;
    initialiseVideoPlayerController(
      YoutubePlayerController.convertUrlToId(videos[currentVideoIndex].link!)!,
    );
    update();
  }

  void refreshCurrentVideo() {
    isVideoEnded = false;
    isVideoPlaying = true;
    // currentVideoPlayerController!.reset();
  }

  void onCloseCreativeBottomSheet() {
    // sync carouselIndex with cardListIndex
    resourceTabPageController!.animateToPage(
      currentCarouselIndex,
      duration: Duration(milliseconds: 100),
      curve: Curves.ease,
    );
    update();
  }
}
