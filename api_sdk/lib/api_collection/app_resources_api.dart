import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class AppResourcesApi {
  static getResources({
    required String apiKey,
    required Map<String, dynamic> payload,
    String queryParams = '',
  }) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";

    try {
      String apiUrl =
          '${ApiConstants().getRestApiUrl('tag-master')}$queryParams';

      final response = await RestApiHandlerData.postData(
        apiUrl,
        json.encode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  /// Adds branding to a PDF by sending the PDF URL and logo base64
  static addPdfBranding({
    required String pdfUrl,
    required String logoBase64,
  }) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(null);
      headers['content-type'] = "application/json";

      final apiUrl = ApiConstants().getRestApiUrl('pdf-branding');

      final Map<String, dynamic> payload = {
        "pdfUrl": pdfUrl,
        "logoBase64": logoBase64,
      };

      final response = await RestApiHandlerData.postData(
        apiUrl,
        json.encode(payload),
        headers,
        isPdf: true,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('addPdfBranding error ==> ${e.toString()}');
    }
  }

  static getWhiteLabelCreative(String whiteLabelUrl) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response =
          await RestApiHandlerData.getData(whiteLabelUrl, headers, isPdf: true);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getCreativeFilters() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/tags', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }
}
