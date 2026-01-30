import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/onboarding/widgets/otp_inputs.dart';
import 'package:app/src/screens/onboarding/widgets/otp_toast.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class AddFamilyVerificationScreen extends StatefulWidget {
  const AddFamilyVerificationScreen({Key? key}) : super(key: key);

  @override
  State<AddFamilyVerificationScreen> createState() =>
      _AddFamilyVerificationScreenState();
}

class _AddFamilyVerificationScreenState
    extends State<AddFamilyVerificationScreen> {
  bool canShowToast = false;
  String? phoneNumber = '';

  @override
  void initState() {
    final controller = Get.find<ClientFamilyController>();
    if (controller.selectedMethod == FamilyAdditionMethod.EXISTING_USER) {
      phoneNumber = controller.CRNSelectedClient?.phoneNumber ?? '';
    } else {
      phoneNumber = controller.mobileNumberController != null &&
              controller.mobileNumberController!.text.isNotNullOrEmpty
          ? '${controller.countryCode}'
              '${controller.mobileNumberController!.text}'
          : controller.client!.phoneNumber;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientFamilyController>(
      builder: (controller) {
        bool isButtonDisabled = controller.otpInputController!.text.length != 6;
        final subtitleInfo = getSubtitleInfo(context);

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Enter verification code',
            subtitleHeight: subtitleInfo.last,
            customSubtitleWidget: subtitleInfo.first,
          ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtpInputs(
                  otpLength: 6,
                  onChange: () {
                    setState(() {});
                  },
                  otpInputController: controller.otpInputController,
                  resendOtp: () async {
                    await controller.resendFamilyVerificationOtp();
                    showToast(
                      context: context,
                      text: controller.familyResendResponse?.message,
                    );
                    return controller.resendOtpState == NetworkState.loaded;
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
                  showProgressIndicator: controller.verifyFamilyMemberState ==
                      NetworkState.loading,
                  disabledColor: ColorConstants.lightGrey,
                  text: 'Confirm',
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        color: isButtonDisabled
                            ? ColorConstants.darkGrey
                            : ColorConstants.white,
                      ),
                  margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
                  onPressed: () async {
                    await controller.verifyFamilyMembers();

                    setState(() {
                      canShowToast = true;
                    });

                    // show toast only 2 seconds
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        canShowToast = false;
                      });

                      if (controller.verifyFamilyMemberState ==
                          NetworkState.loaded) {
                        AutoRouter.of(context).push(
                          AddFamilySuccessRoute(
                            client: controller.client,
                            familyMember: controller.newFamilyMemberInfo,
                            mobileNumber: phoneNumber,
                          ),
                        );
                      }
                    });
                  },
                ),
                OtpToast(
                  canShowToast: canShowToast,
                  isSuccess:
                      controller.verifyFamilyMemberState == NetworkState.loaded,
                  message:
                      controller.verifyFamilyMemberState == NetworkState.error
                          ? controller.verifyFamilyErrorMessage
                          : controller.familyVerifyResponse?.message ?? '',
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildHeaderText(
  //   BuildContext context,
  //   String phoneNumber,
  // ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Enter verfication code',
  //         style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: ColorConstants.black,
  //             ),
  //       ),
  //       SizedBox(
  //         height: 6,
  //       ),
  //       RichText(
  //         text: TextSpan(
  //           children: [
  //             TextSpan(
  //               text:
  //                   'A verification code has been sent to your client’s \nphone number ',
  //               style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
  //                   color: ColorConstants.secondaryBlack, height: 1.4),
  //             ),
  //             TextSpan(
  //               text: '${phoneNumber}',
  //               style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
  //                     color: ColorConstants.black,
  //                     height: 1.4,
  //                   ),
  //             ),
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }

  List getSubtitleInfo(BuildContext context) {
    final span = TextSpan(
      children: [
        TextSpan(
          text:
              'A verification code has been sent to your client’s \nphone number ',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.secondaryBlack, height: 1.4),
        ),
        TextSpan(
          text: '${phoneNumber}',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                height: 1.4,
              ),
        ),
      ],
    );
    Widget subtitleWidget = RichText(text: span);
    final height = getTextHeight(span);
    return [subtitleWidget, height];
  }
}
