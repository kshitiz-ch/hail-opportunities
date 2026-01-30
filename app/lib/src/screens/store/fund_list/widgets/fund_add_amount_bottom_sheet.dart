import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/amount_textfield_show_case.dart';

import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';

import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class FundAddAmountBottomSheet extends StatelessWidget {
  // fields
  final Function(double)? onPressed;
  final double? preFilledAmount;
  final String actionButtonText;
  final SchemeMetaModel? fund;
  final double? minAmount;
  final FocusNode focusNode = new FocusNode();

  // Constructor
  FundAddAmountBottomSheet({
    Key? key,
    this.onPressed,
    this.preFilledAmount,
    this.actionButtonText = 'Continue',
    this.fund,
    this.minAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddAmountBottomSheetController());

    return GetBuilder<AddAmountBottomSheetController>(
      initState: (_) {
        controller.amountController!
            .addListener(() => controller.update(['action-button']));

        // If [preFilledAmount] is not null, initialize
        // the amountController with [preFilledAmount]
        if (preFilledAmount != null) {
          controller.amount = preFilledAmount!;
        }
      },
      dispose: (_) => Get.delete<AddAmountBottomSheetController>(),
      builder: (controller) {
        ShowCaseController? showCaseController;
        if (Get.isRegistered<ShowCaseController>()) {
          showCaseController = Get.find<ShowCaseController>();
        }

        bool displayShowCaseWidget = showCaseController != null &&
            showCaseController.activeShowCaseId ==
                showCaseIds.AmountTextField.id;

        if (displayShowCaseWidget) {
          showCaseController.setShowCaseVisibleCurrently(true);
        }

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20.0, top: 32, left: 30),
                  child: Text(
                    "Enter Investment amount",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          color: ColorConstants.tertiaryBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (fund != null)
                  ListTile(
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    horizontalTitleGap: 12,
                    dense: true,
                    title: Text(
                      fund?.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontSize: 16.0,
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      '${fundTypeDescription(fund!.fundType)} ${fund!.category != null ? "| ${fund!.category}" : ""}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),

                // Amount TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(top: 16),
                  child: displayShowCaseWidget
                      ? AmountTextFieldShowCase(
                          controller: controller.amountController,
                          focusNode: focusNode,
                          minAmount: minAmount,
                          onClickFinished: () {
                            controller.update();
                          },
                        )
                      : AmountTextField(
                          controller: controller.amountController,
                          focusNode: focusNode,
                          minAmount: minAmount,
                        ),
                ),

                // "Suggested Amounts" Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(top: 32, bottom: 16),
                  child: Text(
                    "Suggested Amounts",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ),

                // Suggested Amounts ButtonBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      alignment: MainAxisAlignment.start,
                      buttonPadding: EdgeInsets.zero,
                      children: ['₹ 10,000', '₹ 15,000', '₹ 20,000', '₹ 25,000']
                          .map(
                            (amt) => SizedBox(
                              width: constraints.maxWidth / 4,
                              child: ActionButton(
                                bgColor: ColorConstants.secondaryWhite,
                                text: amt,
                                textStyle: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 12.0,
                                      height: 1.4,
                                      color: ColorConstants.tertiaryBlack,
                                      fontWeight: FontWeight.w400,
                                    ),
                                height: 36,
                                margin: EdgeInsets.only(right: 10),
                                borderRadius: 8.0,
                                onPressed: () {
                                  _updateAmount(
                                    controller.amountController!,
                                    amt.replaceAll('₹', '').trim(),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ),

                // Action Button
                KeyboardVisibilityBuilder(
                  builder: (_, isKeyboardVisible) {
                    return GetBuilder<AddAmountBottomSheetController>(
                      id: 'action-button',
                      dispose: (_) {
                        Get.delete<AddAmountBottomSheetController>();
                      },
                      builder: (controller) => ActionButton(
                        isDisabled: controller.amountController!.text.isEmpty,
                        text: actionButtonText,
                        margin: EdgeInsets.fromLTRB(
                          30,
                          80,
                          30,
                          16,
                        ),
                        borderRadius: isKeyboardVisible ? 0.0 : 30.0,
                        onPressed: () => onPressed!(controller.amount),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateAmount(TextEditingController controller, String amount) {
    controller.value = controller.value.copyWith(
      text: '${amount}',
      selection: TextSelection.collapsed(offset: amount.length),
    );
  }
}

class AddAmountBottomSheetController extends GetxController {
  // Fields
  TextEditingController? amountController;

  // Getters
  double get amount {
    if (amountController!.text.isEmpty) {
      return 0;
    } else if (amountController!.text[0] == '₹') {
      return double.parse(
          amountController!.text.substring(2).replaceAll(',', ''));
    } else {
      return double.parse(amountController!.text.replaceAll(',', ''));
    }
  }

  // Setters
  set amount(double amt) {
    String string = amt.toStringAsFixed(0);

    if (string.length > 1 && double.parse(string) > 9999) {
      string = '${WealthyAmount.formatNumber(string)}';
    }
    amountController!.value = amountController!.value.copyWith(
      text: '${string}',
      selection: TextSelection.collapsed(offset: string.length),
    );
  }

  @override
  void onInit() {
    amountController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    amountController!.dispose();
    super.dispose();
  }

  /// Reset [amountController]
  void resetAmount() {
    amountController!.clear();
  }
}
