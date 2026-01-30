import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/reward_listing.dart';
import 'widgets/total_rewards_banner.dart';

@RoutePage()
class RewardsScreen extends StatelessWidget {
  RewardsScreen({this.fromScreen, this.delayRetryRedemption = false});

  final String? fromScreen;
  final bool delayRetryRedemption;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: RewardsController(),
        dispose: (_) => Get.delete<RewardsController>(),
        builder: (dynamic context) {
          return Scaffold(
            backgroundColor: ColorConstants.white,
            body: Column(
              children: [
                TotalRewardsBanner(delayRetryRedemption: delayRetryRedemption),
                Expanded(
                  child: RewardListing(
                    fromScreen: fromScreen,
                  ),
                )
              ],
            ),
          );
        });
  }
}
