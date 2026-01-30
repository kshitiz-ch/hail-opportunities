import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/screens/rewards/details/widgets/reward_terms_conditions.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/rewards/models/reward_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

String defaultBackgroundImage =
    "https://res.cloudinary.com/dti7rcsxl/image/upload/v1638179825/group_2x_1_vjk3us.png";

@RoutePage()
class RewardsDetailsScreen extends StatelessWidget {
  final RewardModel? reward;
  final String? rewardId;
  late RewardsController rewardsController;

  RewardsDetailsScreen({this.reward, @pathParam this.rewardId}) {
    rewardsController = Get.isRegistered<RewardsController>()
        ? Get.find<RewardsController>()
        : Get.put<RewardsController>(RewardsController());
    rewardsController.getRewardDetails(
      reward?.rewardId?.toString() ?? rewardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = getSafeTopPadding(24, context);
    return GetBuilder<RewardsController>(
        id: GetxId.rewardDetail,
        builder: (controller) {
          late String expiresAt;
          if (controller.rewardDetail?.endAt != null) {
            DateTime expiryFormatted =
                DateTime.parse(controller.rewardDetail!.endAt!);
            expiresAt = DateFormat('dd MMM').format(expiryFormatted);
          }

          return Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: controller.rewardDetailState != NetworkState.loading &&
                    controller.rewardDetail == null
                ? CustomAppBar(
                    showBackButton: true,
                  )
                : null,
            body: controller.rewardDetailState == NetworkState.loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : controller.rewardDetailState == NetworkState.loaded &&
                        controller.rewardDetail != null
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 80 + topPadding - 24,
                              color: ColorConstants.secondaryCardColor,
                              padding: EdgeInsets.only(
                                top: topPadding,
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24, right: 12),
                                    child: IconButton(
                                      onPressed: () {
                                        AutoRouter.of(context).popForced();
                                      },
                                      icon: Image.asset(
                                        AllImages().appBackIcon,
                                        height: 32,
                                        width: 32,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    (controller.rewardDetail?.name ?? '')
                                        .toTitleCase(),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.black,
                                        ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: ColorConstants.secondaryCardColor,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 45.0, right: 24),
                                    child: Image.asset(
                                      AllImages().rewardsTrophy,
                                      width: 50,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: CommonUI.buildColumnTextInfo(
                                      title: 'Cash Reward',
                                      subtitle: WealthyAmount.currencyFormat(
                                          controller.rewardDetail?.rewardValue,
                                          0),
                                      gap: 2,
                                      titleStyle: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: ColorConstants.tertiaryBlack,
                                          ),
                                      subtitleStyle: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 28,
                                            color: ColorConstants.black,
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: ColorConstants.secondaryCardColor,
                              padding: EdgeInsets.only(
                                top: 28,
                                bottom: 20,
                                left: 30,
                                right: 30,
                              ),
                              child: Text(
                                controller.rewardDetail?.description ?? '',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: ColorConstants.black,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 30),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Expiry: ',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: ColorConstants.tertiaryBlack,
                                        ),
                                  ),
                                  Text(
                                    controller.rewardDetail?.endAt != null
                                        ? expiresAt
                                        : 'No Expiry',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: ColorConstants.black,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.rewardDetail?.conditions != null)
                              SingleChildScrollView(
                                padding: EdgeInsets.only(bottom: 100),
                                child: RewardTermsConditions(
                                  rewardDetails: controller.rewardDetail,
                                ),
                              )
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          'This reward does not exist.',
                          textAlign: TextAlign.center,
                        ),
                      ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ActionButton(
              text: 'Back to Rewards',
              height: 56,
              borderRadius: 51,
              margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
              onPressed: () {
                AutoRouter.of(context).popForced();
              },
            ),
          );
        });
  }
}
