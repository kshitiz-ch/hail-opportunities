import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/partner_verification_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/onboarding/widgets/otp_inputs.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PartnerEmailVerifyScreen extends StatelessWidget {
  const PartnerEmailVerifyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerVerificationController>(
      id: GetxId.verifyEmail,
      initState: (_) {
        Get.find<PartnerVerificationController>().resetOtp();
      },
      builder: (controller) {
        final subtitleInfo = getSubtitleInfo(context, controller);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Enter OTP',
            subtitleHeight: subtitleInfo.last,
            customSubtitleWidget: subtitleInfo.first,
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 16),
            child: OtpInputs(
              onChange: () {
                controller.update([GetxId.verifyEmail]);
              },
              otpInputController: controller.otpController,
              resendOtp: () async {
                await controller.sendPartnerEmailOtp();

                if (controller.sendOtpState == NetworkState.loaded) {
                  return showToast(text: 'OTP Resent');
                } else {
                  return showToast(text: controller.sendOtpErrorMessage);
                }
              },
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
                  isDisabled: controller.otpController.text.length != 5,
                  showProgressIndicator:
                      controller.verifyOtpState == NetworkState.loading,
                  text: 'Confirm',
                  margin: EdgeInsets.only(bottom: 24, left: 30, right: 30),
                  onPressed: () async {
                    await controller.verifyPartnerEmailOtp();

                    if (controller.verifyOtpState == NetworkState.loaded) {
                      Get.find<ProfileController>().getAdvisorOverview();
                      AutoRouter.of(context)
                          .popUntil(ModalRoute.withName(ProfileRoute.name));

                      final homeController = Get.isRegistered<HomeController>()
                          ? Get.find<HomeController>()
                          : Get.put(HomeController());
                      homeController.getAdvisorOverview();

                      return showToast(text: "Email added successfully");
                    } else if (controller.verifyOtpState ==
                        NetworkState.error) {
                      return showToast(text: controller.verifyOtpErrorMessage);
                    }
                  },
                ),
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
            text: 'We have sent an OTP to your email',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.secondaryBlack)),
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
