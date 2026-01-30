import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/onboarding/login_controller.dart';
import 'package:app/src/utils/method_channel_util.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class SignInWithPhoneScreen extends StatefulWidget {
  SignInWithPhoneScreen();

  @override
  _SignInWithPhoneScreenState createState() => _SignInWithPhoneScreenState();
}

class _SignInWithPhoneScreenState extends State<SignInWithPhoneScreen> {
  late LoginController loginController;

  @override
  void initState() {
    super.initState();
    loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put<LoginController>(LoginController());

    // loginController.phoneController.addListener(() {
    //   if (mounted) {
    //     setState(() {
    //       enableButton = loginController.phoneController.text.length >= 10;
    //     });
    //   }
    // });

    preFillPhoneNumber();
  }

  void preFillPhoneNumber() async {
    final SharedPreferences sharedPreferences = await prefs;
    String? phoneNumber = sharedPreferences.getString("signInPhone");
    String? countryCode = sharedPreferences.getString("countryCode");
    if (phoneNumber != null) {
      loginController.phoneController!.text = phoneNumber;
      if (countryCode.isNotNullOrEmpty) {
        loginController.countryCode = countryCode;
        loginController.update();
      }
    } else {
      _showHintDialog();
    }
  }

  void _showHintDialog() async {
    // Get phone number hint from Android Phone Number Hint API
    final userSelectedPhoneNumber =
        await MethodChannelUtil.getPhoneNumberHint();

    if (userSelectedPhoneNumber.isNotNullOrEmpty) {
      // Handle different phone number formats
      String phoneNumber = extractPhoneFromHint(userSelectedPhoneNumber!);

      if (phoneNumber.length == 10 && Get.isRegistered<LoginController>()) {
        LoginController loginController = Get.find<LoginController>();
        loginController.phoneController!.text = phoneNumber;
        loginController.countryCode = indiaCountryCode;
        loginController.update();
      } else {
        showToast(text: 'Please add your number manually');
      }
    }
  }

  String errorMessage = '';
  bool enableButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Log In',
        subtitleText: 'Get started with your mobile number',
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstants.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          padding: const EdgeInsets.symmetric(horizontal: 30)
              .copyWith(top: 80, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: loginController.phoneFormKey,
                child: GetBuilder<LoginController>(builder: (controller) {
                  return BorderedTextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                          getPhoneNumberLimitByCountry(controller.countryCode)),
                    ],
                    keyboardType: TextInputType.phone,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: Colors.black,
                          height: 1.4,
                        ),
                    prefixIcon: CountryCodePicker(
                      initialSelection: controller.countryCode,
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
                        controller.countryCode = countryCode.dialCode;
                        controller.phoneFormKey!.currentState!.validate();
                        controller.update();
                      },
                    ),
                    onChanged: (val) {},
                    controller: controller.phoneController,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      return phoneNumberInputValidation(
                          value, controller.countryCode);
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 60),
                child: Text(
                  'We’ll send you an OTP to verify',
                  textAlign: TextAlign.left,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.darkGrey,
                          ),
                ),
              ),
              Spacer(),
              GetBuilder<LoginController>(
                id: GetxId.signInPhoneNumber,
                dispose: (_) {
                  Get.delete<LoginController>();
                },
                builder: (registerController) {
                  return Align(
                    alignment: Alignment.center,
                    child: ActionButton(
                      // isDisabled: !enableButton,
                      text: 'Get OTP',
                      margin: EdgeInsets.zero,
                      height: 56,
                      borderRadius: 51,
                      showProgressIndicator:
                          loginController.signInPhoneNumberResponse.state ==
                              NetworkState.loading,
                      onPressed: () async {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');

                        if (loginController.phoneFormKey!.currentState!
                            .validate()) {
                          loginController.signInPhoneNumber().then((value) {
                            if (loginController
                                    .signInPhoneNumberResponse.state ==
                                NetworkState.loaded) {
                              AutoRouter.of(context)
                                  .push(VerifyLoginOtpRoute());
                            }
                            if (loginController
                                    .signInPhoneNumberResponse.state ==
                                NetworkState.error) {
                              showToast(
                                context: context,
                                text: loginController
                                    .signInPhoneNumberResponse.message,
                              );
                            }
                          });
                        } else {
                          LogUtil.printLog('Form not validated');
                        }
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: ClickableText(
                  text: 'Facing Issues?',
                  fontSize: 14,
                  onClick: () {
                    if (!isPageAtTopStack(context, WebViewRoute.name)) {
                      final url = "https://www.buildwealth.in/partner-support";
                      AutoRouter.of(context).push(
                        WebViewRoute(
                          url: url,
                          onNavigationRequest:
                              (NavigationRequest request) async {
                            if (request.url != url &&
                                request.url.contains('buildwealth.in')) {
                              //go to app login page instead web login page
                              AutoRouter.of(context).popForced();
                              return NavigationDecision.prevent;
                            }
                          },
                        ),
                      );
                    }
                    // launch("https://www.buildwealth.in/partner-support");
                  },
                ),
              )
            ],
          ),
        );
      }),
      // ),
    );
  }
}
