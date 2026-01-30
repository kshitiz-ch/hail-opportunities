import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:bloc/bloc.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/authentication/models/check_passcode_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:flutter_udid/flutter_udid.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationService =
      AuthenticationRepository();

  String indiaCountryCode = '+91';
  String shouldDisablePasscodeKey = "shouldDisablePasscode";
  String? appReleaseNotes;

  bool hasSplashAnimationViewed = false;
  bool? showFestiveAssets = false;

  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<CheckForUpdate>(_checkForUpdate);
    on<ResetAuthentication>(
      (event, emit) => emit(ResetAuthenticationState()),
    );
    on<AppLoadedup>(_mapAppSignInLoadedState);
    // on<UserGoogleSignIn>(_mapAppGoogleSignIn);
    on<UserSignInPhoneNumber>(_mapUserSignInPhoneNumberToState);
    on<UserSignIn>(_mapUserSignInToState);
    on<SendOtpEvent>(_sendOTP);
    on<ReSendOtpEvent>(_reSendOTP);
    on<UserLocalAuth>(_handleLocalAuth);
    on<UserForgotPassword>(_handleForgotPassword);
    on<UserLogOut>(_handleLogout);
    on<LoginHalfAgent>(_loginAsHalfAgent);
  }

  Future<void> _handleLogout(
      UserLogOut event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;

    final fcmToken = sharedPreferences.getString('fcmToken') ?? '';
    final apiKey =
        sharedPreferences.getString('agent_communication_token') ?? '';

    deregisterDeviceToken(fcmToken, apiKey);

    _clearSharedPreferenceValues(sharedPreferences);

    // Prevent processing if already in logout state
    if (state is UserLogoutState) {
      return;
    }

    emit(UserLogoutState(showLogoutMessage: event.showLogoutMessage));
  }

  Future<void> _handleForgotPassword(
      UserForgotPassword event, Emitter<AuthenticationState> emit) async {
    try {
      final data = await authenticationService.forgotPassword(event.email);
      LogUtil.printLog(data);

      //final forgotPasswordModel = forgotPasswordModelFromJson(data);
      emit(UserForgotPasswordState(url: ''));
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<void> _handleLocalAuth(
      UserLocalAuth event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;

    sharedPreferences.setString('passcode', event.passcode);
    emit(UserLocalAuthState(passcode: event.passcode));
  }

  Future<void> _reSendOTP(
      ReSendOtpEvent event, Emitter<AuthenticationState> emit) async {
    emit(ReSendingOtpState());
    try {
      final data =
          await authenticationService.signInPhoneNumber(event.phoneNumber);
      if (data['status'] == '200') {
        emit(OtpReSent(message: data["response"]["message"].toString()));
      } else {
        emit(OtpSentError(message: data["response"]["message"].toString()));
      }
    } catch (e) {
      emit(OtpReSentError(message: 'Problem in sending OTP'));
      LogUtil.printLog(e.toString());
    }
  }

  Future<void> _sendOTP(
      SendOtpEvent event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;

    emit(SendingOtpState());
    try {
      final data = await authenticationService
          .signInPhoneNumber('($indiaCountryCode)${event.phoneNumber}');
      if (data['status'] == '200') {
        await sharedPreferences.setString("signInPhone", event.phoneNumber);
        emit(OtpSent(message: data["response"]["message"].toString()));
      } else {
        emit(OtpSentError(message: data["response"]["message"].toString()));
      }
    } catch (e) {
      emit(OtpSentError(message: 'Problem in sending OTP'));
      LogUtil.printLog(e.toString());
    }
  }

  Future<void> _checkForUpdate(
      CheckForUpdate event, Emitter<AuthenticationState> emit) async {
    try {
      final SharedPreferences sharedPreferences = await prefs;

      DateTime now = new DateTime.now();
      DateTime diwaliAssetDueDate = DateTime(2024, 11, 10);

      showFestiveAssets = now.isBefore(diwaliAssetDueDate);

      hasSplashAnimationViewed =
          sharedPreferences.getBool("splash_animation_viewed") ?? false;

      emit(AppUpdateResetState());

      await _fetchInitApp();

      final minAppVersion = sharedPreferences.getString("min_app_version");

      bool updateAvailable = false;
      if (Platform.isAndroid) {
        AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
        updateAvailable = appUpdateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable;
      } else {
        final String _androidId = 'in.wealthy.android.advisor';
        final String _iosBundleId = 'in.wealthy.ios.advisor';
        final newVersion = await NewVersionPlus(
          iOSId: _iosBundleId,
          androidId: _androidId,
        );
        final status = await newVersion.getVersionStatus();
        updateAvailable = status?.canUpdate ?? false;
      }

      if (updateAvailable) {
        bool shouldForceUpdate = await checkForceUpdateStatus();
        if (shouldForceUpdate == false && minAppVersion.isNotNullOrEmpty) {
          shouldForceUpdate = await checkAppOutdated(minAppVersion!);
        }

        emit(AppUpdateAvailableState(
            shouldForceUpdate: shouldForceUpdate,
            releaseNotes: appReleaseNotes));
      } else {
        emit(AppUpdateNotAvailableState());
      }
    } catch (error) {
      emit(AppUpdateNotAvailableState());
    }
  }

  Future<bool> checkAppOutdated(String minAppVersion) async {
    try {
      final currentAppVersionList = (await PackageInfo.fromPlatform())
          .version
          .split('.')
          .map((subVersion) => WealthyCast.toInt(subVersion) ?? 0)
          .toList();
      final minAppVersionList = minAppVersion
          .split('.')
          .map((subVersion) => WealthyCast.toInt(subVersion) ?? 0)
          .toList();
      final isAppOutdated = currentAppVersionList[0] < minAppVersionList[0] ||
          (currentAppVersionList[0] == minAppVersionList[0] &&
              currentAppVersionList[1] < minAppVersionList[1]) ||
          (currentAppVersionList[0] == minAppVersionList[0] &&
              currentAppVersionList[1] == minAppVersionList[1] &&
              currentAppVersionList[2] < minAppVersionList[2]);
      return isAppOutdated;
    } catch (error) {
      return false;
    }
  }

  Future<void> _mapAppSignInLoadedState(
      AppLoadedup event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final SharedPreferences sharedPreferences = await prefs;
    try {
      if (sharedPreferences.getString('apiKey') != null) {
        verifyAgent();

        try {
          await checkPasscodeAccess();
        } catch (error) {
          LogUtil.printLog(error.toString());
        }

        bool isOnboardingPending =
            sharedPreferences.getBool("onboarding_pending") ?? false;
        if (isOnboardingPending == true) {
          emit(OnboardingPending());
        } else {
          bool shouldDisablePasscode =
              sharedPreferences.getBool(shouldDisablePasscodeKey) ?? false;
          LogUtil.printLog(shouldDisablePasscode.toString());

          if (sharedPreferences.getString('passcode') == null ||
              shouldDisablePasscode) {
            emit(AppAutheticated());
          } else {
            emit(UserLocalAuthState(
                passcode: sharedPreferences.getString('passcode')));
          }
        }
      } else {
        if (sharedPreferences.getBool(shouldDisablePasscodeKey) == null) {
          try {
            await checkPasscodeAccess();
          } catch (error) {
            LogUtil.printLog(error.toString());
          }
        }
        bool? isGuideCompleted = sharedPreferences.getBool('guideCompleted');
        emit(AuthenticationStart(isGuideCompleted: isGuideCompleted));
      }
    } catch (e) {
      emit(AuthenticationFailure(message: e.toString()));
    }
  }

  Future<void> _loginAsHalfAgent(
      LoginHalfAgent event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;

    _clearSharedPreferenceValues(sharedPreferences);

    emit(UserLogoutState(
        showLogoutMessage: false, isLogggingOutForHalfAgent: true));

    await Future.delayed(Duration(seconds: 1));

    sharedPreferences.setString('apiKey', event.apiKey);
    sharedPreferences.setInt('agentId', event.agentId);

    emit(HalfAgentAuthenticated());
  }

  // Future<void> _mapAppGoogleSignIn(
  //     UserGoogleSignIn event, Emitter<AuthenticationState> emit) async {
  //   auth.User? userData;
  //   final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  //   final GoogleSignIn _googleSignIn = GoogleSignIn();
  //   final SharedPreferences sharedPreferences = await prefs;
  //   try {
  //     GoogleSignInAccount googleSignInAccount = (await _googleSignIn.signIn())!;

  //     GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;

  //     auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );
  //     var authResult = await _auth.signInWithCredential(credential);

  //     userData = authResult.user;

  //     assert(!userData!.isAnonymous);

  //     auth.User currentUser = _auth.currentUser!;
  //     assert(userData!.uid == currentUser.uid);

  //     // sharedPreferences.setString('apiKey', null);
  //     sharedPreferences.remove('apiKey');
  //     emit(AppAutheticated());
  //   } catch (e) {
  //     LogUtil.printLog(e.toString());
  //     emit(AuthenticationFailure(message: 'An error occurred'));
  //   }
  // }

  Future<void> _mapUserSignInPhoneNumberToState(
      UserSignInPhoneNumber event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;
    emit(AuthenticationLoading());
    try {
      final data = await authenticationService.signInWithPhoneNumber(
          event.phoneNumber, event.otp);
      if (data["status"] == '200') {
        await sharedPreferences.setString("signInPhone", event.phoneNumber);
        final currentUser = UserDataModel.fromJson(data["response"]);
        sharedPreferences.setString('name', currentUser.agent!.name!);
        // if (currentUser != null) {
        String uuidKey = await _getDeviceUniqueId();
        String appVersion = await _getHeaderInfo();

        final dataSet = await authenticationService.setFCMtoken(
            currentUser.apiKey!,
            json.encode({
              "token": event.fcmToken.toString(),
              "unique_device_id": uuidKey.toString(),
              "email_id": currentUser.agent!.email.toString(),
              "app_version": appVersion.toString(),
            }));
        LogUtil.printLog('set fcm token => $dataSet');
        sharedPreferences.setString('appVersion', appVersion.toString());
        sharedPreferences.setString('fcmToken', event.fcmToken.toString());
        sharedPreferences.setString('apiKey', currentUser.apiKey!);
        sharedPreferences.setInt('agentId', currentUser.agent!.id!);

        verifyAgent();
        var segment = await getSegment(currentUser.apiKey);
        if (segment < 0) {
          emit(OnboardingPending());
        } else {
          emit(AppAutheticated());
        }
      } else {
        emit(AuthenticationNotAuthenticated());
      }
      // } else {
      //   emit(AuthenticationFailure(
      //       message: data["response"]["message"].toString()));
      // }
    } catch (e) {
      LogUtil.printLog(e.toString());
      emit(AuthenticationFailure(message: e.toString()));
    }
  }

  Future<void> _mapUserSignInToState(
      UserSignIn event, Emitter<AuthenticationState> emit) async {
    final SharedPreferences sharedPreferences = await prefs;
    emit(AuthenticationLoading());
    try {
      final data = await authenticationService.signInWithEmailAndPassword(
          event.email, event.password);
      if (data["status"] == '200') {
        await sharedPreferences.setString("signInEmail", event.email);
        final currentUser = UserDataModel.fromJson(data["response"]);
        sharedPreferences.setString('name', currentUser.agent!.name!);
        // if (currentUser != null) {
        String uuidKey = await _getDeviceUniqueId();
        String appVersion = await _getHeaderInfo();

        final dataSet = await authenticationService.setFCMtoken(
          currentUser.apiKey!,
          json.encode(
            {
              "token": event.fcmToken.toString(),
              "unique_device_id": uuidKey.toString(),
              "email_id": currentUser.agent!.email.toString(),
              "app_version": appVersion.toString(),
            },
          ),
        );
        LogUtil.printLog('set fcm token => $dataSet');
        sharedPreferences.setString('appVersion', appVersion.toString());
        sharedPreferences.setString('fcmToken', event.fcmToken.toString());
        sharedPreferences.setString('apiKey', currentUser.apiKey!);
        sharedPreferences.setInt('agentId', currentUser.agent!.id!);
        sharedPreferences.setString(
            'agentExternalId', currentUser.agent!.externalId!);

        verifyAgent();
        var segment = await getSegment(currentUser.apiKey);
        if (segment < 0) {
          emit(OnboardingPending());
        } else {
          emit(AppAutheticated());
        }
      } else {
        emit(AuthenticationNotAuthenticated());
      }
      // } else {
      //   emit(AuthenticationFailure(
      //       message: data["response"]["message"].toString()));
      // }
    } catch (e) {
      LogUtil.printLog(e.toString());
      emit(AuthenticationFailure(message: e.toString()));
    }
  }

  Future<void> checkPasscodeAccess() async {
    final SharedPreferences sharedPreferences = await prefs;
    try {
      PackageInfo packageInfo = await initPackageInfo();
      final data = await authenticationService.checkPasscodeAccess();
      if (data['status'] == "200") {
        CheckPasscodeModel checkPasscode = CheckPasscodeModel.fromJson(
            data["response"][Platform.isIOS ? "ios" : "android"]);

        String? appVersionToDisablePasscode = checkPasscode.appVersion;
        bool? shouldDisablePasscode = checkPasscode.disablePasscode;

        if (appVersionToDisablePasscode == packageInfo.version &&
            shouldDisablePasscode!) {
          await sharedPreferences.setBool(shouldDisablePasscodeKey, true);
        } else {
          await sharedPreferences.setBool(shouldDisablePasscodeKey, false);
        }
      } else {
        await sharedPreferences.setBool(shouldDisablePasscodeKey, false);
      }
    } catch (error) {
      await sharedPreferences.setBool(shouldDisablePasscodeKey, false);
    }
  }

  Future<bool> checkForceUpdateStatus() async {
    bool? shouldForceUpdate = false;

    try {
      final data = await authenticationService.checkForceUpdateStatus();
      if (data['status'] == "200" && data["response"]["os_list"] != null) {
        List osList = data["response"]["os_list"].toList();
        if (osList.contains(Platform.operatingSystem.toLowerCase())) {
          shouldForceUpdate = data["response"]["force_update"];
          appReleaseNotes = data["response"]["release_notes"]
              [Platform.operatingSystem.toLowerCase()];
        }
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }

    return shouldForceUpdate ?? false;
  }

  Future<void> _fetchInitApp() async {
    try {
      final data = await authenticationService.fetchAppInitData();
      if (data['status'] == "200") {
        final SharedPreferences sharedPreferences = await prefs;

        String brochureUrl = data["response"]["brochure"] ?? '';
        sharedPreferences.setString("brochure_url", brochureUrl);

        Map<String, dynamic>? updateDetails =
            data["response"]["update_details"];
        if (updateDetails != null) {
          bool shouldShowNewFeatureDetails =
              updateDetails["show_new_feature_details"] ?? false;

          sharedPreferences.setBool(
              "show_new_feature_details", shouldShowNewFeatureDetails);

          // bool shouldShowNewFeatureDetails =
          //     updateDetails["show_new_feature_details"] ?? false;

          // String newAppVersion = updateDetails["app_version"] ?? '';

          // PackageInfo packageInfo = await initPackageInfo();

          // if (shouldShowNewFeatureDetails &&
          //     newAppVersion == packageInfo.version) {
          //   sharedPreferences.setBool(
          //       "show_new_feature_details", shouldShowNewFeatureDetails);
          // }

          // String? currentAppVersion =
          //     sharedPreferences.getString("current_app_version") ?? '';

          // // If app is updated, then reset new feature viewed flag
          // if (packageInfo.version != currentAppVersion) {
          //   sharedPreferences.setBool("is_new_update_feature_viewed", false);

          //   // Update app version
          //   sharedPreferences.setString(
          //       "current_app_version", packageInfo.version);
          // }
        }

        final minAppVersion =
            WealthyCast.toStr(data["response"]["min_app_version"]) ?? '';
        if (minAppVersion.isNotNullOrEmpty) {
          sharedPreferences.setString("min_app_version", minAppVersion);
        }
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  verifyAgent() async {
    try {
      final SharedPreferences sharedPreferences = await prefs;
      final data = await authenticationService.verifyAgent(
        sharedPreferences.getString('apiKey')!,
        {"agent_id": sharedPreferences.getInt('agentId').toString()},
      );
      LogUtil.printLog('verify=> $data');
    } catch (error) {
      LogUtil.printLog('verifyAgent==>${error.toString()}');
    }
  }

  getSegment(apiKey) async {
    final AdvisorOverviewRepository advisorOverviewRepository =
        AdvisorOverviewRepository();
    int? segment = 0;
    try {
      var response = await advisorOverviewRepository.getAgentSegment(apiKey);
      if (response.exception == null) {
        var agentDetails = AgentModel.fromJson(response.data['hydra']['agent']);
        segment = agentDetails.segment;
      }
    } catch (error) {
      LogUtil.printLog("Something went wrong");
    }
    return segment;
  }

  Future<String> _getDeviceUniqueId() async {
    return await FlutterUdid.udid;
  }

  static Future<PackageInfo> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info;
  }

  Future<String> _getHeaderInfo() async {
    PackageInfo packageInfo = await initPackageInfo();
    if (Platform.isAndroid) {
      return 'android ${packageInfo.version}';
    } else {
      return 'ios ${packageInfo.version}';
    }
  }

  _clearSharedPreferenceValues(SharedPreferences sharedPreferences) {
    sharedPreferences.remove("apiKey");
    sharedPreferences.remove("fcmToken");
    sharedPreferences.remove("agentId");
    sharedPreferences.remove("name");
    sharedPreferences.remove("agentKycStatus");
    sharedPreferences.remove("agentExternalId");
    sharedPreferences.remove("sales_plan_type");
    sharedPreferences.remove("onboarding_pending");
    sharedPreferences.remove("financial_experience");
    sharedPreferences.remove("passcode");
    sharedPreferences.remove(shouldDisablePasscodeKey);
    sharedPreferences.remove("agent_communication_token");
  }

  void deregisterDeviceToken(String deviceToken, String apiKey) async {
    try {
      final payload = <String, dynamic>{'device_token': deviceToken};

      AuthenticationRepository().deregisterDeviceToken(payload, apiKey);
    } catch (e) {
      LogUtil.printLog(e.toString(), tag: 'deregisterDeviceToken');
    }
  }
}
