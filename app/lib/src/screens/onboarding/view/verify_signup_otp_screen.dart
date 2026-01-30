import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/firebase/firebase_event_service.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/onboarding/register_controller.dart';
import 'package:app/src/screens/onboarding/widgets/otp_inputs.dart';
import 'package:app/src/screens/onboarding/widgets/otp_toast.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_autofill/otp_autofill.dart';

@RoutePage()
class VerifySignUpOtpScreen extends StatefulWidget {
  const VerifySignUpOtpScreen({Key? key}) : super(key: key);

  @override
  State<VerifySignUpOtpScreen> createState() => _VerifySignUpOtpScreenState();
}

class _VerifySignUpOtpScreenState extends State<VerifySignUpOtpScreen> {
  bool canShowToast = false;
  OTPInteractor? _otpInteractor;

  @override
  void initState() {
    _listenForOtp();

    super.initState();
  }

  void _listenForOtp() async {
    _otpInteractor = OTPInteractor();
    _otpInteractor!
        .getAppSignature()
        .then((value) => LogUtil.printLog('signature - $value'));

    String? otpMessage = await _otpInteractor!.startListenUserConsent();
    final otpRegEx = RegExp(r'(\d{5})');
    String otpCode = otpRegEx.stringMatch(otpMessage ?? '') ?? '';
    LogUtil.printLog(otpCode);

    if (Get.isRegistered<RegisterController>() && otpCode.isNotNullOrEmpty) {
      Get.find<RegisterController>().otpInputController!.text = otpCode;
      Get.find<RegisterController>().update();
    }
  }

  void _stopListenForOtp() {
    try {
      _otpInteractor?.stopListenForCode();
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopListenForOtp();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      dispose: (_) {
        if (Get.isRegistered<RegisterController>()) {
          Get.find<RegisterController>().resetOtp();
        }
      },
      builder: (controller) {
        bool isButtonDisabled =
            controller.otpInputController!.text.length != 5 ||
                controller.verifySignupOtpResponse.state == NetworkState.loaded;
        final subtitleInfo = getSubtitleInfo(context, controller);
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Enter OTP',
            subtitleHeight: subtitleInfo.last,
            customSubtitleWidget: subtitleInfo.first,
          ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtpInputs(
                  onChange: () {
                    setState(() {});
                  },
                  otpInputController: controller.otpInputController,
                  resendOtp: () async {
                    await controller.resendOtp();

                    showToast(
                        context: context,
                        text: controller.resendOtpResponse.message);

                    return controller.resendOtpResponse.state ==
                        NetworkState.loaded;
                  },
                )
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom == 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  isDisabled: isButtonDisabled,
                  showProgressIndicator:
                      controller.verifySignupOtpResponse.state ==
                          NetworkState.loading,
                  disabledColor: ColorConstants.lightGrey,
                  text: 'Confirm',
                  textStyle:
                      Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                            color: isButtonDisabled
                                ? ColorConstants.darkGrey
                                : ColorConstants.white,
                          ),
                  margin: EdgeInsets.only(
                    bottom: 24,
                    left: 30,
                    right: 30,
                  ),
                  onPressed: () async {
                    await controller.verifySignupOtp();

                    setState(() {
                      canShowToast = true;
                    });

                    // show toast only 2 seconds
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        canShowToast = false;
                      });

                      if (controller.verifySignupOtpResponse.state ==
                          NetworkState.loaded) {
                        _stopListenForOtp();

                        try {
                          final analytics = FirebaseAnalytics.instance;
                          analytics.logSignUp(signUpMethod: 'Signed_Up');
                          FirebaseEventService.logEvent('WL_OTP_Resp_Succ');
                        } catch (error) {
                          LogUtil.printLog(error);
                        }

                        if (controller.isOnboardingQuestionsAvailable) {
                          AutoRouter.of(context)
                              .push(OnboardingQuestionsRoute());
                        } else {
                          AutoRouter.of(context).push(BaseRoute());
                        }
                      }
                    });
                  },
                ),
                OtpToast(
                  canShowToast: canShowToast,
                  isSuccess: controller.verifySignupOtpResponse.state ==
                      NetworkState.loaded,
                  message: controller.verifySignupOtpResponse.message,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List getSubtitleInfo(BuildContext context, RegisterController controller) {
    final span = TextSpan(
      children: [
        TextSpan(
          text: 'We have sent an OTP to your\nphone number',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.secondaryBlack, height: 1.4),
        ),
        TextSpan(
          text: ' ${controller.agentPhoneNumber}',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.black, height: 1.4),
        ),
      ],
    );
    final subtitleWidget = RichText(text: span);
    final height = getTextHeight(span);
    return [subtitleWidget, height];
  }
}
