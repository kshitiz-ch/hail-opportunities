import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/newsletter_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscribeNewsLetterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsLetterController>(
      id: 'subscribe-newsletter',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscribe to our newsletter',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                  ),
                  CommonUI.bottomsheetCloseIcon(context),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Subscribe and Join a community of 90,000+ readers to stay in tune with markets',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset(
                  AllImages().subscribeNewsletterIcon,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: _buildEmailInput(context, controller),
              ),
              ActionButton(
                text: 'Subscribe',
                margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 24),
                showProgressIndicator:
                    controller.newsLetterSubscribeReponse.state ==
                        NetworkState.loading,
                isDisabled:
                    !_isValidEmail(controller.emailInputController.text),
                onPressed: () async {
                  await controller.subscribeNewsletter();
                  if (controller.newsLetterSubscribeReponse.state ==
                      NetworkState.loaded) {
                    AutoRouter.of(context).popForced();
                  }
                  showToast(
                      text: controller.newsLetterSubscribeReponse.message);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmailInput(
      BuildContext context, NewsLetterController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    return BorderedTextFormField(
      borderRadius: BorderRadius.circular(8),
      useLabelAsHint: true,
      enabled: true,
      controller: controller.emailInputController,
      label: 'Enter Email',
      hintText: 'Enter Email',
      style: style.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelStyle: style,
      hintStyle: style,
      inputFormatters: [
        NoLeadingSpaceFormatter(),
      ],
      suffixIcon: controller.emailInputController.text.isNullOrEmpty
          ? null
          : IconButton(
              icon: Icon(
                Icons.clear,
                size: 21.0,
                color: ColorConstants.darkGrey,
              ),
              onPressed: () {
                controller.emailInputController.clear();
                controller.update(['subscribe-newsletter']);
              },
            ),
      onChanged: (val) {
        controller.update(['subscribe-newsletter']);
      },
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value.isNullOrEmpty) {
          return 'Email is Required';
        }
        if (!_isValidEmail(value ?? '')) {
          return 'Please enter valid email';
        }
        return null;
      },
    );
  }

  bool _isValidEmail(String text) {
    return RegExp(
      r'(?<name>[a-zA-Z0-9]+)'
      r'@'
      r'(?<domain>[a-zA-Z0-9]+)'
      r'\.'
      r'(?<topLevelDomain>[a-zA-Z0-9]+)',
    ).hasMatch(text);
  }
}
