import 'package:app/src/config/constants/enums.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:get/get.dart';

class LearnController extends GetxController {
  AdvisorOverviewRepository advisorOverviewRepository =
      AdvisorOverviewRepository();

  List<AdvisorVideoModel> tutorials = [];
  List<VideoPlayListModel> playLists = [];

  NetworkState videoState = NetworkState.cancel;

  bool isFaqLoading = false;
  bool isTutorialFetching = false;

  void onInit() async {
    getVideos();

    super.onInit();
  }

  Future<void> getVideos() async {
    try {
      videoState = NetworkState.loading;
      update();

      dynamic data = await advisorOverviewRepository.getAdvisorVideos();
      if (data != null && data['status'] == '200') {
        data['response'].forEach((playList) {
          playLists.add(VideoPlayListModel.fromJson(playList));
        });

        videoState = NetworkState.loaded;
        update();
      } else {
        videoState = NetworkState.error;
      }
    } catch (error) {
      videoState = NetworkState.error;
    }
  }
}
