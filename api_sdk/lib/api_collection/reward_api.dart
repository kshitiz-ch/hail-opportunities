import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class RewardAPI {
  static getRewards(apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('rewards')}?won=false', headers);

    return response;
  }

  static getRewardsWon(apiKey, agentId, bool? isRedeemed) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('rewards')}?won=true';

    if (isRedeemed != null) {
      apiUrl += '&redeemed=${isRedeemed.toString()}';
    }

    apiUrl += '&redeemed=${isRedeemed.toString()}';
    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static getSpecificReward(rewardId, apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.getData(
      '${ApiConstants().getRestApiUrl('rewards')}$rewardId/',
      headers,
      isUTF8: true,
    );

    return response;
  }

  static getRewardsBalance(apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('rewards')}balance/', headers);

    return response;
  }

  static addRewardBalance(rewardId, apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('rewards')}$rewardId/add-to-balance/',
        {},
        headers);

    return response;
  }

  static getRewardRedemptions(apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('rewards-redemption')}', headers);

    return response;
  }

  static getRewardRedemption(redemptionId, apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.getData(
        '${ApiConstants().getRestApiUrl('rewards-redemption')}$redemptionId/',
        headers);

    return response;
  }

  static sendRewardRedeemRequest(apiKey, agentId, body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('rewards-redemption')}',
        jsonEncode(body),
        headers);

    return response;
  }

  static markRewardRedemptionFail(orderId, apiKey, agentId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('rewards-redemption')}$orderId/mark-failure/',
        {},
        headers);

    return response;
  }

  static retryRewardRedemptionRequest(orderId, apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    // headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('rewards-redemption')}$orderId/retry-creating-cashgram/',
        {},
        headers);

    return response;
  }
}
