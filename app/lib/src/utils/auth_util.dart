import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

final LocalAuthentication _localAuthentication = LocalAuthentication();

Future<bool> biometricAuthentication(context, {fromAppLoad = false}) async {
  try {
    bool didAuthenticate = false;

    didAuthenticate = await _localAuthentication.authenticate(
      localizedReason: "Please authenticate to continue.",
      options: const AuthenticationOptions(
        biometricOnly: true,
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    return didAuthenticate;
  } on PlatformException catch (e) {
    if (!fromAppLoad) {
      showToast(
        context: context,
        text: 'This security feature is not available',
      );
    }
    LogUtil.printLog('error=> $e');
  } catch (error) {
    if (!fromAppLoad) {
      showToast(
        context: context,
        text: 'This security feature is not available',
      );
    }
  }

  return false;
}

Future<List<BiometricType>> getListOfBiometricTypes() async {
  List<BiometricType> listOfBiometrics;

  try {
    listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
  } catch (error) {
    listOfBiometrics = [];
  }

  return listOfBiometrics;
}
