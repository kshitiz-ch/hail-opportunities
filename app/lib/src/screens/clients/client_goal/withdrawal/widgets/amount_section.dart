import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AmountSection extends StatelessWidget {
  const AmountSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawalController>(
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
              _buildMaxAmountUnitsText(context, controller),
              _buildFullNote(context, controller),
              if (controller.partialWithdrawalDisabled)
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Please Note: Partial Withdrawal is disabled as your fund balance is below the minimum withdrawal amount ${WealthyAmount.currencyFormatWithoutTrailingZero(controller.minWithdrawalAmt, 1)}",
                    textAlign: TextAlign.center,
                    style: context.headlineSmall!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueRadioButtons(WithdrawalController controller) {
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
        items: controller.partialWithdrawalDisabled
            ? [OrderValueType.Full]
            : OrderValueType.values,
        selectedValue: controller.valueTypeSelected,
      ),
    );
  }

  Widget _buildAmountInput(
      BuildContext context, WithdrawalController controller) {
    bool isValueTypeUnits =
        controller.valueTypeSelected != OrderValueType.Amount;
    final hideSuffixIcon = controller.amountController.text.isNullOrEmpty ||
        controller.valueTypeSelected == OrderValueType.Full;
    return SimpleTextFormField(
      contentPadding: EdgeInsets.only(bottom: 8),
      enabled: controller.valueTypeSelected != OrderValueType.Full,
      prefixIconSize: Size(10, 28),
      controller: controller.amountController,
      focusNode: controller.amountInputFocusNode,
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

  Widget _buildMaxAmountUnitsText(
      BuildContext context, WithdrawalController controller) {
    if (controller.valueTypeSelected == OrderValueType.Full) {
      return SizedBox();
    }
    bool isValueTypeUnits =
        controller.valueTypeSelected != OrderValueType.Amount;
    FolioModel? folioOverview = controller
        .dropdownSelectedScheme!.values.first.schemeData.folioOverview;

    String maxValue;
    if (isValueTypeUnits) {
      maxValue =
          (folioOverview?.withdrawalUnitsAvailable ?? 0).toStringAsFixed(3);
    } else {
      maxValue = WealthyAmount.currencyFormat(
        folioOverview?.withdrawalAmountAvailable,
        2,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  'Maximum Withdrawable ${isValueTypeUnits ? 'Units' : 'Amount'} ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            TextSpan(
              text: maxValue,
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

  Widget _buildFullNote(BuildContext context, WithdrawalController controller) {
    final showFullNote = controller.valueTypeSelected != OrderValueType.Full;
    if (!showFullNote) {
      return SizedBox();
    }

    bool isPlaceFullOrder = false;
    final isValid = controller.isFormValid;

    if (isValid) {
      final valueEntered =
          WealthyCast.toDouble(controller.amountController.text) ?? 0;
      final folioOverview = controller
          .dropdownSelectedScheme!.values.first.schemeData.folioOverview!;
      final maxAmount = folioOverview.withdrawalAmountAvailable ?? 0;
      final maxUnits = folioOverview.withdrawalUnitsAvailable ?? 0;
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
        : 'To withdraw the full ${isAmountOrder ? 'amount' : 'units'}, choose Order Type Full.';

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
