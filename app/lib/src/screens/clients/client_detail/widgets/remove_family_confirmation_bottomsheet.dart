import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class RemoveFamilyConfirmationBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? text;
  final String? ctaText;
  final bool? isClientPartOfFamily;
  final String? memberUserId;
  final TextEditingController textEditingController = TextEditingController();
  RemoveFamilyConfirmationBottomSheet({
    Key? key,
    this.title,
    this.subtitle,
    this.text,
    this.ctaText,
    this.isClientPartOfFamily,
    this.memberUserId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Padding(
        padding: EdgeInsets.only(
          top: 30.0,
          bottom:
              isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                title!,
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
                subtitle!,
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
                contentPadding: EdgeInsets.only(bottom: 6, top: 6),
                hintText: 'Type “$text”',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                hintStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: Color(0xff7E7E7E),
                          height: 0.7,
                        ),
                controller: textEditingController,
                onChanged: (value) {},
                onSubmitted: (value) {},
              ),
            ),
            GetBuilder<ClientFamilyController>(builder: (controller) {
              return ActionButton(
                text: ctaText,
                showProgressIndicator:
                    controller.removeFamilyState == NetworkState.loading,
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                onPressed: () async {
                  if (textEditingController.text.isNotNullOrEmpty &&
                      textEditingController.text.toLowerCase() ==
                          text!.toLowerCase()) {
                    await controller.removeFromFamily(
                      isClientPartOfFamily!,
                      memberUserId,
                    );

                    if (controller.removeFamilyState == NetworkState.loaded &&
                        Get.isRegistered<ClientDetailController>()) {
                      await Get.find<ClientDetailController>()
                          .getUserProfileViewData();
                    }

                    if (controller.removeFamilyState == NetworkState.loaded) {
                      showToast(
                        text: controller.removeFamilyResponse?.message ??
                            'Successfully removed',
                        context: context,
                      );
                      AutoRouter.of(context).popForced();
                    } else if (controller.removeFamilyState ==
                        NetworkState.error) {
                      showToast(
                        text: controller.removeFamilyErrorMessage ??
                            genericErrorMessage,
                        context: context,
                      );
                    }
                  } else {
                    showToast(
                      text: 'Type \"${text}\"',
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
