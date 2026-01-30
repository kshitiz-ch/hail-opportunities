import 'dart:io';

import 'package:api_sdk/main.dart';
import 'package:dio/dio.dart';

import 'api_exception.dart';

class CertifiedApiBaseHelper {
  late Dio dioClient;
  late Dio dioRetryClient;

  CertifiedApiBaseHelper(String certificate, String certificateKey) {
    dioClient = ApiSdk.createDioClient(
      certificate: certificate,
      certificateKey: certificateKey,
      addRetry: false,
    );
    dioRetryClient = ApiSdk.createDioClient(
      certificate: certificate,
      certificateKey: certificateKey,
      addRetry: true,
    );

    /// DioException is thrown if dioClient validateStatus is false
  }

  Dio getDioClient(bool retry) => retry ? dioRetryClient : dioClient;

  Future<dynamic> get(
    String url,
    dynamic headers, {
    bool isUTF8 = false,
    bool retry = false,
  }) async {
    Response<dynamic>? apiResponse;

    try {
      apiResponse = await getDioClient(retry).get(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException && e.response != null) {
        apiResponse = e.response!;
      }
    } finally {
      return _returnResponse(apiResponse, isUTF8: isUTF8);
    }
  }

  Future<dynamic> post(
    String url,
    dynamic data,
    dynamic headers, {
    bool retry = false,
  }) async {
    Response<dynamic>? apiResponse;

    try {
      apiResponse = await getDioClient(retry).post(
        url,
        data: data,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException && e.response != null) {
        apiResponse = e.response;
      }
    } finally {
      return _returnResponse(apiResponse);
    }
  }

  Future<dynamic> put(
    String url,
    dynamic body,
    dynamic headers, {
    bool retry = false,
  }) async {
    Response<dynamic>? apiResponse;

    try {
      apiResponse = await getDioClient(retry).put(
        url,
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException && e.response != null) {
        apiResponse = e.response;
      }
    } finally {
      return _returnResponse(apiResponse);
    }
  }

  Future<dynamic> delete(
    String url, {
    bool retry = false,
  }) async {
    Response<dynamic>? apiResponse;

    try {
      apiResponse = await getDioClient(retry).delete(url);
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException && e.response != null) {
        apiResponse = e.response;
      }
    } finally {
      return _returnResponse(apiResponse);
    }
  }
}

dynamic _returnResponse(Response? response, {bool isUTF8 = false}) {
  if (response == null) {
    return {};
  }
  return {'status': response.statusCode.toString(), "response": response.data};
}
