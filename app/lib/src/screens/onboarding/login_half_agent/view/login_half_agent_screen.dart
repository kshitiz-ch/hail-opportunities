import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/onboarding/login_half_agent_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class LoginHalfAgentScreen extends StatelessWidget {
  const LoginHalfAgentScreen({
    Key? key,
    required this.authCode,
  }) : super(key: key);

  final String? authCode;

  void dispose() {}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: GetBuilder<LoginHalfAgentController>(
          init: LoginHalfAgentController(authCode: authCode),
          builder: (controller) {
            if (controller.accessTokenResponse.state == NetworkState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: ColorConstants.errorColor,
                      size: 30,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Failed to Login. Please retry with a new link',
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ActionButton(
                      text: 'Go Back',
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                      },
                    )
                  ],
                ),
              );
            }

            if (controller.accessTokenResponse.state == NetworkState.loaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: ColorConstants.primaryAppColor,
                      size: 30,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Successfully logged in',
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Logging in...',
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
