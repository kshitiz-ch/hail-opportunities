import 'dart:math';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/learn_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/widgets/learn_with_wealthy_section.dart';
import 'package:app/src/screens/wealth_academy/widgets/playlist_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WealthyAcademySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LearnController>(
      init: LearnController(),
      dispose: (_) {
        Get.delete<LearnController>();
      },
      builder: (controller) {
        if (controller.videoState == NetworkState.loading) {
          return SkeltonLoaderCard(
            height: 500,
            margin: EdgeInsets.only(left: 20, right: 20, top: 16),
          );
        }
        if (controller.videoState == NetworkState.error) {
          return SizedBox(
            height: 500,
            child: Center(
              child: RetryWidget(
                genericErrorMessage,
                onPressed: () {
                  controller.getVideos();
                },
              ),
            ),
          );
        }
        if (controller.videoState == NetworkState.loaded) {
          if (controller.playLists.isNullOrEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: EmptyScreen(
                iconData: Icons.video_library,
                message: 'No Videos Found',
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              min(maxNoOfEntries, controller.playLists.length),
              (index) {
                final playList = controller.playLists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PlayListCard(
                    playList: playList,
                    onPressed: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "wealth_academy_open",
                        properties: {
                          "screen_location": "wealth_academy",
                          "screen": "Home",
                        },
                      );
                      AutoRouter.of(context).push(
                        PlaylistPlayerRoute(
                          videos: playList.videos,
                        ),
                      );
                    },
                  ),
                );
              },
            )..addIf(
                maxNoOfEntries < controller.playLists.length,
                buildViewAllCTA(
                  context: context,
                  onClick: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "wealth_academy_view_all",
                      properties: {
                        "screen_location": "wealth_academy",
                        "screen": "Home",
                      },
                    );
                    AutoRouter.of(context).push(WealthAcademyRoute());
                  },
                ),
              ),
          );
        }

        return SizedBox();
      },
    );
  }
}
