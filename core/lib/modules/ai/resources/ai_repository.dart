import 'package:api_sdk/api_collection/ai_api.dart';
import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';

class AIRepository {
  Future<dynamic> getWealthyAiUrl(String apiKey, {String? question}) async {
    try {
      final response = await AIAPI.getWealthyAiUrl(
        apiKey,
        question: question,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getWealthyAiAccessToken(String apiKey) async {
    try {
      final response = await AIAPI.getWealthyAiAccessToken(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getAiResponse(dynamic body) async {
    try {
      final response = await AIAPI.getAiResponse(body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  void setThreadIdAndAccessToken(String threadId, String accessToken) {
    ApiConstants().xThreadId = threadId;
    ApiConstants().xAccessToken = accessToken;
  }

  Future<void> endSession() async {
    try {
      await AIAPI.endSession();
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
