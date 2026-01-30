import 'package:api_sdk/api_collection/client_api.dart';
import 'package:api_sdk/log_util.dart';

class ClientGoalRepository {
  Future<dynamic> createGoalOrder(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.createGoalOrder(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createSwitchOrder(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.createSwitchOrder(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createWithdrawalOrder(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.createWithdrawalOrder(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createStp(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.createStp(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> editStp(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.editStp(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> createSwp(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.createSwp(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> editSwp(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.editSwp(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> markGoalAsCustom(
    String apiKey,
    String userId,
    String goalId,
  ) async {
    try {
      final response = await ClientAPI.markGoalAsCustom(
        apiKey,
        userId,
        goalId,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getStpOrders(
      String apiKey, String clientId, Map<String, dynamic> payload) async {
    try {
      final response = await ClientAPI.getStpOrders(apiKey, clientId, payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateGoal(
    String apiKey,
    String userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.updateGoal(
        apiKey,
        userId,
        payload,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSwpList(
    String apiKey,
    String userId,
    String goalId,
  ) async {
    try {
      final response = await ClientAPI.getSwpList(
        apiKey,
        userId,
        goalId,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getSWPDetails(
    String apiKey,
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ClientAPI.getSWPDetails(
        apiKey,
        clientId,
        payload,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
