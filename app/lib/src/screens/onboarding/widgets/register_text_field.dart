import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/partner_verification_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerVerificationController>(
        builder: (PartnerVerificationController controller) {
      return Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildOnboardingSimpleTextField(
              buildContext: context,
              helperText: 'Email ID needs to be verified',
              helperStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.darkGrey,
                      ),
              labelText: 'Email ID',
              keyboardType: TextInputType.emailAddress,
              controller: controller.emailController,
            ),
          ],
        ),
      );
    });
  }
}
