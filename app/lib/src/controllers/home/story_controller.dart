import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/main.dart';
import 'package:core/modules/app_resources/resources/app_resources_repository.dart';
import 'package:core/modules/dashboard/models/story_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryListController extends GetxController {
  // From story view package
  StoryController storyController = StoryController();
  AnimationController? animationController;

  NetworkState storiesState = NetworkState.loading;
  List<StoryModel> stories = [];
  List<StoryItem> storyItems = [];

  RxBool animateStoryIcon = false.obs;

  void onInit() {
    ever(
      animateStoryIcon,
      (value) {
        if (animationController != null) {
          if (animateStoryIcon.isTrue) {
            animationController!
              ..forward()
              ..addListener(
                () {
                  if (animationController!.isCompleted) {
                    animationController!.repeat();
                  }
                },
              );
          } else {
            animationController?.stop();
          }
        }
      },
    );
    super.onInit();
  }

  void dispose() {
    animationController?.dispose();
    storyController.dispose();
    super.dispose();
  }

  Future<void> getStories(
      {String? storyIdToNavigate, updateStoryItems = false}) async {
    storiesState = NetworkState.loading;
    update();

    try {
      // var storyResponse = await AdvisorOverviewRepository().getStories();

      // List<StoryModel> storyModelList = [];
      // if (storyResponse['status'] == '200') {
      //   var storyList = storyResponse['response'];
      //   // await cacheStoryJsonAsString(storyList);

      //   storyList.forEach((story) {
      //     storyModelList.add(StoryModel.fromJson(story));
      //   });
      // } else {
      //   storiesState = NetworkState.error;
      // }

      List<StoryModel> storyModelList = [];

      try {
        final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 0),
            minimumFetchInterval: Duration.zero,
          ),
        );
        await remoteConfig.fetchAndActivate();
        LogUtil.printLog(jsonDecode(
          remoteConfig.getValue("stories").asString(),
        ));
        List<dynamic> storiesJsonList = jsonDecode(
          remoteConfig.getValue("stories").asString(),
        ) as List<dynamic>;

        if (storiesJsonList.isNotNullOrEmpty) {
          storiesJsonList.forEach((element) {
            storyModelList.add(StoryModel.fromJson(element));
          });
        }

        if (storyModelList.isNotEmpty) {
          storyModelList.sort((a, b) => a.position!.compareTo(b.position!));
        }
      } catch (error) {
        LogUtil.printLog(error);
      }

      // Fetch daily creative story using tag master API
      StoryModel? dailyCreativeStoryModel = await getDailyCreativeStory();
      if (dailyCreativeStoryModel != null) {
        storyModelList.add(dailyCreativeStoryModel);
      }

      // Create Story Items which are then passed to the story screen to have Story like UI
      if (updateStoryItems) {
        await getStoryItems(storyModelList, storyIdToNavigate);
      }

      if (storyModelList.isNotEmpty) {
        stories = storyModelList;
        storiesState = NetworkState.loaded;
      } else {
        storiesState = NetworkState.error;
      }
    } catch (error) {
      storiesState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<StoryModel?> getDailyCreativeStory() async {
    StoryModel? dailyCreativeStoryModel;

    try {
      final englishLanguageTag = "tag_3Js65koCX6A";
      final apiKey = await getApiKey() ?? '';
      final payload = {
        "tenant": "pgallery",
        "tags": [englishLanguageTag]
      };
      final queryParams = '?limit=1&offset=0&order_by=-created_at&filetype=img';
      var data = await AppResourcesRepository().getResources(
        apiKey: apiKey,
        queryParams: queryParams,
        payload: payload,
      );

      if (data['status'] == '200') {
        List creativesListJson = data["response"]["data"] as List;

        if (creativesListJson.isNotEmpty &&
            creativesListJson.first["type"] == "img") {
          dailyCreativeStoryModel = StoryModel.fromJson({
            "id": creativesListJson.first["id"],
            "name": "daily_creative",
            "image": "https://${creativesListJson.first["url"]}"
          });
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    return dailyCreativeStoryModel;
  }

  Future<StoryModel?> getDailyUpdateStory() async {
    StoryModel? dailyUpdateStoryModel;

    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 0),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate();
      Map<String, dynamic> dailyUpdateStoryJson = jsonDecode(
        remoteConfig.getValue("daily_update_story").asString(),
      ) as Map<String, dynamic>;

      if (dailyUpdateStoryJson.isNotEmpty) {
        // await cacheStoryJsonAsString(dailyUpdateStoryJson, isDMU: true);
        dailyUpdateStoryModel = StoryModel.fromJson(dailyUpdateStoryJson);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    return dailyUpdateStoryModel;
  }

  Future<void> cacheStoryJsonAsString(storyJson, {bool isDMU = false}) async {
    try {
      SharedPreferences sharedPreferences = await prefs;
      String storyBase64 = jsonToBase64(storyJson);

      String sharedPreferenceKey = isDMU
          ? SharedPreferencesKeys.dailyMarketUpdateBase64
          : SharedPreferencesKeys.storyListBase64;

      String cachedStoryListBase64 =
          sharedPreferences.getString(sharedPreferenceKey) ?? '';

      if (storyBase64.isNotEmpty && storyBase64 != cachedStoryListBase64) {
        // animateStoryIcon.value = true;
        sharedPreferences.setString(sharedPreferenceKey, storyBase64);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> getStoryItems(
      List<StoryModel> storiesList, String? storyIdToNavigate) async {
    storyItems = storiesList.map<StoryItem>((story) {
      bool isStoryLoaded = false;

      return StoryItem(
        Container(
          color: Colors.black,
          width: SizeConfig().screenWidth,
          padding: EdgeInsets.only(top: 40),
          child: CachedNetworkImage(
            imageUrl: story.image!,
            fit: BoxFit.contain,
            imageBuilder: (context, object) {
              if (!isStoryLoaded) {
                isStoryLoaded = true;
              }

              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: object,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
            progressIndicatorBuilder:
                (BuildContext context, String url, DownloadProgress progress) {
              // If image is not loaded or downloading is less than 100%, pause the story controller
              if (!isStoryLoaded &&
                  (progress.progress == null || progress.progress! < 1)) {
                storyController.pause();
              } else {
                isStoryLoaded = true;
                storyController.play();
              }

              return Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
        duration: Duration(seconds: 3),
        shown: story.name != storyIdToNavigate,
      );
    }).toList();
  }

  void disableAnimateStoryIcon() {
    animateStoryIcon.value = false;
    update();
  }
}
