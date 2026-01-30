import 'package:api_sdk/api_collection/reward_api.dart';
import 'package:api_sdk/log_util.dart';

class RewardsRepository {
  Future<dynamic> getRewards(String apiKey, int agentId) async {
    try {
      final response = await RewardAPI.getRewards(apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSpecificReward(rewardId, String apiKey, agentId) async {
    try {
      final response =
          await RewardAPI.getSpecificReward(rewardId, apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRewardsWon(String apiKey, agentId,
      {required bool isRedeemed}) async {
    try {
      final response =
          await RewardAPI.getRewardsWon(apiKey, agentId, isRedeemed);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRewardsBalance(String apiKey, agentId) async {
    try {
      final response = await RewardAPI.getRewardsBalance(apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> addRewardBalance(
      String rewardId, String apiKey, agentId) async {
    try {
      final response =
          await RewardAPI.addRewardBalance(rewardId, apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRewardRedemptions(String apiKey, agentId) async {
    try {
      final response = await RewardAPI.getRewardRedemptions(apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getRewardRedemption(
      String redemptionId, String apiKey, agentId) async {
    try {
      final response =
          await RewardAPI.getRewardRedemption(redemptionId, apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> markRewardRedemptionFail(
      String orderId, String apiKey, agentId) async {
    try {
      final response =
          await RewardAPI.markRewardRedemptionFail(orderId, apiKey, agentId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> retryRewardRedemptionRequest(orderId, String apiKey) async {
    try {
      final response =
          await RewardAPI.retryRewardRedemptionRequest(orderId, apiKey);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> sendRewardRedeemRequest(
      String apiKey, agentId, amount) async {
    try {
      Map payload = {"amount": amount};

      final response =
          await RewardAPI.sendRewardRedeemRequest(apiKey, agentId, payload);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
