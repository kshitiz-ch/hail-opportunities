import 'package:api_sdk/api_collection/my_business_api.dart';
import 'package:api_sdk/log_util.dart';

class MyBusinessRepository {
  Future<dynamic> getPartnerTotalAum(
    String apiKey,
    List<String> agentExternalIdList,
  ) async {
    try {
      final response = await MyBusinessAPI.getPartnerTotalAum(
        apiKey,
        agentExternalIdList,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerMfMetrics(
    String apiKey,
    List<String> agentExternalIdList,
    String date,
  ) async {
    try {
      final response = await MyBusinessAPI.getPartnerMfMetrics(
        apiKey,
        agentExternalIdList,
        date,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getPartnerClientMetrics(
    String apiKey,
    List<String> agentExternalIdList,
  ) async {
    try {
      final response = await MyBusinessAPI.getPartnerClientMetrics(
        apiKey,
        agentExternalIdList,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
