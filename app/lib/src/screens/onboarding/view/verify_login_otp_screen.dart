import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/auth_util.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/constants/color_constants.dart';
import '../../../config/constants/enums.dart';
import '../../../config/constants/string_constants.dart';
import '../../../config/routes/router.gr.dart';
import '../../../config/utils/function_utils.dart';
import '../../../controllers/onboarding/login_controller.dart';
import '../../../utils/push_notifications.dart';
import '../../../widgets/button/action_button.dart';
import '../../../widgets/misc/lockscreen_ui.dart';
import '../widgets/otp_inputs.dart';
import '../widgets/otp_toast.dart';

@RoutePage()
class VerifyLoginOtpScreen extends StatefulWidget {
  const VerifyLoginOtpScreen(
      {Key? key,
      this.isExistingAgent = false,
      this.agentName,
      this.phoneNumber,
      this.countryCode})
      : super(key: key);

  final bool isExistingAgent;
  final String? agentName;
  final String? phoneNumber;
  final String? countryCode;

  @override
  State<VerifyLoginOtpScreen> createState() => _VerifyLoginOtpScreenState();
}

class _VerifyLoginOtpScreenState extends State<VerifyLoginOtpScreen> {
  bool canShowToast = false;
  late LoginController controller;
  OTPInteractor? _otpInteractor;

  @override
  void initState() {
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
    // fixed setState() or markNeedsBuild() called during build.
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     controller.phoneController?.text = widget.phoneNumber!;
    //   },
    // );

    if (widget.phoneNumber != null) {
      controller.phoneController?.text = widget.phoneNumber!;
      controller.countryCode = widget.countryCode;
    }

    _listenForOtp();

    super.initState();
  }

  void _listenForOtp() async {
    _otpInteractor = OTPInteractor();
    _otpInteractor!
        .getAppSignature()
        .then((value) => LogUtil.printLog('signature - $value'));

    String? otpMessage = await _otpInteractor?.startListenUserConsent();
    final otpRegEx = RegExp(r'(\d{5})');
    String otpCode = otpRegEx.stringMatch(otpMessage ?? '') ?? '';
    LogUtil.printLog(otpCode);

    if (Get.isRegistered<LoginController>() && otpCode.isNotNullOrEmpty) {
      Get.find<LoginController>().otpInputController!.text = otpCode;
      Get.find<LoginController>().update();
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
    return GetBuilder<LoginController>(
      dispose: (_) {
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().resetOtp();
        }
      },
      builder: (controller) {
        final subtitleInfo = getSubtitleInfo(context);
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
                  otpInputController: controller.otpInputController,
                  onChange: () {
                    setState(() {});
                  },
                  resendOtp: () async {
                    await controller.signInPhoneNumber();

                    showToast(
                        context: context,
                        text: controller.signInPhoneNumberResponse.message);

                    return controller.signInPhoneNumberResponse.state ==
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
                  isDisabled: controller.otpInputController!.text.length != 5 ||
                      controller.verifySignInOtpResponse.state ==
                          NetworkState.loaded,
                  showProgressIndicator:
                      controller.verifySignInOtpResponse.state ==
                          NetworkState.loading,
                  text: 'Confirm',
                  margin: EdgeInsets.only(bottom: 24, left: 30, right: 30),
                  onPressed: () async {
                    String? token;
                    try {
                      token = await PushNotificationsManager().init();
                    } catch (error) {
                      LogUtil.printLog(error);
                    }

                    await controller.verifySignInOtp(token);

                    setState(() {
                      canShowToast = true;
                    });

                    // show toast only 2 seconds
                    await Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        canShowToast = false;
                      });
                      if (controller.verifySignInOtpResponse.state ==
                          NetworkState.loaded) {
                        _stopListenForOtp();
                        // move to lock screen flow after signin

                        if (controller.onboardingQuestionsList != null &&
                            (controller.onboardingQuestionsList?.questions ??
                                    [])
                                .isNotEmpty) {
                          AutoRouter.of(context).push(
                            OnboardingQuestionsRoute(),
                          );
                        } else {
                          _navigateToLockScreen();
                        }
                      }
                    });
                  },
                ),
                OtpToast(
                  canShowToast: canShowToast,
                  isSuccess: controller.verifySignInOtpResponse.state ==
                      NetworkState.loaded,
                  message: controller.verifySignInOtpResponse.message,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void displayLockScreen(passcode) {
    showLockScreen(
      context: context,
      backgroundColorOpacity: 1,
      correctString: passcode,
      canBiometric: true,
      showBiometricFirst: true,
      biometricAuthenticate: biometricAuthentication,
      onUnlocked: onUnlockScreen,
    );
  }

  Future<void> onUnlockScreen() async {
    AutoRouter.of(context).push(BaseRoute());
  }

  void _navigateToLockScreen() async {
    final SharedPreferences sharedPreferences = await prefs;
    bool shouldDisablePasscode = sharedPreferences
            .getBool(SharedPreferencesKeys.shouldDisablePasscode) ??
        false;

    if (shouldDisablePasscode) {
      AutoRouter.of(context).push(BaseRoute());
    } else if (sharedPreferences.getString('passcode') == null) {
      showConfirmPasscode(
        context: context,
        backgroundColorOpacity: 1,
        backgroundColor: Colors.white,
        confirmTitle: 'Confirm New Passcode',
        onCompleted: (context, verifyCode) async {
          LogUtil.printLog(verifyCode);
          await sharedPreferences.setString('passcode', verifyCode);
        },
        canBiometric: true,
        showBiometricFirst: true,
        biometricAuthenticate: biometricAuthentication,
        onUnlocked: onUnlockScreen,
      );
    } else {
      String passcode = sharedPreferences.getString('passcode')!;
      await sharedPreferences.setString('passcode', passcode);
      displayLockScreen(passcode);
    }
  }

  List getSubtitleInfo(BuildContext context) {
    String existingAgentText = '';
    if (widget.isExistingAgent) {
      existingAgentText =
          'Hi ${widget.agentName ?? 'there'}, your number is already registered with us. ';
    }
    TextSpan span = TextSpan(
      children: [
        TextSpan(
          text: '${existingAgentText}We have sent an OTP to your phone number',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.secondaryBlack, height: 1.4),
        ),
        TextSpan(
          text:
              ' (${controller.countryCode})${controller.phoneController!.text}',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.black, height: 1.4),
        ),
      ],
    );
    Widget subtitleWidget = RichText(text: span);
    final height = getTextHeight(span);
    return [subtitleWidget, height];
  }
}
