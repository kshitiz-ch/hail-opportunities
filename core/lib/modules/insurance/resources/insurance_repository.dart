import 'dart:convert';

import 'package:api_sdk/api_collection/insurance_api.dart';
import 'package:api_sdk/log_util.dart';

class InsuranceRepository {
  Future<dynamic> sharePolicy(
      String apiKey, Map<String, String> payload) async {
    try {
      final response =
          await InsuranceApi.sharePolicy(apiKey, jsonEncode(payload));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> sendOtp(String apiKey, Map<String, String> payload) async {
    try {
      final response = await InsuranceApi.sendOtp(apiKey, jsonEncode(payload));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> verifyOtp(String apiKey, Map<String, String> payload) async {
    try {
      final response =
          await InsuranceApi.verifyOtp(apiKey, jsonEncode(payload));

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
