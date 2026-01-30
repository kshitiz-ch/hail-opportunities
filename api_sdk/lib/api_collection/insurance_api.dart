import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class InsuranceApi {
  static sharePolicy(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final apiUrl = ApiConstants().getRestApiUrl('share-insurance-policy');
    final response = await RestApiHandlerData.postData(apiUrl, body, headers);
    return response;
  }

  static sendOtp(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final apiUrl = ApiConstants().getRestApiUrl('insurance-send-otp');
    final response = await RestApiHandlerData.postData(apiUrl, body, headers);
    return response;
  }

  static verifyOtp(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final apiUrl = ApiConstants().getRestApiUrl('insurance-verify-otp');
    final response = await RestApiHandlerData.postData(apiUrl, body, headers);
    return response;
  }
}
