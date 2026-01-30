import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  late AuthenticationRepository authenticationService;
  late AdvisorOverviewRepository advisorOverviewRepository;
  UserDataModel? userDataModel;
  late SharedPreferences sharedPreferences;
  GlobalKey<FormState>? phoneFormKey;
  GlobalKey<FormState>? emailFormKey;

  TextEditingController? passwordController;
  TextEditingController? phoneController;
  TextEditingController? loginIDController;
  TextEditingController? otpInputController;
  String? countryCode = indiaCountryCode;

  ApiResponse verifySignInOtpResponse = ApiResponse();
  ApiResponse signInWithEmailAndPasswordResponse = ApiResponse();
  ApiResponse signInPhoneNumberResponse = ApiResponse();

  // for existing users
  SignUpModel? signUpModel;

  int? agentSegment;
  String? agentPhoneNumber;
  OnboardingQuestionOverviewModel? onboardingQuestionsList;
  List<String> cities = [];

  LoginController() {
    authenticationService = AuthenticationRepository();
    advisorOverviewRepository = AdvisorOverviewRepository();

    emailFormKey = GlobalKey<FormState>();
    phoneFormKey = GlobalKey<FormState>();

    otpInputController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    loginIDController = TextEditingController();
  }

  @override
  void onInit() async {
    sharedPreferences = await prefs;

    super.onInit();
  }

  @override
  void dispose() {
    passwordController!.dispose();
    loginIDController!.dispose();
    phoneController!.dispose();
    super.dispose();
  }

  Future<void> verifySignInOtp(String? fcmToken) async {
    verifySignInOtpResponse.state = NetworkState.loading;
    update();
    try {
      var data = await authenticationService.signInWithPhoneNumber(
          '($countryCode)${phoneController!.text}', otpInputController!.text);
      if (data['status'] != "400") {
        userDataModel = UserDataModel.fromJson(data["response"]);
        sharedPreferences.setString('name', userDataModel!.agent!.name!);

        if (userDataModel != null) {
          String uuidKey = await getDeviceUniqueId();
          String appVersion = await getAppVersion();

          LogUtil.printLog("set fcm start ===> ${DateTime.now()}");
          authenticationService.setFCMtoken(
            userDataModel!.apiKey!,
            json.encode(
              {
                "token": fcmToken.toString(),
                "unique_device_id": uuidKey.toString(),
                "email_id": userDataModel?.agent?.email.toString(),
                "app_version": appVersion.toString(),
              },
            ),
          );

          LogUtil.printLog("set fcm end ===> ${DateTime.now()}");
          // LogUtil.printLog('set fcm token => $dataSet');
          //todo add to shared preference key
          sharedPreferences.setString('appVersion', appVersion.toString());
          sharedPreferences.setString('fcmToken', fcmToken.toString());
          sharedPreferences.setString('apiKey', userDataModel!.apiKey!);
          sharedPreferences.setInt('agentId', userDataModel?.agent?.id ?? 0);
          sharedPreferences.setString(
              'agentExternalId', userDataModel?.agent?.externalId ?? '');
          sharedPreferences.setBool(SharedPreferencesKeys.hideRevenue,
              userDataModel?.agent?.hideRevenue == true);
          MixPanelAnalytics.identify(userDataModel?.agent?.externalId ?? '',
              email: userDataModel?.agent?.email);
          // BlitzllamaFlutter.createUser(userDataModel?.agent?.externalId ?? '');
          // try {
          //   AppsflyerSDK.setCustomerUserId(userDataModel?.agent?.externalId);
          //   AppsflyerSDK.setUninstallToken(fcmToken);
          // } catch (error) {
          //   LogUtil.printLog(error);
          // }

          await getOnboardingQuestions();

          // verify agent
          verifyAgent();
          // register device token
          CommonController.registerDeviceToken(
            deviceToken: fcmToken ?? '',
            loginType: 'phone',
          );

          agentSegment = await getSegment(userDataModel!.apiKey!);

          verifySignInOtpResponse.state = NetworkState.loaded;
        } else {
          verifySignInOtpResponse.state = NetworkState.error;
          verifySignInOtpResponse.message =
              "failed to authenticate please try again";
        }
      } else {
        verifySignInOtpResponse.state = NetworkState.error;
        verifySignInOtpResponse.message =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      verifySignInOtpResponse.state = NetworkState.error;
      verifySignInOtpResponse.message =
          "failed to authenticate please try again";
    } finally {
      update([GetxId.verifySignInOtp]);
    }
  }

  Future<void> signInPhoneNumber() async {
    try {
      signInPhoneNumberResponse.state = NetworkState.loading;
      update([GetxId.signInPhoneNumber]);

      var data = await authenticationService
          .signInPhoneNumber('($countryCode)${phoneController!.text}');
      if (data['status'] != "400") {
        await sharedPreferences.setString("signInPhone", phoneController!.text);
        await sharedPreferences.setString("countryCode", countryCode!);
        signInPhoneNumberResponse.message =
            data['response']['message'] ?? "OTP Resent";
        signInPhoneNumberResponse.state = NetworkState.loaded;
        agentPhoneNumber = '($countryCode)${phoneController!.text}';
      } else {
        signInPhoneNumberResponse.state = NetworkState.error;
        signInPhoneNumberResponse.message =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      signInPhoneNumberResponse.state = NetworkState.error;
      signInPhoneNumberResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.signInPhoneNumber]);
    }
  }

  void verifyAgent() async {
    try {
      final data = await authenticationService.verifyAgent(
        sharedPreferences.getString('apiKey')!,
        {"agent_id": sharedPreferences.getInt('agentId').toString()},
      );
      LogUtil.printLog('verify=> $data');
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<int?> getSegment(String apiKey) async {
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

  Future<void> signInWithEmailAndPassword({String? fcmToken}) async {
    try {
      signInWithEmailAndPasswordResponse.state = NetworkState.loading;
      update([GetxId.signInWithEmailAndPassword]);
      final data = await authenticationService.signInWithEmailAndPassword(
        loginIDController!.text.trim(),
        passwordController!.text,
      );
      LogUtil.printLog('data=> $data');
      if (data["status"] == '200') {
        await sharedPreferences.setString(
            "signInEmail", loginIDController!.text.trim());
        userDataModel = UserDataModel.fromJson(data["response"]);
        sharedPreferences.setString('name', userDataModel!.agent!.name!);
        if (userDataModel != null) {
          String uuidKey = await getDeviceUniqueId();
          String appVersion = await getAppVersion();

          authenticationService.setFCMtoken(
            userDataModel!.apiKey!,
            json.encode(
              {
                "token": fcmToken.toString(),
                "unique_device_id": uuidKey.toString(),
                "email_id": userDataModel!.agent!.email.toString(),
                "app_version": appVersion.toString(),
              },
            ),
          );
          // LogUtil.printLog('set fcm token => $dataSet');
          sharedPreferences.setString('appVersion', appVersion.toString());
          sharedPreferences.setString('fcmToken', fcmToken.toString());
          sharedPreferences.setString('apiKey', userDataModel!.apiKey!);
          sharedPreferences.setInt('agentId', userDataModel!.agent!.id!);
          sharedPreferences.setString(
              'agentExternalId', userDataModel!.agent!.externalId!);
          // BlitzllamaFlutter.createUser(userDataModel?.agent?.externalId ?? '');
          sharedPreferences.setBool(SharedPreferencesKeys.hideRevenue,
              userDataModel?.agent?.hideRevenue == true);
          MixPanelAnalytics.identify(userDataModel?.agent?.externalId ?? '',
              email: userDataModel?.agent?.email);
          await getOnboardingQuestions();

          // verify agent
          verifyAgent();
          // register device token
          CommonController.registerDeviceToken(
            deviceToken: fcmToken ?? '',
            loginType: 'email',
            email: loginIDController!.text.trim(),
          );

          agentSegment = await getSegment(userDataModel!.apiKey!);
          signInWithEmailAndPasswordResponse.state = NetworkState.loaded;
        } else {
          signInWithEmailAndPasswordResponse.message = 'User not found';
          signInWithEmailAndPasswordResponse.state = NetworkState.error;
        }
      } else {
        signInWithEmailAndPasswordResponse.state = NetworkState.error;

        signInWithEmailAndPasswordResponse.message =
            getErrorMessageFromResponse(data["response"]);
      }
    } catch (e) {
      signInWithEmailAndPasswordResponse.state = NetworkState.error;
      signInWithEmailAndPasswordResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.signInWithEmailAndPassword]);
    }
  }

  void resetOtp() {
    otpInputController!.text = '';
  }

  // TODO: Move this to onboarding controller
  Future<void> getOnboardingQuestions() async {
    try {
      String apiKey = (await getApiKey())!;
      var data = await authenticationService.getOnboardingQuestionsv2(apiKey);

      if (data['status'] == '200') {
        onboardingQuestionsList =
            OnboardingQuestionOverviewModel.fromJson(data['response']);

        if (onboardingQuestionsList?.questions?.isNotEmpty ?? false) {
          await sharedPreferences.setBool("onboarding_pending", true);
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }

  Future<void> getCities() async {
    try {
      String apiKey = (await getApiKey())!;
      var data = await authenticationService.getCities(apiKey);
      if (data['status'] == '200') {
        cities = List<String>.from(data['response']['cities']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }
}
