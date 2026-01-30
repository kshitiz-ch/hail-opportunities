import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardBalance extends StatelessWidget {
  final ProfileController? profileController;

  const RewardBalance({Key? key, this.profileController}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        id: GetxId.rewardBalance,
        init: profileController?..getRewardsBalance(),
        builder: (controller) {
          if (controller.getRewardBalanceState == NetworkState.loading) {
            return SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.getRewardBalanceState == NetworkState.error) {
            return Center(
              child: Text(genericErrorMessage),
            );
          }
          if (controller.getRewardBalanceState != NetworkState.loaded) {
            return SizedBox();
          } else {
            return controller.rewardsBalanceModel.balance == null
                ? SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0.toWidth),
                        child: Text(
                          'Your Rewards',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: ColorConstants.secondaryCardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              AllImages().profileRewardsIcon,
                              width: 60,
                              height: 60,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: CommonUI.buildColumnTextInfo(
                                title: 'Reward Balance',
                                titleStyle: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.tertiaryBlack,
                                    ),
                                subtitleStyle: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: ColorConstants.black,
                                    ),
                                subtitle:
                                    '${WealthyAmount.currencyFormat(controller.rewardsBalanceModel.balance, 0, showSuffix: false)}',
                              ),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ClickableText(
                                onClick: () {
                                  AutoRouter.of(context).push(
                                    RewardsRoute(
                                        fromScreen: 'rewards_balance_screen'),
                                  );
                                },
                                text: 'View Rewards',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
          }
        });
  }
}
