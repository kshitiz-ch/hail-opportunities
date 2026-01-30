import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/partner_verification_controller.dart';
import 'package:app/src/screens/onboarding/widgets/register_text_field.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@RoutePage()
class RegisterEmailScreen extends StatelessWidget {
  RegisterEmailScreen({
    required this.isOnboardingQuestionsAvailable,
  });

  final bool isOnboardingQuestionsAvailable;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<PartnerVerificationController>(
        init: PartnerVerificationController(),
        dispose: (_) {
          Get.delete<PartnerVerificationController>();
        },
        builder: (controller) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: ColorConstants.white,
              // AppBar
              appBar: CustomAppBar(
                titleText: 'Enter Details',
                subtitleText: 'Enter your email id to register',
                showBackButton: false,
                trailingWidgets: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ClickableText(
                      padding: EdgeInsets.all(5),
                      text: 'Skip',
                      onClick: () async {
                        if (isOnboardingQuestionsAvailable) {
                          AutoRouter.of(context)
                              .push(OnboardingQuestionsRoute());
                        } else {
                          AutoRouter.of(context).push(BaseRoute());
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: constraints.maxHeight,
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      bottom: 24,
                    ),
                    child: Form(
                      key: controller.emailFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RegisterTextField(),
                          Spacer(),
                          ActionButton(
                            showProgressIndicator:
                                controller.sendOtpState == NetworkState.loading,
                            text: 'Verify Email',
                            margin: EdgeInsets.zero,
                            height: 56,
                            onPressed: () async {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              if (controller.emailFormKey.currentState!
                                  .validate()) {
                                await controller.sendPartnerEmailOtp();
                                if (controller.sendOtpState ==
                                    NetworkState.loaded) {
                                  AutoRouter.of(context).push(
                                    VerifyEmailOtpRoute(
                                      isOnboardingQuestionsAvailable:
                                          isOnboardingQuestionsAvailable,
                                    ),
                                  );
                                } else {
                                  showToast(
                                    text: controller.sendOtpErrorMessage,
                                    context: context,
                                  );
                                }
                              }
                            },
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CommonUI.termsAndCondition(context),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
