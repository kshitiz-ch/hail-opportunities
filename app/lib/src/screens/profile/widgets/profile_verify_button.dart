import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileVerifyButton extends StatelessWidget {
  const ProfileVerifyButton({Key? key, this.fieldValue, this.fieldName})
      : super(key: key);

  final String? fieldValue;
  final String? fieldName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: fieldName,
      builder: (controller) {
        bool isLoading =
            controller.getVerificationRequestIdState == NetworkState.loading ||
                controller.sendVerificationState == NetworkState.loading;

        return InkWell(
          onTap: () async {
            await controller.getPartnerVerificationRequestId(fieldName!);

            if (controller.getVerificationRequestIdState ==
                NetworkState.loaded) {
              await controller.sendPartnerVerificationOtp(
                  fieldName!, fieldValue);

              if (controller.sendVerificationState == NetworkState.loaded) {
                AutoRouter.of(context).push(
                  PartnerVerificationRoute(
                      verifyFieldValue: fieldValue,
                      requestId: controller.verificationRequestId,
                      isEmail: fieldName == "email"),
                );
              } else {
                return showToast(text: 'This feature is not available now');
              }
            } else if (controller.getVerificationRequestIdState ==
                NetworkState.error) {
              return showToast(text: 'This feature is not available now');
            }
          },
          child: isLoading
              ? _buildLoadingIndicator()
              : Text(
                  "Verify",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelLarge!
                      .copyWith(
                          color: ColorConstants.primaryAppColor, fontSize: 14),
                ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: EdgeInsets.only(left: 8),
      width: 10,
      height: 10,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}
