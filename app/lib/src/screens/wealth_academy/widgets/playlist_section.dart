import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/learn_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/wealth_academy/widgets/playlist_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LearnController>(
      init: LearnController(),
      dispose: (_) {
        Get.delete<LearnController>();
      },
      builder: (controller) {
        if (controller.videoState == NetworkState.loading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.videoState != NetworkState.loading &&
            controller.playLists.length == 0) {
          return Center(
            child: EmptyScreen(
              message: 'No Videos Found',
              iconData: Icons.video_settings,
            ),
          );
        }
        final playLists = controller.playLists;

        if (playLists.length > 0) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            shrinkWrap: true,
            itemCount: playLists.length,
            itemBuilder: (_, index) {
              VideoPlayListModel playList = playLists[index];
              //? get current Video by Index
              return PlayListCard(
                playList: playList,
                onPressed: () {
                  //? open playlist bottom-sheet on video card click.
                  AutoRouter.of(context).push(
                    PlaylistPlayerRoute(videos: playList.videos),
                  );

                  //? notify playlistController for selected video.
                  //? required to play video.
                  // playlistController.playVideo(playList.videos![0]);
                },
              );
            },
            separatorBuilder: (_, index) => SizedBox(height: 16),
          );
        }

        return SizedBox();
      },
    );
  }
}
