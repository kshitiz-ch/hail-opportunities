import 'dart:convert';

import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/api_collection/mutual_fund_api.dart';
import 'package:api_sdk/log_util.dart';

class MutualFundsRepository {
  Future<dynamic> getMfGoalSubtype(String apiKey, int subType) async {
    try {
      final response = await MutualFundAPI.getMfGoalSubtype(subType, apiKey);

      return jsonEncode(response.data['taxy']);
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getUserSipData(String apiKey, dynamic body) async {
    final response =
        await MutualFundAPI.getUserSipMeta(json.encode(body), apiKey);

    return response;
  }

  Future<dynamic> getClientProfileData(String apiKey, String userID) async {
    try {
      final response = await CommonAPI.getAccountDetails(apiKey, userID);

      return jsonEncode(response.data['taxy']);
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createBankAccount(
      String apiKey, Map body, String userID) async {
    try {
      final response = await CommonAPI.createBankAccount(apiKey, body, userID);

      LogUtil.printPrettyJsonString(
          tag: 'DataUpdateBank/', jsonString: jsonEncode(response.data));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateBankAccount(
      String apiKey, Map body, String userID) async {
    try {
      final response = await CommonAPI.updateBankAccount(apiKey, body, userID);

      LogUtil.printPrettyJsonString(
          tag: 'DataBankUpdate/', jsonString: jsonEncode(response.data));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
