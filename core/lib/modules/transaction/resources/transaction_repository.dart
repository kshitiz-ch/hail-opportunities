import 'package:api_sdk/api_collection/transaction_api.dart';
import 'package:api_sdk/log_util.dart';

class TransactionRepository {
  Future<dynamic> getTransactions(
    String? apiKey,
    Map<String, dynamic> payload,
    String type,
  ) async {
    try {
      final response =
          await TransactionAPI.getTransactions(apiKey, payload, type);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
