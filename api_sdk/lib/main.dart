import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/rest/api_helpers/firebase_performance_dio.dart';
import 'package:api_sdk/rest/api_helpers/pretty_dio_logger.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiSdk {
  static Future<PackageInfo> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info;
  }

  static dynamic getHeaderInfo(String? apiKey) async {
    try {
      // potential issue fix
      // in some controller we are using global apikey variable in function call
      // which is initialise at init or onready
      // if for any reason function call is triggered
      // without completion of init or onready
      // it will give unauthorised error & logout automatically
      if (apiKey != null && apiKey.trim().isEmpty) {
        apiKey = (await SharedPreferences.getInstance()).getString('apiKey');
      }
    } catch (e) {}

    PackageInfo packageInfo = await initPackageInfo();
    dynamic headers = {};
    if (Platform.isAndroid) {
      if (apiKey == null) {
        headers = {
          'X-APP-VERSION': 'android-v${packageInfo.version}',
        };
      } else {
        headers = {
          'X-APP-VERSION': 'android-v${packageInfo.version}',
          'Authorization': apiKey,
        };
      }
    } else if (Platform.isIOS) {
      if (apiKey == null) {
        headers = {
          'X-APP-VERSION': 'ios-v${packageInfo.version}',
        };
      } else {
        headers = {
          'X-APP-VERSION': 'ios-v${packageInfo.version}',
          'Authorization': apiKey,
        };
      }
    }
    return headers;
  }

  static Dio createDioClient({
    bool addRetry = false,
    String? certificate,
    String? certificateKey,
  }) {
    /// The default request encoder is [Utf8Encoder]
    final dioClient = Dio(BaseOptions(
      validateStatus: (status) {
        // if not success ==> invalid ==> dio throws error => handled by RetryInterceptor
        final isSuccess = status != null && (status ~/ 100) == 2;
        return isSuccess;
      },
    ));

    dioClient.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
        maxWidth: 120,
        logPrint: (val) {
          LogUtil.printLog('$val', tag: 'PrettyDioLogger');
        },
        filter: (options, args) {
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );

    dioClient.interceptors.add(DioFirebasePerformanceInterceptor());

    if (addRetry) {
      dioClient.interceptors.add(
        RetryInterceptor(
          logPrint: (val) {
            LogUtil.printLog('$val', tag: 'RetryInterceptor');
          },
          dio: dioClient,
          retryEvaluator: (error, attempt) {
            // if its cancelled
            // dont retry already implemented in RetryInterceptor

            // retry if its not 2XX
            final isSuccess = error.response?.statusCode != null &&
                (error.response!.statusCode! ~/ 100) == 2;
            return !isSuccess;
          },
          retries: 2,
          retryDelays: const [
            Duration(seconds: 1), // wait 1 sec before first retry
            Duration(seconds: 1), // wait 1 sec before second retry
          ],
        ),
      );
    }

    if (certificate != null && certificateKey != null) {
      dioClient.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final context = SecurityContext.defaultContext;
          // modify context as needed
          context.useCertificateChainBytes(utf8.encode(certificate));
          context.usePrivateKeyBytes(utf8.encode(certificateKey));
          final httpClient = HttpClient(context: context);
          return httpClient;
        },
      );
    }

    return dioClient;
  }

  static dynamic getFormattedResponse(
    Response? response, {
    bool isUTF8 = false,
    bool isPdf = false,
    bool isRequestCancelled = false,
  }) {
    // if request is cancelled ui shouldn't get updated to error state

    if (isRequestCancelled || response == null) {
      return {'isRequestCancelled': isRequestCancelled};
    }

    switch (response.statusCode) {
      case 200:
        return {
          'status': response.statusCode.toString(),
          "response": response.data,
          'isRequestCancelled': isRequestCancelled
        };
      case 400:
        return {
          'status': response.statusCode.toString(),
          "response":
              isPdf ? json.decode(utf8.decode(response.data)) : response.data,
          'isRequestCancelled': isRequestCancelled
        };
      case 401:
      case 403:
        return {
          'status': response.statusCode.toString(),
          "response":
              isPdf ? json.decode(utf8.decode(response.data)) : response.data,
          'isRequestCancelled': isRequestCancelled
        };
      case 500:
      default:
        return {
          'status': response.statusCode.toString(),
          "response":
              isPdf ? json.decode(utf8.decode(response.data)) : response.data,
          'isRequestCancelled': isRequestCancelled
        };
    }
  }
}
