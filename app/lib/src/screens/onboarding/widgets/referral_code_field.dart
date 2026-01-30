import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/onboarding/register_controller.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ReferralCodeInviteField extends StatefulWidget {
  @override
  State<ReferralCodeInviteField> createState() =>
      _ReferralCodeInviteFieldState();
}

class _ReferralCodeInviteFieldState extends State<ReferralCodeInviteField> {
  bool showReferralCode = false;
  bool showInfo = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReferralCTA(),
            SizedBox(height: 10),
            if (showReferralCode) _buildReferralInput(controller),
          ],
        );
      },
    );
  }

  Widget _buildReferralCTA() {
    return ClickableText(
      text: 'Have a referral code ?',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      suffixIcon: Icon(
        !showReferralCode ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
        size: 20,
        color: ColorConstants.primaryAppColor,
      ),
      onClick: () {
        setState(() {
          showReferralCode = !showReferralCode;
        });
      },
    );
  }

  Widget _buildReferralInput(RegisterController controller) {
    final isInviteCodeAppliedSuccess =
        controller.validateReferralCodeResponse.isLoaded;
    final isInviteCodeAppliedError =
        controller.validateReferralCodeResponse.isError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            BorderedTextFormField(
              hintStyle: context.headlineSmall!.copyWith(
                color: ColorConstants.darkGrey,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                    '[0-9a-zA-Z]',
                  ),
                ),
                UpperCaseTextFormatter(),
              ],
              // textCapitalization just switches user's keyboard
              //to uppercase but user can switch back to lowercase.
              // Formatter solution is much better
              enabled: !isInviteCodeAppliedSuccess,

              keyboardType: TextInputType.text,
              prefixIcon: isInviteCodeAppliedSuccess
                  ? Padding(
                      padding: EdgeInsets.only(left: 18.0),
                      child: Row(
                        children: [
                          Text(
                            controller.inviteCodeController!.text.toUpperCase(),
                            style: context.headlineSmall!.copyWith(
                              color: ColorConstants.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: isInviteCodeAppliedSuccess
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: ColorConstants.greenAccentColor,
                                  )
                                : null,
                          )
                        ],
                      ),
                    )
                  : null,
              hintText: 'Enter code (if any) ',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.validateReferralCodeResponse.isLoading)
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (!isInviteCodeAppliedSuccess)
                    ClickableText(
                      onClick: () {
                        if (!controller
                            .validateReferralCodeResponse.isLoading) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          controller.validateReferralCode();
                        }
                      },
                      text: 'Apply',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textColor:
                          controller.inviteCodeController!.text.isNullOrEmpty
                              ? ColorConstants.tertiaryBlack
                              : ColorConstants.primaryAppColor,
                    ),
                  // space for info icon on stack
                  SizedBox(width: 50),
                ],
              ),
              onChanged: (val) {
                if (isInviteCodeAppliedError && val.isNotNullOrEmpty) {
                  //make the referralState cancelled once
                  //the user starts changing an already entered incorrect referral code
                  controller.validateReferralCodeResponse.state =
                      NetworkState.cancel;
                }
                controller.update();
              },
              controller: controller.inviteCodeController,
              textInputAction: TextInputAction.next,
              validator: (value) {
                return null;
              },
            ),
            // stack widget is required because if textfield not enabled due to success
            // ontap wont work
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    if (!showInfo) {
                      showInfo = true;
                    }
                  });
                },
                icon: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
            )
          ],
        ),
        if (isInviteCodeAppliedSuccess || isInviteCodeAppliedError)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              controller.validateReferralCodeResponse.message,
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isInviteCodeAppliedSuccess
                    ? ColorConstants.greenAccentColor
                    : ColorConstants.errorColor,
                height: 1.4,
              ),
            ),
          ),
        if (showInfo)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildShowInfo(),
          ),
      ],
    );
  }

  Widget _buildShowInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorConstants.borderColor)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Referral codes help us track who referred you. Using a referral code has no impact on your earnings or commissions.',
              style: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              setState(() {
                showInfo = false;
              });
            },
            icon: Icon(
              Icons.close,
              size: 20,
              color: ColorConstants.tertiaryBlack,
            ),
          )
        ],
      ),
    );
  }
}
