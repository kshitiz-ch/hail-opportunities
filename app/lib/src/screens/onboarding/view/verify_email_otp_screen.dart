import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/partner_verification_controller.dart';
import 'package:app/src/screens/onboarding/widgets/otp_inputs.dart';
import 'package:app/src/screens/onboarding/widgets/otp_toast.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class VerifyEmailOtpScreen extends StatefulWidget {
  const VerifyEmailOtpScreen({
    Key? key,
    required this.isOnboardingQuestionsAvailable,
  }) : super(key: key);

  final bool isOnboardingQuestionsAvailable;

  @override
  State<VerifyEmailOtpScreen> createState() => _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen> {
  bool canShowToast = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerVerificationController>(
      id: GetxId.verifyEmail,
      dispose: (_) {
        if (Get.isRegistered<PartnerVerificationController>()) {
          Get.find<PartnerVerificationController>().resetOtp();
        }
      },
      builder: (controller) {
        bool isButtonDisabled = controller.otpController.text.length != 5 ||
            controller.verifyOtpState == NetworkState.loaded;
        final subtitleInfo = getSubtitleInfo(context, controller);
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Verify Your Email',
            subtitleHeight: subtitleInfo.last,
            customSubtitleWidget: subtitleInfo.first,
            trailingWidgets: [
              Align(
                alignment: Alignment.centerRight,
                child: ClickableText(
                  text: 'Skip',
                  padding: EdgeInsets.all(5),
                  onClick: () {
                    if (widget.isOnboardingQuestionsAvailable) {
                      AutoRouter.of(context).push(OnboardingQuestionsRoute());
                    } else {
                      AutoRouter.of(context).push(BaseRoute());
                    }
                  },
                ),
              ),
            ],
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
                  otpInputController: controller.otpController,
                  resendOtp: () async {
                    await controller.sendPartnerEmailOtp();
                    if (controller.sendOtpState == NetworkState.error) {
                      showToast(
                          context: context,
                          text: controller.sendOtpErrorMessage);
                    }
                    return controller.sendOtpState == NetworkState.loaded;
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
                      controller.verifyOtpState == NetworkState.loading,
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
                    await controller.verifyPartnerEmailOtp();
                    setState(() {
                      canShowToast = true;
                    });
                    // show toast only 2 seconds
                    Future.delayed(Duration(seconds: 2), () async {
                      setState(() {
                        canShowToast = false;
                      });
                      if (controller.verifyOtpState == NetworkState.loaded) {
                        if (widget.isOnboardingQuestionsAvailable) {
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
                  isSuccess: controller.verifyOtpState == NetworkState.loaded,
                  message: controller.verifyOtpErrorMessage,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List getSubtitleInfo(
    BuildContext context,
    PartnerVerificationController controller,
  ) {
    final span = TextSpan(
      children: [
        TextSpan(
          text: 'We have sent an OTP to your email ID\n',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.secondaryBlack, height: 1.4),
        ),
        TextSpan(
          text: ' ${controller.emailController.text}',
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
