import 'dart:async';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';

class AppUpdateController extends GetxController {
  String? availableVersion;
  String? currentVersion;
  bool isUpdateAvailable = false;
  AppUpdateInfo? appUpdateInfo;

  final String _androidId = 'in.wealthy.android.advisor';
  final String _iosBundleId = 'in.wealthy.ios.advisor';

  Future<VersionStatus?> checkForUpdate(BuildContext context) async {
    VersionStatus? status;

    try {
      final newVersion = await NewVersionPlus(
        iOSId: _iosBundleId,
        androidId: _androidId,
      );
      status = await newVersion.getVersionStatus();
      if (Platform.isAndroid) {
        appUpdateInfo = await InAppUpdate.checkForUpdate();
        LogUtil.printLog(appUpdateInfo);
        if (appUpdateInfo!.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          isUpdateAvailable = true;
        }
      } else {
        // isUpdateAvailable = status?.canUpdate ?? false;
      }

      availableVersion = status!.storeVersion;
      currentVersion = status.localVersion;
    } catch (error) {
      LogUtil.printLog(error);
    }

    update();

    return status;
  }

  Future updateVersion(BuildContext context) async {
    checkForUpdate(context).then(
      (value) {
        if (value?.canUpdate ?? false) {
          updateApp(context, doFlexibleUpdate: false);
        }
      },
    );
  }
}
