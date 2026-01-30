import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/certified_rest_api_handler.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

String onboardingQuestionVersion = "onboarding_v2";

class AuthenticationAPI {
  static signInWithEmailAndPassword(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('login'), body, headers);

    return response;
  }

  static signInPhoneNumber(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('login-otp'), body, headers);

    return response;
  }

  static signInWithPhoneNumber(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    final url = ApiConstants().getRestApiUrl('login-phone-captcha');

    // final response = await RestApiHandlerData.postData(url, body, headers);
    final response = await CertifiedRestApiHandlerData(
      certificate: ApiConstants().apiClientCertificate,
      certificateKey: ApiConstants().apiClientCertificateKey,
    ).postData(url, body, headers);

    return response;
  }

  static signUp(dynamic body, {String? captchaToken}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    final url = ApiConstants().getRestApiUrl('signup-captcha');

    headers['content-type'] = 'application/json';
    if (captchaToken != null && captchaToken.isNotEmpty) {
      headers['c-token'] = captchaToken;
    }
    // final response =
    //     await RestApiHandlerData.postData(url, jsonEncode(body), headers);
    final response = await CertifiedRestApiHandlerData(
      certificate: ApiConstants().apiClientCertificate,
      certificateKey: ApiConstants().apiClientCertificateKey,
    ).postData(url, jsonEncode(body), headers);

    LogUtil.printLog('signup response $response');

    return response;
  }

  static verifySignUp(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    final url = ApiConstants().getRestApiUrl('verify-signup-captcha');
    headers['content-type'] = 'application/json';
    // final response =
    //     await RestApiHandlerData.postData(url, jsonEncode(body), headers);
    final response = await CertifiedRestApiHandlerData(
      certificate: ApiConstants().apiClientCertificate,
      certificateKey: ApiConstants().apiClientCertificateKey,
    ).postData(url, jsonEncode(body), headers);

    return response;
  }

  static resendSignUpOtp(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('resend-signup-otp'),
        jsonEncode(body),
        headers);

    return response;
  }

  static validateReferralCode(String referralCode, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url =
        '${ApiConstants().getRestApiUrl('validate-referral-code')}?referral_code=$referralCode';
    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.getData(url, headers);
    return response;
  }

  static updateOnboardingAnswers(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.putData(
        ApiConstants().getRestApiUrl('update-lead-qna'),
        jsonEncode(body),
        headers);

    return response;
  }

  static sendFinancialExperience(dynamic body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.putData(
        ApiConstants().getRestApiUrl('update-lead-qna-v2'),
        jsonEncode(body),
        headers);

    return response;
  }

  static forgotPassword(dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('forgot-password'), body, headers);

    return response;
  }

  static setFCMtoken(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('set-fcm-token'), body, headers);

    return response;
  }

  static verifyAgent(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('verify-agent'), {}, headers);
    return response;
  }

  static checkPasscodeAccess() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/check-passcode-access',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static checkForceUpdateStatus() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/check-force-update', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static fetchAppInitData() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/app-init-data', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerVerificationRequestId(
      String apiKey, Map<String, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('create-pv-request'),
        jsonEncode(body),
        headers);

    return response;
  }

  static sendPartnerVerificationOtp(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('send-pv-otp'), jsonEncode(body), headers);

    return response;
  }

  static reSendPartnerVerificationOtp(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('resend-pv-otp'),
        jsonEncode(body),
        headers);

    return response;
  }

  static verifyPartnerVerificationOtp(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('verify-pv-otp'),
        jsonEncode(body),
        headers);

    return response;
  }

  static sendPartnerEmailOtp(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
      ApiConstants().getRestApiUrl('send-cr-otp'),
      jsonEncode(body),
      headers,
    );

    return response;
  }

  static verifyPartnerEmailOtp(String apiKey, Map body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
      ApiConstants().getRestApiUrl('verify-cr-otp'),
      jsonEncode(body),
      headers,
    );

    return response;
  }

  static getCities(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    final response = await RestApiHandlerData.getData(
      ApiConstants().getRestApiUrl('cities'),
      headers,
    );

    return response;
  }

  static getOnboardingQuestionsv2(String apiKey, String? stageId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String queryParams = '?qna_type=$onboardingQuestionVersion';
    if (stageId != null && stageId.isNotEmpty) {
      queryParams += '&stage_id=$stageId';
    }

    String apiUrl =
        '${ApiConstants().getRestApiUrl('onboarding-question-v2')}$queryParams';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
    );

    return response;
  }

  static submitOnboardingAnswerv2(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = '${ApiConstants().getRestApiUrl('onboarding-question-v2')}';

    headers['content-type'] = 'application/json';

    payload["qna_type"] = onboardingQuestionVersion;

    final response = await RestApiHandlerData.postData(
      apiUrl,
      jsonEncode(payload),
      headers,
    );

    return response;
  }

  static getOnboardingAnswersv2(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl =
        '${ApiConstants().getRestApiUrl('onboarding-question-v2')}answers/?qna_type=$onboardingQuestionVersion';

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
    );

    return response;
  }

  static getHalfAgentAccessToken(Map<String, dynamic> body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    String apiUrl = ApiConstants().getRestApiUrl('access-token');

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
      apiUrl,
      jsonEncode(body),
      headers,
    );

    return response;
  }

  /// Gets agent communication auth token using GraphQL mutation
  static getAgentCommunicationAuthToken(String apiKey) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getAgentCommunicationAuthToken();
      return response;
    } catch (e) {
      LogUtil.printLog(
          'getAgentCommunicationAuthToken error ==> ${e.toString()}');
    }
  }

  static registerDeviceToken(
      Map<String, dynamic> payload, String apiKey) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = 'application/json';

      final url = ApiConstants().getRestApiUrl('register-device-token');
      final response = await RestApiHandlerData.postData(
        url,
        payload,
        headers,
        retry: true,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  static deregisterDeviceToken(
      Map<String, dynamic> payload, String apiKey) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = 'application/json';

      final url = ApiConstants().getRestApiUrl('deregister-device-token');
      final response = await RestApiHandlerData.postData(
        url,
        payload,
        headers,
        retry: true,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
