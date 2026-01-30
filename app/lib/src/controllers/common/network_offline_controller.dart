import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class NetworkOfflineController extends FullLifeCycleController
    with FullLifeCycleMixin {
  ApiResponse checkNetworkResponse = ApiResponse();
  bool isAppInBackground = false;

  Future<void> checkNetworkConnection() async {
    try {
      checkNetworkResponse.state = NetworkState.loading;
      update();

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        checkNetworkResponse.state = NetworkState.loaded;
      } else {
        checkNetworkResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog(error);
      checkNetworkResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Stream<NetworkState> checkNetworkConnectionStream() async* {
    while (true) {
      // If app is in the background dont check for network connection
      if (isAppInBackground) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          yield NetworkState.loaded;
        } else {
          yield NetworkState.error;
        }
      } catch (error) {
        LogUtil.printLog('error==>${error.toString()}');
        yield NetworkState.error;
      } finally {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void onDetached() {
    isAppInBackground = true;
  }

  @override
  void onHidden() {
    isAppInBackground = true;
  }

  @override
  void onInactive() {
    isAppInBackground = true;
  }

  @override
  void onPaused() {
    isAppInBackground = true;
  }

  @override
  void onResumed() {
    isAppInBackground = false;
  }
}
