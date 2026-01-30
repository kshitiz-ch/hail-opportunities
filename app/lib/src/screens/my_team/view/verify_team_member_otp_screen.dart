import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/my_team/add_team_member_controller.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/screens/onboarding/widgets/otp_inputs.dart';
import 'package:app/src/screens/onboarding/widgets/otp_toast.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class VerifyTeamMemberOtpScreen extends StatefulWidget {
  const VerifyTeamMemberOtpScreen({Key? key}) : super(key: key);

  @override
  State<VerifyTeamMemberOtpScreen> createState() =>
      _VerifyTeamMemberOtpScreenState();
}

class _VerifyTeamMemberOtpScreenState extends State<VerifyTeamMemberOtpScreen> {
  bool canShowToast = false;

  void goBackHandler() async {
    if (Get.isRegistered<AddTeamMemberController>()) {
      Get.find<AddTeamMemberController>().resetOtpStates();
    }
    AutoRouter.of(context).popForced();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, goBackHandler);
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(titleText: 'Enter OTP'),
        body: GetBuilder<AddTeamMemberController>(builder: (controller) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(context, controller),
                SizedBox(
                  height: 45,
                ),
                OtpInputs(
                  otpInputController: controller.otpInputController,
                  showResendOtp: controller.selectedMethod ==
                      NewMemberAdditionMethod.NEW_USER,
                  onChange: () {
                    setState(() {});
                  },
                  resendOtp: () async {
                    await controller.resendAgentLeadOtp();

                    showToast(
                        context: context,
                        text: controller.resendOtpResponse.message);

                    return controller.resendOtpResponse.state ==
                        NetworkState.loaded;
                  },
                )
              ],
            ),
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:
            GetBuilder<AddTeamMemberController>(builder: (controller) {
          return Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom == 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  isDisabled: controller.otpInputController.text.length != 5 ||
                      controller.verifyOtpResponse.state == NetworkState.loaded,
                  showProgressIndicator: controller.verifyOtpResponse.state ==
                      NetworkState.loading,
                  text: 'Confirm',
                  margin: EdgeInsets.only(bottom: 24, left: 30, right: 30),
                  onPressed: () async {
                    if (controller.selectedMethod ==
                        NewMemberAdditionMethod.NEW_USER) {
                      await controller.verifyNewAgentLeadOtp();
                    } else {
                      if (controller.designation == "Employee") {
                        await controller.validateAndAddEmployee();
                      } else if (controller.designation == "Member") {
                        await controller.validateAndAddAssociate();
                      }
                    }

                    setState(() {
                      canShowToast = true;
                    });

                    // show toast only 2 seconds
                    await Future.delayed(
                      Duration(seconds: 2),
                      () {
                        setState(() {
                          canShowToast = false;
                        });

                        if (controller.verifyOtpResponse.state ==
                            NetworkState.loaded) {
                          bool isAddingEmployee =
                              controller.designation == "Employee";

                          if (Get.isRegistered<MyTeamController>()) {
                            MyTeamController myTeamController =
                                Get.find<MyTeamController>();

                            if (isAddingEmployee) {
                              myTeamController.tabController!.index = 0;
                            } else if (controller.designation == "Member") {
                              myTeamController.tabController!.index = 1;
                            }

                            myTeamController.clearSearchBar();
                          }
                          AutoRouter.of(context)
                              .popUntilRouteWithName(MyTeamRoute.name);
                        }
                      },
                    );
                  },
                ),
                OtpToast(
                  canShowToast: canShowToast,
                  isSuccess:
                      controller.verifyOtpResponse.state == NetworkState.loaded,
                  message: controller.verifyOtpResponse.message,
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderText(
      BuildContext context, AddTeamMemberController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 6,
        ),
        Container(
          padding: EdgeInsets.only(right: 16),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'We have sent an OTP to phone number',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          color: ColorConstants.secondaryBlack, height: 1.4),
                ),
                TextSpan(
                  text:
                      ' (${controller.countryCode})${controller.phoneNumberController.text}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.black, height: 1.4),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
