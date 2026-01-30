import 'package:api_sdk/api_collection/app_resources_api.dart';
import 'package:api_sdk/log_util.dart';

class AppResourcesRepository {
  Future<dynamic> getResources({
    required String apiKey,
    required Map<String, dynamic> payload,
    String queryParams = '',
  }) async {
    try {
      final response = await AppResourcesApi.getResources(
        apiKey: apiKey,
        payload: payload,
        queryParams: queryParams,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> addPdfBranding({
    required String pdfUrl,
    required String logoBase64,
  }) async {
    try {
      final response = await AppResourcesApi.addPdfBranding(
        pdfUrl: pdfUrl,
        logoBase64: logoBase64,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('addPdfBranding repository error ==> ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> getCreativeFilters() async {
    try {
      final response = await AppResourcesApi.getCreativeFilters();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }

  Future<dynamic> getWhiteLabelCreative(String whiteLabelUrl) async {
    try {
      final response =
          await AppResourcesApi.getWhiteLabelCreative(whiteLabelUrl);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      return "Something went wrong";
    }
  }
}
