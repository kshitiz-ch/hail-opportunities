import 'dart:math';

import 'package:api_sdk/api_collection/authentication_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:core/config/string_utils.dart';

class AuthenticationRepository {
  Future<dynamic> signInWithEmailAndPassword(
      String username, String? password) async {
    final response = await AuthenticationAPI.signInWithEmailAndPassword({
      'username': username,
      'password': password,
      'captcha_token': getRandomString(5)
    });

    return response;
  }

  Future<dynamic> signInWithPhoneNumber(String phoneNumber, String? otp) async {
    final response = await AuthenticationAPI.signInWithPhoneNumber(
        {'phone_number': phoneNumber, 'otp': otp});

    return response;
  }

  Future<dynamic> signUp(String firstName, String lastName, String phoneNumber,
      {String? emailID,
      String? referralCode,
      String? captchaToken,
      required Map<String, dynamic> queryParams}) async {
    Map signUpPayload = {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber.toString(),
      ...queryParams
    };

    if (emailID != null) {
      signUpPayload['email'] = emailID;
    }
    if (referralCode.isNotNullOrEmpty) {
      signUpPayload['referral_code'] = referralCode;
    }

    final response = await AuthenticationAPI.signUp(
      signUpPayload,
      captchaToken: captchaToken,
    );
    return response;
  }

  Future<dynamic> verifySignUp(String leadId, String otp) async {
    final response =
        await AuthenticationAPI.verifySignUp({'lead_id': leadId, 'otp': otp});

    return response;
  }

  Future<dynamic> resendSignUpOtp(
    String leadId,
  ) async {
    final response =
        await AuthenticationAPI.resendSignUpOtp({'lead_id': leadId});

    return response;
  }

  Future<dynamic> getCities(
    String apiKey,
  ) async {
    final response = await AuthenticationAPI.getCities(apiKey);

    return response;
  }

  Future<dynamic> getOnboardingQuestionsv2(String apiKey,
      {String? stageId}) async {
    final response =
        await AuthenticationAPI.getOnboardingQuestionsv2(apiKey, stageId);

    return response;
  }

  Future<dynamic> getOnboardingAnswersv2(String apiKey) async {
    final response = await AuthenticationAPI.getOnboardingAnswersv2(apiKey);

    return response;
  }

  Future<dynamic> submitOnboardingAnswerv2(
      String apiKey, Map<String, dynamic> payload) async {
    final response =
        await AuthenticationAPI.submitOnboardingAnswerv2(apiKey, payload);

    return response;
  }

  Future<dynamic> updateOnboardingAnswers(
      dynamic answers, String apiKey) async {
    final response =
        await AuthenticationAPI.updateOnboardingAnswers(answers, apiKey);

    return response;
  }

  Future<dynamic> validateReferralCode(
      String referralCode, String apiKey) async {
    final response =
        await AuthenticationAPI.validateReferralCode(referralCode, apiKey);
    return response;
  }

  Future<dynamic> sendFinancialExperience(dynamic answer, String apiKey) async {
    final response =
        await AuthenticationAPI.sendFinancialExperience(answer, apiKey);

    return response;
  }

  Future<dynamic> signInPhoneNumber(String phoneNumber) async {
    final response = await AuthenticationAPI.signInPhoneNumber(
        {'phone_number': phoneNumber});

    return response;
  }

  Future<dynamic> forgotPassword(String username) async {
    final response = await AuthenticationAPI.forgotPassword(
        {'email_or_username': username, 'captcha_token': getRandomString(5)});

    return response;
  }

  Future<dynamic> setFCMtoken(String apiKey, dynamic body) async {
    final response = await AuthenticationAPI.setFCMtoken(apiKey, body);

    return response;
  }

  Future<dynamic> verifyAgent(String apiKey, dynamic body) async {
    final response = await AuthenticationAPI.verifyAgent(apiKey, body);

    return response;
  }

  Future<dynamic> checkPasscodeAccess() async {
    final response = await AuthenticationAPI.checkPasscodeAccess();

    return response;
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890dfsdfsfsdfsdfsfdvsdsd';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<dynamic> getPartnerVerificationRequestId(
      String apiKey, Map<String, dynamic> body) async {
    final response =
        await AuthenticationAPI.getPartnerVerificationRequestId(apiKey, body);

    return response;
  }

  Future<dynamic> checkForceUpdateStatus() async {
    final response = await AuthenticationAPI.checkForceUpdateStatus();

    return response;
  }

  Future<dynamic> fetchAppInitData() async {
    final response = await AuthenticationAPI.fetchAppInitData();

    return response;
  }

  Future<dynamic> sendPartnerVerificationOtp(
      String apiKey, dynamic body) async {
    final response =
        await AuthenticationAPI.sendPartnerVerificationOtp(apiKey, body);

    return response;
  }

  Future<dynamic> reSendPartnerVerificationOtp(
      String apiKey, dynamic body) async {
    final response =
        await AuthenticationAPI.reSendPartnerVerificationOtp(apiKey, body);

    return response;
  }

  Future<dynamic> verifyPartnerVerificationOtp(
      String apiKey, dynamic body) async {
    final response =
        await AuthenticationAPI.verifyPartnerVerificationOtp(apiKey, body);

    return response;
  }

  Future<dynamic> verifyPartnerEmailOtp(String apiKey, Map payload) async {
    final response =
        await AuthenticationAPI.verifyPartnerEmailOtp(apiKey, payload);
    return response;
  }

  Future<dynamic> sendPartnerEmailOtp(String apiKey, Map payload) async {
    final response =
        await AuthenticationAPI.sendPartnerEmailOtp(apiKey, payload);
    return response;
  }

  Future<dynamic> getHalfAgentAccessToken(Map<String, dynamic> payload) async {
    final response = await AuthenticationAPI.getHalfAgentAccessToken(payload);
    return response;
  }

  Future<dynamic> registerDeviceToken(
      Map<String, dynamic> payload, String apiKey) async {
    final response =
        await AuthenticationAPI.registerDeviceToken(payload, apiKey);
    return response;
  }

  Future<dynamic> deregisterDeviceToken(
      Map<String, dynamic> payload, String apiKey) async {
    final response =
        await AuthenticationAPI.deregisterDeviceToken(payload, apiKey);
    return response;
  }

  /// Gets agent communication auth token using GraphQL mutation
  Future<dynamic> getAgentCommunicationAuthToken(String apiKey) async {
    try {
      final response =
          await AuthenticationAPI.getAgentCommunicationAuthToken(apiKey);
      return response;
    } catch (e) {
      LogUtil.printLog(
          'getAgentCommunicationAuthToken repository error ==> ${e.toString()}');
      return null;
    }
  }
}
