import 'package:api_sdk/rest/api_helpers/api_base_helper.dart';
import 'package:dio/dio.dart';

class RestApiHandlerData {
  static ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  static getData(
    String path,
    dynamic headers, {
    bool isUTF8 = false,
    bool isPdf = false,
    CancelToken? cancelToken,
    bool retry = true,
  }) async {
    final response = await _apiBaseHelper.get(
      '$path',
      headers,
      isUTF8: isUTF8,
      isPdf: isPdf,
      cancelToken: cancelToken,
      retry: retry,
    );
    return response;
  }

  static postData(
    String path,
    dynamic data,
    dynamic headers, {
    bool isPdf = false,
    CancelToken? cancelToken,
    bool retry = false,
  }) async {
    final response = await _apiBaseHelper.post(
      '$path',
      data,
      headers,
      isPdf: isPdf,
      cancelToken: cancelToken,
      retry: retry,
    );
    return response;
  }

  static putData(String path, dynamic body, dynamic headers) async {
    final response = await _apiBaseHelper.put('$path', body, headers);
    return response;
  }
}
