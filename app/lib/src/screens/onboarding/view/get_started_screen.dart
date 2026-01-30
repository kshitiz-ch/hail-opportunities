import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GetStartedScreen extends StatelessWidget {
  DateTime? backButtonPressedSince;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          backButtonPressedSince =
              minimiseApplication(backButtonPressedSince, context);
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 60,
                ),
                color: ColorConstants.secondaryWhite,
                width: double.infinity,
                child: Image.asset(
                  AllImages().authenticationScreenIconNew,
                  height: SizeConfig().screenHeight * (350 / 660),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  // color: ColorConstants.primaryAppColor,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 44),
                alignment: Alignment.center,
                child: Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.secondaryBlack,
                      ),
                  // style: Theme.of(context)
                  //     .primaryTextTheme
                  //     .headlineLarge!
                  //     .copyWith(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 18,
                  //       color: ColorConstants.black,
                  //     ),
                ),
              ),
              SizedBox(height: 15),
              Image.asset(
                AllImages().wealthyBlackLogo,
                width: 135,
              ),
              // Container(
              //   padding: EdgeInsets.only(top: 16),
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Take your first step towards getting Wealthy',
              //     textAlign: TextAlign.center,
              //     style: Theme.of(context)
              //         .primaryTextTheme
              //         .headlineSmall!
              //         .copyWith(
              //           color: ColorConstants.secondaryBlack,
              //         ),
              //   ),
              // ),
              Center(
                child: ActionButton(
                  text: 'Sign Up',
                  margin: EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(top: 32, bottom: 16),
                  height: 56,
                  borderRadius: 51,
                  onPressed: () {
                    AutoRouter.of(context).push(SignUpRoute());
                  },
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.white,
                      ),
                ),
              ),
              Center(
                child: ActionButton(
                  text: 'Login to your Account',
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  height: 56,
                  borderRadius: 51,
                  onPressed: () {
                    showLoginBottomSheet(context);
                  },
                  bgColor: ColorConstants.secondaryAppColor,
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.primaryAppColor,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showLoginBottomSheet(BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      isScrollControlled: false,
      isBackgroundBlur: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          color: ColorConstants.white,
        ),
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Login to wealthy',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: ColorConstants.black,
                        ),
              ),
            ),
            SizedBox(height: 32),
            ActionButton(
              text: 'Login with Phone  ',
              margin: EdgeInsets.symmetric(horizontal: 30),
              height: 56,
              textStyle: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w800, color: Colors.white),
              borderRadius: 170,
              onPressed: () {
                AutoRouter.of(context).push(SignInWithPhoneRoute());
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ActionButton(
                borderColor: ColorConstants.primaryAppColor,
                text: 'Login with Email ',
                showBorder: true,
                margin: EdgeInsets.symmetric(horizontal: 30),
                height: 56,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w800,
                        ),
                bgColor: ColorConstants.white,
                borderRadius: 170,
                onPressed: () {
                  AutoRouter.of(context).push(SignInEmailRoute());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
