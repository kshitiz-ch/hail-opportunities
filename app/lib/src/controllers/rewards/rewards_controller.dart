import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/rewards/models/reward_balance_model.dart';
import 'package:core/modules/rewards/models/reward_model.dart';
import 'package:core/modules/rewards/models/reward_redemption_model.dart';
import 'package:core/modules/rewards/resources/rewards_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class RewardsController extends GetxController {
  NetworkState rewardsState = NetworkState.cancel;
  NetworkState rewardsBalanceState = NetworkState.cancel;
  NetworkState redemptionState = NetworkState.cancel;
  NetworkState retryRedemptionState = NetworkState.cancel;
  NetworkState pendingRedemptionState = NetworkState.cancel;
  NetworkState rewardDetailState = NetworkState.cancel;

  List<RewardModel> rewards = [];
  int? rewardsBalance = 0;
  RewardRedemptionModel? redemption;
  RewardRedemptionModel? pendingRedemption;

  final amountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool hasMadeRedemptionRequest = false;
  bool shouldDelayRedemption = false;
  bool isRedemptionFailed = false;

  String? redemptionErrorMessage;
  String? retryRedemptionErrorMessage;

  RewardModel? rewardDetail;

  Future<void> getRewardsBalance() async {
    rewardsBalanceState = NetworkState.loading;
    update(['rewards-balance']);

    try {
      String apiKey = (await getApiKey())!;
      int? agentId = await getAgentId();
      // TODO: change agentId.toString() -> agentId
      var response = await RewardsRepository()
          .getRewardsBalance(apiKey, agentId.toString());
      if (response["status"] == "200") {
        RewardsBalanceModel rewardsBalanceModel =
            RewardsBalanceModel.fromJson(response["response"]);

        rewardsBalanceState = NetworkState.loaded;
        rewardsBalance = rewardsBalanceModel.balance;
      } else {
        rewardsBalanceState = NetworkState.error;
      }
    } catch (error) {
      rewardsBalanceState = NetworkState.error;
    } finally {
      update(['rewards-balance']);
    }
  }

  Future<void> getActiveRewards() async {
    rewardsState = NetworkState.loading;
    rewards = [];
    update(['rewards-listing']);
    try {
      String apiKey = (await getApiKey())!;
      int agentId = (await getAgentId())!;
      var response = await RewardsRepository().getRewards(apiKey, agentId);
      if (response["status"] == "200") {
        var data = response["response"];
        data.forEach((datum) {
          datum["reward"]["reward_id"] = datum["id"];
          RewardModel reward = RewardModel.fromJson(datum["reward"]);
          rewards.add(reward);
        });

        rewardsState = NetworkState.loaded;
      } else {
        rewardsState = NetworkState.error;
      }
    } catch (error) {
      rewardsState = NetworkState.error;
    } finally {
      update(['rewards-listing']);
    }
  }

  Future<void> getCompletedRewards() async {
    rewardsState = NetworkState.loading;
    rewards = [];
    update(['rewards-listing']);

    try {
      List<RewardModel> rewardsWon = [];

      String apiKey = (await getApiKey())!;
      int? agentId = await getAgentId();

      var nonRedeemedResponse = await RewardsRepository()
          .getRewardsWon(apiKey, agentId.toString(), isRedeemed: false);
      if (nonRedeemedResponse["status"] == "200") {
        var data = nonRedeemedResponse["response"];
        data.forEach((datum) {
          datum["reward"]["reward_id"] = datum["id"];
          datum["reward"]["earned_at"] = datum["earned_at"];
          datum["reward"]["redeemed_at"] = datum["redeemed_at"];
          RewardModel reward = RewardModel.fromJson(datum["reward"]);
          rewardsWon.add(reward);
        });
      }

      var redeemedResponse = await RewardsRepository()
          .getRewardsWon(apiKey, agentId.toString(), isRedeemed: true);
      if (redeemedResponse["status"] == "200") {
        var data = redeemedResponse["response"];
        data.forEach((datum) {
          datum["reward"]["reward_id"] = datum["id"];
          datum["reward"]["earned_at"] = datum["earned_at"];
          datum["reward"]["redeemed_at"] = datum["redeemed_at"];
          RewardModel reward = RewardModel.fromJson(datum["reward"]);
          rewardsWon.add(reward);
        });
      }

      rewards = rewardsWon;
      rewardsState = NetworkState.loaded;
    } catch (error) {
      rewardsState = NetworkState.error;
    } finally {
      update(['rewards-listing']);
    }
  }

  Future<void> redeemMoney() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isRedemptionFailed = false;
    redemptionState = NetworkState.loading;
    update(['rewards-redeem']);

    try {
      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      var response = await RewardsRepository().sendRewardRedeemRequest(
        apiKey,
        agentId.toString(),
        amountController.text.replaceAll(',', ''),
      );

      if (response["status"] == "200") {
        var data = response["response"];
        redemption = RewardRedemptionModel.fromJson(data);

        redemptionState = NetworkState.loaded;
      } else {
        shouldDelayRedemption = false;
        redemptionState = NetworkState.error;
        redemptionErrorMessage =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (error) {
      // To Prevent the user from redeeming again immediately
      isRedemptionFailed = true;
      redemptionState = NetworkState.error;
      redemptionErrorMessage = 'Something went wrong. Please try again';
    } finally {
      update(['rewards-redeem']);
    }
  }

  Future<void> getPendingRedemption() async {
    pendingRedemptionState = NetworkState.loading;
    update(['rewards-balance']);

    try {
      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      var response = await RewardsRepository()
          .getRewardRedemptions(apiKey, agentId.toString());
      if (response["status"] == "200") {
        var data = response["response"];
        RewardRedemptionModel? pendingRedemptionFound;
        for (var datum in data) {
          RewardRedemptionModel activeRedemption =
              RewardRedemptionModel.fromJson(datum);

          if (activeRedemption.redeemStatus == RewardRedemptionStatus.Created ||
              activeRedemption.redeemStatus ==
                  RewardRedemptionStatus.PaymentInitiated ||
              activeRedemption.redeemStatus ==
                  RewardRedemptionStatus.PaymentPending) {
            pendingRedemptionFound = activeRedemption;
            break;
          }
        }

        // [pendingRedemptionFound] is created to make sure pending Redemption becomes null if there is no active redemption
        pendingRedemption = pendingRedemptionFound;

        pendingRedemptionState = NetworkState.loaded;
      } else {
        pendingRedemptionState = NetworkState.error;
      }
    } catch (error) {
      pendingRedemptionState = NetworkState.error;
    } finally {
      update(['rewards-balance']);
    }
  }

  Future<void> retryRewardRedemptionRequest() async {
    retryRedemptionState = NetworkState.loading;
    update(['rewards-balance']);

    try {
      String apiKey = (await getApiKey())!;
      var response = await RewardsRepository()
          .retryRewardRedemptionRequest(pendingRedemption!.orderId, apiKey);

      if (response["status"] == "200") {
        var data = response["response"];
        redemption = RewardRedemptionModel.fromJson(data);
        if (redemption?.thirdPartyPaymentLink != null) {
          retryRedemptionState = NetworkState.loaded;
        } else {
          retryRedemptionState = NetworkState.error;
          retryRedemptionErrorMessage =
              "Failed to generate redemption request. Please try after sometime";
        }
      } else {
        retryRedemptionErrorMessage =
            getErrorMessageFromResponse(response["response"]);
        retryRedemptionState = NetworkState.error;
      }
    } catch (error) {
      retryRedemptionState = NetworkState.error;
    } finally {
      update(['rewards-balance']);
    }
  }

  void getRewardDetails(String? rewardId) async {
    try {
      rewardDetailState = NetworkState.loading;
      update([GetxId.rewardDetail]);
      final apiKey = (await getApiKey())!;
      final agentId = await getAgentId();
      final response = await RewardsRepository().getSpecificReward(
        rewardId,
        apiKey,
        agentId.toString(),
      );
      if (response["status"] == "200") {
        final reward = response["response"]["reward"];
        rewardDetail = RewardModel.fromJson(reward);
        rewardDetailState = NetworkState.loaded;
      }
    } catch (error) {
      rewardDetailState = NetworkState.error;
      LogUtil.printLog(error);
    } finally {
      update([GetxId.rewardDetail]);
    }
  }

  setShouldDelayRedemption(bool val) {
    shouldDelayRedemption = val;
    update(['rewards-balance']);
  }
}
