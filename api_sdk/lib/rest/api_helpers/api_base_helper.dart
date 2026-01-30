import 'dart:io';

import 'package:api_sdk/main.dart';
import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiBaseHelper {
  late Dio dioClient;
  late Dio dioRetryClient;

  ApiBaseHelper() {
    dioClient = ApiSdk.createDioClient();
    dioRetryClient = ApiSdk.createDioClient(addRetry: true);

    /// DioException is thrown if dioClient validateStatus is false
  }

  Dio getDioClient(bool retry) => retry ? dioRetryClient : dioClient;

  // To use cancelToken
  // initialise cancelToken x in controller and pass it down here
  // to cancel old api call as new same api call is to triggered
  // use x.cancel() first in controller
  // then repeat same steps
  // initialisation of new cancelToken in x and passing it down here

  Future<dynamic> get(
    String url,
    dynamic headers, {
    bool isUTF8 = false,
    bool isPdf = false,
    CancelToken? cancelToken,
    bool retry = true,
  }) async {
    Response<dynamic>? apiResponse;
    bool isRequestCancelled = false;

    try {
      apiResponse = await getDioClient(retry).get(
        url,
        options: Options(
          headers: headers,
          responseType: isPdf ? ResponseType.bytes : ResponseType.json,
        ),
        cancelToken: cancelToken,
      );
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException) {
        apiResponse = e.response;
        if (e.type == DioExceptionType.cancel) {
          isRequestCancelled = true;
        }
      }
    } finally {
      return ApiSdk.getFormattedResponse(
        apiResponse,
        isUTF8: isUTF8,
        isPdf: isPdf,
        isRequestCancelled: isRequestCancelled,
      );
    }
  }

  Future<dynamic> post(
    String url,
    dynamic data,
    dynamic headers, {
    bool isPdf = false,
    CancelToken? cancelToken,
    bool retry = false,
  }) async {
    Response<dynamic>? apiResponse;
    bool isRequestCancelled = false;

    try {
      apiResponse = await getDioClient(retry).post(
        url,
        data: data,
        options: Options(
          headers: headers,
          responseType: isPdf ? ResponseType.bytes : ResponseType.json,
        ),
        cancelToken: cancelToken,
      );
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('No Internet connection');
      }
      if (e is DioException) {
        apiResponse = e.response;
        if (e.type == DioExceptionType.cancel) {
          isRequestCancelled = true;
        }
      }
    } finally {
      return ApiSdk.getFormattedResponse(
        apiResponse,
        isPdf: isPdf,
        isRequestCancelled: isRequestCancelled,
      );
    }
  }

  Future<dynamic> put(
    String url,
    dynamic body,
    dynamic headers, {
    bool retry = true,
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
      return ApiSdk.getFormattedResponse(apiResponse);
    }
  }

  Future<dynamic> delete(
    String url, {
    bool retry = true,
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
      return ApiSdk.getFormattedResponse(apiResponse);
    }
  }
}
