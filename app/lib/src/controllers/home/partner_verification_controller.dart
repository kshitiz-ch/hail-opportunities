import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerVerificationController extends GetxController {
  String? requestId;
  String? verifyFieldValue;
  OnboardingQuestionOverviewModel? onboardingQuestionsList;
  List<String> cities = [];

  NetworkState sendOtpState = NetworkState.cancel;
  NetworkState resendOtpState = NetworkState.cancel;
  NetworkState verifyOtpState = NetworkState.cancel;
  NetworkState partnerVerificationState = NetworkState.cancel;

  String sendOtpErrorMessage = '';
  String resendOtpErrorMessage = '';
  String verifyOtpErrorMessage = '';
  String partnerVerificationErrorMessage = '';

  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addEmailFormKey = GlobalKey<FormState>();

  TextEditingController otpController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  PartnerVerificationController({this.requestId, this.verifyFieldValue});

  Future<void> reSendPartnerVerificationOtp() async {
    resendOtpState = NetworkState.loading;
    update();

    try {
      {
        String apiKey = (await getApiKey())!;
        Map payload = {
          "request_id": requestId,
          "field_value": verifyFieldValue
        };

        var data = await AuthenticationRepository()
            .reSendPartnerVerificationOtp(apiKey, payload);

        if (data["status"] == "200") {
          resendOtpState = NetworkState.loaded;
        } else {
          resendOtpState = NetworkState.error;
          resendOtpErrorMessage = getErrorMessageFromResponse(data["response"]);
        }
      }
    } catch (error) {
      resendOtpState = NetworkState.error;
      resendOtpErrorMessage = 'Something went wrong. Please try again';
    } finally {
      update();
    }
  }

  Future<void> verifyPartnerVerificationOtp() async {
    partnerVerificationState = NetworkState.loading;
    update();

    try {
      {
        String apiKey = (await getApiKey())!;
        Map payload = {
          "otp": otpController.text,
          "request_id": requestId,
          "field_value": verifyFieldValue
        };

        var data = await AuthenticationRepository()
            .verifyPartnerVerificationOtp(apiKey, payload);

        if (data["status"] == "200") {
          partnerVerificationState = NetworkState.loaded;
        } else {
          partnerVerificationState = NetworkState.error;
          partnerVerificationErrorMessage =
              getErrorMessageFromResponse(data["response"]);
        }
      }
    } catch (error) {
      partnerVerificationState = NetworkState.error;
      partnerVerificationErrorMessage =
          'Something went wrong. Please try again';
    } finally {
      update();
    }
  }

  Future<void> sendPartnerEmailOtp() async {
    sendOtpState = NetworkState.loading;
    update();

    try {
      {
        String apiKey = (await getApiKey())!;
        Map payload = {
          "update_field": "email",
          "field_value": emailController.text,
        };

        var data = await AuthenticationRepository()
            .sendPartnerEmailOtp(apiKey, payload);

        if (data["status"] == "200") {
          sendOtpState = NetworkState.loaded;
          requestId = data["response"]["request_id"];
        } else {
          sendOtpState = NetworkState.error;
          sendOtpErrorMessage = getErrorMessageFromResponse(data["response"]);
        }
      }
    } catch (error) {
      sendOtpState = NetworkState.error;
      sendOtpErrorMessage = 'Something went wrong. Please try again';
    } finally {
      update();
    }
  }

  Future<void> verifyPartnerEmailOtp() async {
    verifyOtpState = NetworkState.loading;
    update([GetxId.verifyEmail]);

    try {
      {
        String apiKey = (await getApiKey())!;
        Map payload = {
          "otp": otpController.text,
          "request_id": requestId,
        };

        var data = await AuthenticationRepository()
            .verifyPartnerEmailOtp(apiKey, payload);

        if (data["status"] == "200") {
          verifyOtpState = NetworkState.loaded;
          await getOnboardingQuestions();
        } else {
          verifyOtpState = NetworkState.error;
          verifyOtpErrorMessage = getErrorMessageFromResponse(data["response"]);
        }
      }
    } catch (error) {
      verifyOtpState = NetworkState.error;
      verifyOtpErrorMessage = 'Something went wrong. Please try again';
    } finally {
      update([GetxId.verifyEmail]);
    }
  }

  Future<void> getOnboardingQuestions() async {
    try {
      String apiKey = (await getApiKey())!;
      var data =
          await AuthenticationRepository().getOnboardingQuestionsv2(apiKey);

      if (data['status'] == '200') {
        onboardingQuestionsList =
            OnboardingQuestionOverviewModel.fromJson(data['response']);
        if (onboardingQuestionsList!.questions!.isNotEmpty) {
          await getCities();
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update([GetxId.verifyEmail]);
    }
  }

  Future<void> getCities() async {
    try {
      String apiKey = (await getApiKey())!;
      var data = await AuthenticationRepository().getCities(apiKey);
      if (data['status'] == '200') {
        cities = List<String>.from(data['response']['cities']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update([GetxId.verifyEmail]);
    }
  }

  void resetOtp() {
    otpController.clear();
  }
}
