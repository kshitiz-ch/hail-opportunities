import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class ChangeReferralCodeBottomSheet extends StatelessWidget {
  const ChangeReferralCodeBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: GetxId.referralCode,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(30)
              .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Referral Code',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                  ),
                  CommonUI.bottomsheetCloseIcon(context)
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: CommonClientUI.borderTextFormField(
                  context,
                  controller: controller.referralCodeController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        "[0-9a-zA-Z]",
                      ),
                    ),
                    LengthLimitingTextInputFormatter(9),
                    NoLeadingSpaceFormatter()
                  ],
                  hintText: 'Referral Code',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Referral Code should be 4 to 9 characters',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 30),
                child: CommonUI.buildInfoText(
                  context,
                  "Changing the referral link will invalidate the previous one",
                ),
              ),
              ActionButton(
                showProgressIndicator:
                    controller.changeReferralCodeResponse.state ==
                        NetworkState.loading,
                onPressed: () async {
                  if (controller.referralCodeController.text.length < 4) {
                    return showToast(
                        text: 'Referral code should be 4 to 9 characters');
                  }

                  await controller.changeReferralCode();

                  if (controller.changeReferralCodeResponse.state ==
                      NetworkState.loaded) {
                    showToast(text: 'Referral Code updated Successfully');
                    AutoRouter.of(context).popForced();
                  } else if (controller.changeReferralCodeResponse.state ==
                      NetworkState.error) {
                    return showToast(
                        text: controller.changeReferralCodeResponse.message);
                  }
                },
                margin: EdgeInsets.zero,
                text: 'Update',
              )
            ],
          ),
        );
      },
    );
  }
}
