import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/onboarding/login_controller.dart';
import 'package:app/src/utils/auth_util.dart';
import 'package:app/src/utils/push_notifications.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/lockscreen_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class SignInEmailScreen extends StatefulWidget {
  SignInEmailScreen();
  @override
  _SignInEmailScreenState createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends State<SignInEmailScreen> {
  late LoginController loginController;

  @override
  void initState() {
    loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put<LoginController>(LoginController());
    loginController.signInWithEmailAndPasswordResponse.message = '';
    loginController.loginIDController!.addListener(() {
      setState(() {
        enableButton = loginController.loginIDController!.text.isNotEmpty &&
            loginController.passwordController!.text.isNotEmpty;
      });
    });
    loginController.passwordController!.addListener(() {
      setState(() {
        enableButton = loginController.loginIDController!.text.isNotEmpty &&
            loginController.passwordController!.text.isNotEmpty;
      });
    });
    preFillEmail();
    super.initState();
  }

  void preFillEmail() async {
    final SharedPreferences sharedPreferences = await prefs;
    String? email = sharedPreferences.getString("signInEmail");
    if (email != null) {
      loginController.loginIDController!.text = email;
    }
  }

  bool enableButton = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Log In',
        subtitleText: 'Enter your email Id & password',
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstants.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          padding: const EdgeInsets.symmetric(horizontal: 30)
              .copyWith(top: 80, bottom: 24),
          child: Form(
            key: loginController.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildOnboardingSimpleTextField(
                  keyboardType: TextInputType.text,
                  labelText: 'Email ID / Username',
                  buildContext: context,
                  controller: loginController.loginIDController,
                ),
                buildOnboardingSimpleTextField(
                  keyboardType: TextInputType.visiblePassword,
                  labelText: 'Password',
                  buildContext: context,
                  obscureText: !_isPasswordVisible,
                  controller: loginController.passwordController,
                  isPasswordField: true,
                  isPasswordVisible: _isPasswordVisible,
                  onPasswordVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                Spacer(),
                GetBuilder<LoginController>(
                  dispose: (_) {
                    Get.delete<LoginController>();
                  },
                  id: GetxId.signInWithEmailAndPassword,
                  builder: (controller) {
                    return Container(
                      alignment: Alignment.center,
                      child: ActionButton(
                        showProgressIndicator: controller
                                .signInWithEmailAndPasswordResponse.state ==
                            NetworkState.loading,
                        text: 'Login',
                        borderRadius: 170,
                        isDisabled: !enableButton,
                        height: 50,
                        margin: EdgeInsets.zero,
                        onPressed: enableButton
                            ? () async {
                                onSignIn();
                              }
                            : null,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                Align(
                  alignment: Alignment.center,
                  child: ClickableText(
                    text: 'Forgot Password?',
                    fontSize: 14,
                    onClick: () {
                      String advisorWebUrl = getAdvisorWebUrl();
                      String forgotPasswordUrl =
                          '$advisorWebUrl/dashboards/forgot-password/';

                      if (!isPageAtTopStack(context, WebViewRoute.name)) {
                        AutoRouter.of(context).push(
                          WebViewRoute(
                            url: forgotPasswordUrl,
                            onNavigationRequest: (NavigationRequest request) {
                              if (request.url.endsWith('/dashboards/login/')) {
                                //go to app login page instead web login page
                                AutoRouter.of(context).popUntil(
                                    ModalRoute.withName(SignInEmailRoute.name));
                                return NavigationDecision.prevent;
                              }
                              return NavigationDecision.navigate;
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> onUnlockScreen() async {
    AutoRouter.of(context).push(BaseRoute());
  }

  Future<void> onSignIn() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (loginController.emailFormKey!.currentState!.validate()) {
      String? token = await PushNotificationsManager().init();
      await loginController.signInWithEmailAndPassword(
        fcmToken: token,
      );

      if (loginController.signInWithEmailAndPasswordResponse.state ==
          NetworkState.error) {
        showToast(
          context: context,
          text: loginController.signInWithEmailAndPasswordResponse.message,
        );
      }

      if (loginController.signInWithEmailAndPasswordResponse.state ==
          NetworkState.loaded) {
        try {
          // String? externalId =
          //     loginController.sharedPreferences.getString("agentExternalId");
          // String? fcmToken =
          //     loginController.sharedPreferences.getString("fcmToken");

          // AppsflyerSDK.setCustomerUserId(externalId);
          // AppsflyerSDK.setUninstallToken(fcmToken);
        } catch (error) {
          LogUtil.printLog(error);
        }

        if (loginController.onboardingQuestionsList != null &&
            loginController.onboardingQuestionsList!.questions!.isNotEmpty) {
          AutoRouter.of(context).push(
            OnboardingQuestionsRoute(),
          );
        } else {
          _navigateToLockScreen();
        }
      }
    } else {
      LogUtil.printLog('Form not validated');
    }
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
  }
}
