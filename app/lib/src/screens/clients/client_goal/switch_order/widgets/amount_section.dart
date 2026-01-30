import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AmountSection extends StatelessWidget {
  const AmountSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwitchOrderController>(
      id: GetxId.schemeForm,
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Choose Order Type',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              _buildValueRadioButtons(controller),
              _buildAmountInput(context, controller),
              _buildMinAmountText(context, controller),
              _buildFullNote(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueRadioButtons(SwitchOrderController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 32),
      child: RadioButtons(
        onTap: (value) {
          controller.updateValueTypeSelected(value);
        },
        itemBuilder: (BuildContext context, dynamic value, int index) {
          return Text(
            (value as OrderValueType).name,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.black,
                ),
          );
        },
        items: OrderValueType.values,
        selectedValue: controller.valueTypeSelected,
      ),
    );
  }

  Widget _buildAmountInput(
      BuildContext context, SwitchOrderController controller) {
    bool isValueTypeUnits =
        controller.valueTypeSelected != OrderValueType.Amount;
    final hideSuffixIcon = controller.amountController.text.isNullOrEmpty ||
        controller.valueTypeSelected == OrderValueType.Full;
    return SimpleTextFormField(
      contentPadding: EdgeInsets.only(bottom: 8),
      enabled: controller.valueTypeSelected != OrderValueType.Full,
      prefixIconSize: Size(10, 28),
      focusNode: controller.amountInputFocusNode,
      controller: controller.amountController,
      prefixIcon: isValueTypeUnits
          ? null
          : Align(
              alignment: Alignment.bottomLeft,
              child: Text("\₹ "),
            ),
      label: controller.valueTypeSelected == OrderValueType.Full
          ? 'Available Units'
          : 'Enter ${isValueTypeUnits ? 'Units' : 'Amount'}',
      useLabelAsHint: true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        if (!isValueTypeUnits) FilteringTextInputFormatter.digitsOnly,
        NoLeadingSpaceFormatter(),
      ],
      maxLength: 10,
      hideCounterText: true,
      suffixIcon: hideSuffixIcon
          ? null
          : IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.clear,
                size: 20.0,
                color: ColorConstants.black,
              ),
              onPressed: () {
                controller.amountController.clear();
              },
            ),
      borderColor: ColorConstants.borderColor,
      onChanged: (_) {
        controller.update([GetxId.schemeForm]);
      },
      validator: (value) {
        return controller.validator(value);
      },
    );
  }

  Widget _buildMinAmountText(
      BuildContext context, SwitchOrderController controller) {
    if (controller.valueTypeSelected == OrderValueType.Full) {
      return SizedBox();
    }
    bool isValueTypeUnits =
        controller.valueTypeSelected != OrderValueType.Amount;
    String text;
    String value;
    if (isValueTypeUnits) {
      text = 'Max Units available for switch';
      value = (controller.dropdownSelectedScheme!.switchOut.units ?? 0)
          .toStringAsFixed(3);
    } else {
      text = 'Minimum Switch Amount';
      value = WealthyAmount.currencyFormat(
        controller.dropdownSelectedScheme!.switchIn?.minAmount,
        2,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$text ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            TextSpan(
              text: value,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.black,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFullNote(
      BuildContext context, SwitchOrderController controller) {
    final showFullNote = controller.valueTypeSelected != OrderValueType.Full;

    if (!showFullNote) {
      return SizedBox();
    }

    bool isPlaceFullOrder = false;
    final isValid = controller.isFormValid;
    if (isValid) {
      final valueEntered =
          WealthyCast.toDouble(controller.amountController.text) ?? 0;
      final maxAmount =
          controller.dropdownSelectedScheme?.switchOut.currentValue ?? 0;
      final maxUnits = controller.dropdownSelectedScheme?.switchOut.units ?? 0;
      isPlaceFullOrder = canPlaceFullOrder(
        inputValue: valueEntered,
        maxAmount: maxAmount.toInt(),
        maxUnits: maxUnits,
        orderType: controller.valueTypeSelected,
      );
    }

    final isAmountOrder = controller.valueTypeSelected == OrderValueType.Amount;

    final text = isPlaceFullOrder
        ? 'Entered ${isAmountOrder ? 'amount' : 'units'} is ${isAmountOrder ? 'close' : 'equal'} to the available ${isAmountOrder ? 'balance' : 'units'}. A full unit order will be placed.'
        : 'To switch the full ${isAmountOrder ? 'amount' : 'units'}, choose Order Type Full.';

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$text ',
              style: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.4,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
            // TextSpan(
            //   text: isPlaceFullOrder
            //       ? 'A full unit order will be placed.'
            //       : 'Full',
            //   style: context.titleLarge!.copyWith(
            //     fontWeight: FontWeight.w600,
            //     fontSize: 12,
            //     height: 1.4,
            //     color: ColorConstants.black,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
