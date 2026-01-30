import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/screens/rewards/widgets/pending_redemption_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/kyc_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalRewardsBanner extends StatefulWidget {
  const TotalRewardsBanner({Key? key, this.delayRetryRedemption})
      : super(key: key);

  final bool? delayRetryRedemption;

  @override
  _TotalRewardsBannerState createState() => _TotalRewardsBannerState();
}

class _TotalRewardsBannerState extends State<TotalRewardsBanner> {
  Timer? _timer;
  late int disableRetryTime;
  bool canRetryRedemption = true;
  final RewardsController rewardsController = Get.find<RewardsController>();

  @override
  void initState() {
    // if (widget.delayRetryRedemption) {
    //   disableRetryRedemptionFor(60);
    // } else {
    //   checkDelayAlreadyExists();
    // }
    checkDelayAlreadyExists();
    super.initState();
  }

  Future checkDelayAlreadyExists() async {
    try {
      SharedPreferences sharedPreferences = await prefs;
      int? savedDelay =
          sharedPreferences.getInt(SharedPreferencesKeys.delayRetryRedemption);
      if (savedDelay != null && savedDelay > 0) {
        disableRetryRedemptionFor(savedDelay);
      } else {
        disableRetryTime = 0;
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void disableRetryRedemptionFor(int delay) {
    const oneSec = const Duration(seconds: 1);
    setState(() {
      canRetryRedemption = false;
      disableRetryTime = delay;
    });

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (disableRetryTime == 0) {
          rewardsController.setShouldDelayRedemption(false);
          setState(() {
            timer.cancel();
            canRetryRedemption = true;
          });
        } else {
          setState(() {
            disableRetryTime = disableRetryTime - 1;
          });
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();

    try {
      final SharedPreferences sharedPreferences = await prefs;
      await sharedPreferences.setInt(
          SharedPreferencesKeys.delayRetryRedemption, disableRetryTime);
    } catch (error) {
      LogUtil.printLog(error);
    }

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RewardsController>(
      id: 'rewards-balance',
      initState: (_) async {
        await Get.find<RewardsController>().getRewardsBalance();
        await Get.find<RewardsController>().getPendingRedemption();
      },
      builder: (controller) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (controller.shouldDelayRedemption && canRetryRedemption) {
            disableRetryRedemptionFor(60);
          }
        });
        return Container(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            bottom: 20,
            top: getSafeTopPadding(40, context),
          ),
          color: ColorConstants.secondaryCardColor,
          // color: ColorConstants.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => AutoRouter.of(context).popForced(),
                    child: Image.asset(
                      AllImages().appBackIcon,
                      height: 32,
                      width: 32,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Wealthy Rewards',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Balance',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        controller.rewardsBalanceState == NetworkState.loading
                            ? Container(
                                margin: EdgeInsets.only(top: 12),
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: ColorConstants.secondaryBlack,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                WealthyAmount.currencyFormat(
                                    controller.rewardsBalance, 0),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 28,
                                    ),
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Image.asset(
                      AllImages().rewardsTrophy,
                      width: 65,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (controller.pendingRedemptionState == NetworkState.loading)
                _buildShimmerLoader()
              else if (!canRetryRedemption)
                _buildDisableRedemption(controller)
              else if (controller.pendingRedemption != null)
                PendingRedemptionCard()
              else if (controller.rewardsBalance! > 0)
                _buildRedeemButton(controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorConstants.lightOrangeColor,
      ),
    ).toShimmer(
      baseColor: ColorConstants.lightOrangeColor,
      highlightColor: ColorConstants.white,
    );
  }

  Widget _buildDisableRedemption(RewardsController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorConstants.lightOrangeColor),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: ColorConstants.tertiaryBlack,
          ),
          SizedBox(
            width: 6,
          ),
          Expanded(
            child: Text(
              'Your redemption request was not completed. Please Retry after ${disableRetryTime.toString()} seconds...',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.tertiaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemButton(RewardsController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ActionButton(
        margin: EdgeInsets.zero,
        text: 'Redeem Now',
        onPressed: () async {
          int? kycStatus = await getAgentKycStatus();
          if (kycStatus != null && kycStatus != AgentKycStatus.APPROVED) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
              ),
              builder: (context) => KycWarningBottomSheet(kycStatus: kycStatus),
            );
            return null;
          }

          AutoRouter.of(context).push(
            RedeemRoute(
              balance: controller.rewardsBalance,
              fromScreen: "Active",
            ),
          );
        },
      ),
    );
  }
}
