import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/auth.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/utils/push_notifications.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController {
  AdvisorOverviewRepository? advisorOverviewRepository;
  late SharedPreferences sharedPreferences;
  GlobalKey<FormState>? phoneFormKey;
  GlobalKey<FormState>? detailFormKey;

  String? countryCode = indiaCountryCode;
  late AuthenticationRepository authenticationService;
  late SignUpModel signUpModel;
  late UserDataModel userDataModel;
  String? agentPhoneNumber;
  String? agentFullName;

  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? emailController;
  TextEditingController? inviteCodeController;
  TextEditingController? phoneController;
  TextEditingController? otpInputController;

  ApiResponse registerPhoneResponse = ApiResponse();
  ApiResponse registerDetailsResponse = ApiResponse();
  ApiResponse validateReferralCodeResponse = ApiResponse();
  ApiResponse verifySignupOtpResponse = ApiResponse();
  ApiResponse resendOtpResponse = ApiResponse();

  String? signupErrorCode;
  // CPTREQ00 -> Catcha required error
  // INVALID_CAPTCHA = "INVCAP00"
  // CONFLC00 -> conflict resolution error
  String? signupWebViewRedirectUrl;

  bool isOnboardingQuestionsAvailable = false;

  RegisterController() {
    authenticationService = AuthenticationRepository();
    advisorOverviewRepository = AdvisorOverviewRepository();
  }

  @override
  void onInit() async {
    sharedPreferences = await prefs;

    phoneFormKey = GlobalKey<FormState>();
    detailFormKey = GlobalKey<FormState>();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    otpInputController = TextEditingController();
    inviteCodeController = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    firstNameController!.dispose();
    lastNameController!.dispose();
    phoneController!.dispose();
    emailController?.dispose();
    inviteCodeController!.dispose();
    super.dispose();
  }

  Future<void> signUp({String? captchaToken}) async {
    try {
      registerPhoneResponse.state = NetworkState.loading;
      update([GetxId.registerPhone]);
      agentPhoneNumber = '($countryCode)${phoneController!.text}';
      agentFullName = firstNameController!.text.trim() +
          ' ' +
          lastNameController!.text.trim();

      String? referralCode;
      if (validateReferralCodeResponse.state == NetworkState.loaded) {
        referralCode = inviteCodeController?.text.toLowerCase();
      } else if ((inviteCodeController?.text ?? '').isNotNullOrEmpty) {
        await validateReferralCode();
        if (validateReferralCodeResponse.state == NetworkState.loaded) {
          referralCode = inviteCodeController?.text.toLowerCase();
        } else {
          registerPhoneResponse.state = NetworkState.cancel;
          return;
        }
      }

      Map<String, dynamic> queryParams = await getReferralDetails();

      var data = await authenticationService.signUp(
        firstNameController!.text.trim(),
        lastNameController!.text.trim(),
        '($countryCode)${phoneController!.text}',
        referralCode: referralCode,
        // captchaToken: captchaToken,
        queryParams: queryParams,
        emailID: (emailController?.text ?? '').trim(),
      );

      if (data['status'] != "400") {
        signUpModel = SignUpModel.fromJson(data['response']);
        await sharedPreferences.remove("passcode");
        await sharedPreferences.setBool(
            SharedPreferencesKeys.isReferralDetailsUsed, true);
        registerPhoneResponse.state = NetworkState.loaded;
      } else {
        registerPhoneResponse.message =
            getErrorMessageFromResponse(data['response']);

        // Get Error Code for captcha
        try {
          signupErrorCode = data['response']['error_code'];
        } catch (error) {
          LogUtil.printLog("error ==> ${error.toString()}");
        }

        // get signup web view redirect url
        try {
          signupWebViewRedirectUrl = data['response']['redirect_url'];
        } catch (error) {
          LogUtil.printLog("error ==> ${error.toString()}");
        }

        registerPhoneResponse.state = NetworkState.error;
      }
    } catch (error) {
      registerPhoneResponse.message = genericErrorMessage;
      registerPhoneResponse.state = NetworkState.error;
    } finally {
      update([GetxId.registerPhone]);
    }
  }

  Future<String?> getCaptchaKey() async {
    String? captchaKey;
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate();
      captchaKey = remoteConfig.getString("captcha_key_android");
    } catch (error) {
      LogUtil.printLog(error);
    }
    return captchaKey;
  }

  Future<void> validateReferralCode() async {
    final referralCode = inviteCodeController?.text.toUpperCase() ?? '';

    if (referralCode.isNullOrEmpty) {
      validateReferralCodeResponse.message = 'Please enter a referral code';
      validateReferralCodeResponse.state = NetworkState.error;
      _resetReferralCodeState();
      update();
      return;
    }

    try {
      validateReferralCodeResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey() ?? '';
      final data = await authenticationService.validateReferralCode(
        referralCode,
        apiKey,
      );
      if (data["status"] == '200') {
        validateReferralCodeResponse.message =
            data["response"]["message"] ?? 'Invite code applied succesfully!';
        validateReferralCodeResponse.state = NetworkState.loaded;
      } else if (data["status"] == '400') {
        validateReferralCodeResponse.message = data["response"]["message"] ??
            'Invalid referral code. Please try again';
        validateReferralCodeResponse.state = NetworkState.error;
        _resetReferralCodeState();
      } else {
        validateReferralCodeResponse.state = NetworkState.error;
        validateReferralCodeResponse.message =
            getErrorMessageFromResponse(data["response"]);
        _resetReferralCodeState();
      }
    } catch (e) {
      validateReferralCodeResponse.state = NetworkState.error;
      validateReferralCodeResponse.message = genericErrorMessage;
      _resetReferralCodeState();
    } finally {
      update();
    }
  }

  void _resetReferralCodeState() {
    Future.delayed(Duration(seconds: 2), () {
      validateReferralCodeResponse.state = NetworkState.cancel;
      update();
    });
  }

  Future<void> registerDetails(
      String firstName, String lastName, String email) async {
    //TODO: update code once register detail & register phone api is ready

    // try {
    //   isRegisterDetailForm = true;
    //   registerDetailsResponse.state = NetworkState.loading;
    //   update([GetxId.registerDetails]);
    //   agentFullName = '$firstName $lastName';
    //   final isValidEmail = email.isNotNullOrEmpty;
    //   var data = await authenticationService.signUp(
    //       firstName, lastName, '($indiaCountryCode)$phoneNumber',
    //       emailID: isValidEmail ? email : null);

    //   if (data['status'] != "400") {
    //     signUpResponse = data['response'];
    //     await sharedPreferences.remove("passcode");
    //     if (data['response']['existing']) {
    //       isSignUpAgentExists = true;
    //       isRegisterDetailForm = false;
    //     } else {
    //       isSignUpAgentExists = false;
    //     }
    //     registerDetailsResponse.state = NetworkState.loaded;
    //   } else {
    //     registerDetailsResponse.errorMessage =
    //         getErrorMessageFromResponse(data['response']) ??
    //             genericErrorMessage;
    //     registerDetailsResponse.state = NetworkState.error;
    //   }
    // } catch (error) {
    //   registerDetailsResponse.errorMessage =
    //       error?.toString() ?? genericErrorMessage;
    //   registerDetailsResponse.state = NetworkState.error;
    // } finally {
    //   update([GetxId.registerDetails]);
    // }
  }

  Future<void> verifySignupOtp() async {
    try {
      verifySignupOtpResponse.state = NetworkState.loading;
      update();

      await Future.delayed(Duration(seconds: 5));

      var data = await authenticationService.verifySignUp(
          signUpModel.leadId!, otpInputController!.text);

      if (data['status'] != "400") {
        userDataModel = UserDataModel.fromJson(data['response']);
        sharedPreferences.setString('apiKey', userDataModel.apiKey!);
        sharedPreferences.setInt('agentId', userDataModel.agent!.id!);
        sharedPreferences.setBool(SharedPreferencesKeys.hideRevenue,
            userDataModel.agent?.hideRevenue == true);

        try {
          sharedPreferences.setString(
              'agentExternalId', userDataModel.agent!.externalId!);
          MixPanelAnalytics.identify(userDataModel.agent?.externalId ?? '',
              email: userDataModel.agent?.email);
          // BlitzllamaFlutter.createUser(userDataModel.agent?.externalId ?? '');
          // AppsflyerSDK.setCustomerUserId(userDataModel.agent!.externalId);
        } catch (error) {
          LogUtil.printLog(error);
        }

        String uuidKey = await getDeviceUniqueId();
        String appVersion = await getAppVersion();

        String? token = await PushNotificationsManager().init();

        // try {
        //   AppsflyerSDK.setUninstallToken(token);
        // } catch (error) {
        //   LogUtil.printLog(error);
        // }

        authenticationService.setFCMtoken(
          data['response']['api_key'],
          json.encode(
            {
              "token": token.toString(),
              "unique_device_id": uuidKey.toString(),
              "email_id": userDataModel.agent!.email.toString(),
              "app_version": appVersion.toString(),
            },
          ),
        );

        sharedPreferences.setString('appVersion', appVersion.toString());
        sharedPreferences.setString('fcmToken', token.toString());

        verifySignupOtpResponse.state = NetworkState.loaded;

        // register device token
        CommonController.registerDeviceToken(
          deviceToken: token.toString(),
          loginType: 'signup',
        );

        await getOnboardingQuestions();
      } else {
        verifySignupOtpResponse.state = NetworkState.error;
        verifySignupOtpResponse.message =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      verifySignupOtpResponse.state = NetworkState.error;
      verifySignupOtpResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> resendOtp() async {
    try {
      resendOtpResponse.state = NetworkState.loading;
      update();

      var data =
          await authenticationService.resendSignUpOtp(signUpModel.leadId!);

      if (data['status'] != "400") {
        resendOtpResponse.message = data['response']['message'] ?? "OTP Resent";
        resendOtpResponse.state = NetworkState.loaded;
      } else {
        resendOtpResponse.state = NetworkState.error;
        resendOtpResponse.message =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      resendOtpResponse.state = NetworkState.error;
      resendOtpResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getOnboardingQuestions() async {
    try {
      String apiKey = (await getApiKey())!;
      var data = await authenticationService.getOnboardingQuestionsv2(apiKey);

      if (data['status'] == '200') {
        OnboardingQuestionOverviewModel onboardingQuestionsList =
            OnboardingQuestionOverviewModel.fromJson(data['response']);

        if (onboardingQuestionsList.questions?.isNotEmpty ?? false) {
          isOnboardingQuestionsAvailable = true;
          await sharedPreferences.setBool("onboarding_pending", true);
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void resetOtp() {
    otpInputController!.text = '';
  }
}
