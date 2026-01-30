import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/home/partner_verification_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PartnerEmailAddScreen extends StatelessWidget {
  const PartnerEmailAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerVerificationController>(
      init: PartnerVerificationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Enter Email',
          ),
          body: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 16),
            child: Form(
              key: controller.addEmailFormKey,
              child: BorderedTextFormField(
                controller: controller.emailController,
                enabled: true,
                label: "Email Address",
                hintText: "example@gmail.com",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isNullOrEmpty || !isEmailValid(value)) {
                    return 'Please enter valid Email ID.';
                  }

                  return null;
                },
              ),
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
                  isDisabled: controller.emailController.text.isEmpty,
                  showProgressIndicator:
                      controller.sendOtpState == NetworkState.loading,
                  text: 'Send OTP',
                  margin: EdgeInsets.only(bottom: 24, left: 30, right: 30),
                  onPressed: () async {
                    if (!controller.addEmailFormKey.currentState!.validate()) {
                      return null;
                    }

                    await controller.sendPartnerEmailOtp();

                    if (controller.sendOtpState == NetworkState.loaded) {
                      AutoRouter.of(context).push(PartnerEmailVerifyRoute());
                    } else if (controller.sendOtpState == NetworkState.error) {
                      return showToast(text: controller.sendOtpErrorMessage);
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
}
