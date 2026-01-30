import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/delete_partner_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class AccountDeleteAcknowledgementBottomSheet extends StatelessWidget {
  final Function? onClick;

  const AccountDeleteAcknowledgementBottomSheet({Key? key, this.onClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete Account Initiated',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 45),
            child: Text.rich(
              TextSpan(
                text:
                    'Your account deletion request has been registered. Account will be permanently deleted within 1-5 working days. You will not receive revenue after your account is deleted and your clients\nwill be deassigned.\n\n',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w400,
                        ),
                children: [
                  TextSpan(
                    text: 'THIS CANNOT BE UNDONE.',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.errorTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ActionButton(
            text: 'Got It',
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          )
        ],
      ),
    );
  }
}

class AccountDeleteConfirmationBottomSheet extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();
  AccountDeleteConfirmationBottomSheet({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Padding(
        padding: EdgeInsets.only(top: 30.0, bottom: isKeyboardVisible ? 50 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Are you sure you want to Delete\nyour Account ?',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                          height: 24 / 16,
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40)
                  .copyWith(top: 16, bottom: 24),
              child: Text(
                'Type “DELETE” in the folowing space to\ndelete your wealthy account',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w400,
                          height: 17 / 14,
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SimpleTextFormField(
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.black,
                          height: 17 / 14,
                        ),
                contentPadding: EdgeInsets.only(bottom: 12, top: 6),
                label: 'Type “Delete”',
                controller: textEditingController,
                onSubmitted: (value) {},
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.lightRedColor,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                  .copyWith(bottom: 24),
              padding: EdgeInsets.all(16),
              child: Text.rich(
                TextSpan(
                  text: '',
                  children: [
                    WidgetSpan(
                      child: Image.asset(
                        AllImages().alertIcon,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    TextSpan(
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.errorTextColor,
                          ),
                      text:
                          'Your Wealthy partner account will be deleted permanently.',
                    ),
                    TextSpan(
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.errorTextColor,
                          ),
                      text:
                          '\nAfter deletion you will not receive any revenue and your clients will be de-assigned.',
                    )
                  ],
                ),
              ),
            ),
            GetBuilder<DeletePartnerController>(builder: (controller) {
              return ActionButton(
                text: 'Delete Account',
                showProgressIndicator: controller.deletePartnerRequestState ==
                    NetworkState.loading,
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                onPressed: () async {
                  if (textEditingController.text.isNotNullOrEmpty &&
                      textEditingController.text.toLowerCase() == 'delete') {
                    await controller.deletePartner();
                    showToast(
                        text: controller.deletePartnerRequestMessage,
                        context: context);
                    AutoRouter.of(context).popForced();
                    if (controller.deletePartnerRequestState ==
                        NetworkState.loaded) {
                      CommonUI.showBottomSheet(context,
                          child: AccountDeleteAcknowledgementBottomSheet());
                    }
                  } else {
                    showToast(
                      text: 'Type “DELETE” to delete your wealthy account',
                      context: context,
                    );
                  }
                },
              );
            })
          ],
        ),
      );
    });
  }
}
