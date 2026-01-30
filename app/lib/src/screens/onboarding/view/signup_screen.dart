import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/onboarding/register_controller.dart';
import 'package:app/src/screens/onboarding/widgets/referral_code_field.dart';
import 'package:app/src/utils/method_channel_util.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  RegisterController? registerController;

  SignUpScreen() {
    registerController = Get.put<RegisterController>(RegisterController());
  }

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // RegisterController registerController;

  @override
  void initState() {
    _showHintDialog();
    super.initState();
  }

  void _showHintDialog() async {
    // Get phone number hint from Android Phone Number Hint API
    final userSelectedPhoneNumber =
        await MethodChannelUtil.getPhoneNumberHint();

    if (userSelectedPhoneNumber.isNotNullOrEmpty) {
      // Handle different phone number formats
      String phoneNumber = extractPhoneFromHint(userSelectedPhoneNumber!);

      if (phoneNumber.length == 10 && Get.isRegistered<RegisterController>()) {
        RegisterController registerController = Get.find<RegisterController>();
        registerController.phoneController!.text = phoneNumber;
        registerController.countryCode = indiaCountryCode;
        registerController.update([GetxId.phoneNumberInput]);
      } else {
        showToast(text: 'Please add your number manually');
      }
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Sign Up',
        subtitleText: 'Get started with your mobile number',
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstants.white,
      body: GetBuilder<RegisterController>(
          id: GetxId.registerPhone,
          dispose: (_) {
            Get.delete<RegisterController>();
          },
          builder: (controller) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(top: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: controller.phoneFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GetBuilder<RegisterController>(
                                  id: GetxId.phoneNumberInput,
                                  builder: (controller) {
                                    return BorderedTextFormField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(
                                            getPhoneNumberLimitByCountry(
                                                controller.countryCode)),
                                      ],
                                      keyboardType: TextInputType.phone,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                            color: ColorConstants.black,
                                            height: 1.4,
                                          ),
                                      prefixIcon: CountryCodePicker(
                                        padding: EdgeInsets.zero,
                                        initialSelection:
                                            controller.countryCode,
                                        flagWidth: 24.0,
                                        flagDecoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        showFlag: true,
                                        showFlagDialog: true,
                                        enabled: true,
                                        textStyle: Theme.of(context)
                                            .primaryTextTheme
                                            .headlineSmall!
                                            .copyWith(
                                              color: Colors.black,
                                              height: 1.4,
                                            ),
                                        onChanged: (CountryCode countryCode) {
                                          controller.countryCode =
                                              countryCode.dialCode;

                                          controller.update(
                                              [GetxId.phoneNumberInput]);
                                        },
                                      ),
                                      onChanged: (val) {
                                        controller
                                            .update([GetxId.phoneNumberInput]);
                                      },
                                      controller: controller.phoneController,
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        return phoneNumberInputValidation(
                                            value, controller.countryCode);
                                      },
                                    );
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 24),
                                child: Text(
                                  'We\'ll send you an OTP to verify',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.darkGrey,
                                      ),
                                ),
                              ),
                              buildOnboardingSimpleTextField(
                                buildContext: context,
                                labelText: 'First Name',
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                controller: controller.firstNameController,
                              ),
                              buildOnboardingSimpleTextField(
                                buildContext: context,
                                labelText: 'Last Name',
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                controller: controller.lastNameController,
                              ),
                              buildOnboardingSimpleTextField(
                                buildContext: context,
                                labelText: 'Email ID',
                                keyboardType: TextInputType.emailAddress,
                                controller: controller.emailController,
                              ),
                              ReferralCodeInviteField(),
                              SizedBox(height: SizeConfig().screenHeight / 8),
                              Container(
                                width: double.infinity,
                                child: ActionButton(
                                  text: 'Get OTP',
                                  margin: EdgeInsets.zero,
                                  height: 56,
                                  borderRadius: 51,
                                  showProgressIndicator:
                                      controller.registerPhoneResponse.state ==
                                          NetworkState.loading,
                                  onPressed: () {
                                    onSignUp(context, controller);
                                  },
                                  textStyle: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: CommonUI.termsAndCondition(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Future<void> onSignUp(
      BuildContext context, RegisterController registerController,
      {String? captchaToken}) async {
    if (registerController.phoneFormKey!.currentState!.validate()) {
      registerController.signUp(captchaToken: captchaToken).then(
        (value) async {
          if (registerController.registerPhoneResponse.isLoaded) {
            bool isAgentExists =
                registerController.signUpModel.existing ?? false;

            if (isAgentExists) {
              AutoRouter.of(context).push(
                VerifyLoginOtpRoute(
                  isExistingAgent: true,
                  agentName: registerController.signUpModel.name,
                  phoneNumber: registerController.phoneController!.text,
                  countryCode: registerController.countryCode,
                ),
              );
            } else {
              AutoRouter.of(context).push(VerifySignUpOtpRoute());
            }
          } else if (registerController.registerPhoneResponse.isError) {
            showToast(
              context: context,
              text: registerController.registerPhoneResponse.message,
            );
            // await showCaptcha(registerController);
          }
        },
      );
    }
  }

  // Temporarily removed captcha implementation due to safetynet captcha sdk shutdown

  // Future<void> showCaptcha(RegisterController registerController) async {
  //   if (registerController.signupErrorCode.isNotNullOrEmpty) {
  //     final errorCode = registerController.signupErrorCode;
  //     // CPTREQ00 -> Catcha required error
  //     // INVALID_CAPTCHA = "INVCAP00"
  //     // CONFLC00 -> conflict resolution error
  //     if (errorCode == 'CPTREQ00') {
  //       String key = (await registerController.getCaptchaKey()) ?? '';
  //       if (key.isNullOrEmpty) {
  //         // TODO: Remote Config for dev not working due to not having access so added here
  //         key = '6LejnMwkAAAAAFIscgPalTmOwzBijusBTLw8iask';
  //         // Note the above key is not working in dev
  //       }
  //       // Grecaptcha().verifyWithRecaptcha(key).then((String result) {
  //       //   onSignUp(context, registerController, captchaToken: result);
  //       // });
  //     } else if (errorCode == 'CONFLC00') {
  //       if (registerController.signupWebViewRedirectUrl.isNotNullOrEmpty) {
  //         AutoRouter.of(context).push(
  //           WebViewRoute(
  //             url: registerController.signupWebViewRedirectUrl,
  //             onNavigationRequest: (NavigationRequest request) {
  //               if (request.url.contains('wealthy.onelink.me')) {
  //                 //go to app login page instead web login page
  //                 AutoRouter.of(context)
  //                     .popUntil(ModalRoute.withName(GetStartedRoute.name));
  //                 return NavigationDecision.prevent;
  //               }
  //               return NavigationDecision.navigate;
  //             },
  //           ),
  //         );
  //       }
  //     } else if (errorCode == 'INVCAP00') {
  //       showToast(text: 'We could not verify that you are a human');
  //     }
  //   }
  // }
}
