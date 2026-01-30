import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/bank_details_form_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/demat/demats_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class FloatingActionButtonSection extends StatelessWidget {
  final VoidCallback? onProceed;
  const FloatingActionButtonSection({
    Key? key,
    this.onProceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BankDetailsFormController>(
      builder: (controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.addBankDetailsState == NetworkState.loaded &&
                    !isKeyboardVisible)
                  const SizedBox(height: 16),
                ActionButton(
                  heroTag: kDefaultHeroTag,
                  isDisabled: controller.ifscState != NetworkState.loaded,
                  text: 'Continue',
                  showProgressIndicator:
                      controller.addBankDetailsState == NetworkState.loading,
                  margin: EdgeInsets.symmetric(
                    vertical: isKeyboardVisible ? 0 : 10.0,
                    horizontal: isKeyboardVisible ? 0 : 36.0,
                  ),
                  borderRadius: isKeyboardVisible ? 0.0 : 30.0,
                  onPressed: () async {
                    if (controller.bankDetailsFormKey.currentState!
                        .validate()) {
                      await controller.addBankDetails();

                      if (controller.addBankDetailsState ==
                          NetworkState.loaded) {
                        showToast(text: 'Bank Details updated');
                        try {
                          if (onProceed != null) {
                            DematsController dematsController =
                                Get.find<DematsController>();
                            dematsController.userBankAccounts
                                .insert(0, controller.bankAccountResult);

                            AutoRouter.of(context).popForced();
                            onProceed!();
                          } else {
                            Get.find<ClientDetailController>()
                                .isBankAccountUpdated = true;
                          }
                        } catch (error) {
                          LogUtil.printLog(error);
                        }
                      }

                      if (controller.addBankDetailsState ==
                          NetworkState.error) {
                        showToast(text: controller.addBankDetailsErrorMessage);
                      }
                    }
                  },
                ),
                if (controller.addBankDetailsState != NetworkState.loaded ||
                    onProceed == null)
                  SizedBox(
                    height: 40,
                    child: TextButton(
                      child: Text(
                        'Skip',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelLarge!
                            .copyWith(
                              fontSize: 14.0,
                              color: ColorConstants.primaryAppColor,
                            ),
                      ),
                      onPressed: () {
                        if (onProceed != null) {
                          AutoRouter.of(context).popForced();
                          onProceed!();
                        } else {}
                      },
                    ),
                  ),
                SizedBox(height: 10)
              ],
            );
          },
        );
      },
    );
  }
}
