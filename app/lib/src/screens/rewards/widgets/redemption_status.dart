import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/rewards/models/reward_redemption_model.dart';
import 'package:core/modules/rewards/resources/rewards_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class RedemptionStatusScreen extends StatefulWidget {
  final String? redemptionId;
  RedemptionStatusScreen({this.redemptionId});

  @override
  _RedemptionStatusScreenState createState() => _RedemptionStatusScreenState();
}

class _RedemptionStatusScreenState extends State<RedemptionStatusScreen> {
  bool isLoading = true;

  @override
  initState() {
    super.initState();

    checkRedemptionStatus();
  }

  checkRedemptionStatus() async {
    try {
      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;
      var response = await RewardsRepository()
          .getRewardRedemption(widget.redemptionId!, apiKey, agentId);
      if (response["status"] == "200") {
        var data = response["response"];
        RewardRedemptionModel redemption = RewardRedemptionModel.fromJson(data);

        if (redemption.payoutCompletedAt != null && redemption.amount != null) {
          AutoRouter.of(context).push(
            RewardSuccessRoute(
              amount: WealthyCast.toInt(redemption.amount),
            ),
          );
        } else {
          if (Get.isRegistered<RewardsController>()) {
            Get.find<RewardsController>().getRewardsBalance();
            Get.find<RewardsController>().getPendingRedemption();
          }
          AutoRouter.of(context)
              .popUntil(ModalRoute.withName(RewardsRoute.name));
        }
      } else {
        final errorMessage = getErrorMessageFromResponse(response);
        showToast(text: errorMessage);
        AutoRouter.of(context).popUntil(ModalRoute.withName(RewardsRoute.name));
      }
    } catch (error) {
      if (Get.isRegistered<RewardsController>()) {
        Get.find<RewardsController>().getRewardsBalance();
        Get.find<RewardsController>().getPendingRedemption();
      }
      AutoRouter.of(context).popUntil(ModalRoute.withName(RewardsRoute.name));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          if (!isLoading) {
            AutoRouter.of(context).popForced();
          }
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: Container(
          child: isLoading
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
