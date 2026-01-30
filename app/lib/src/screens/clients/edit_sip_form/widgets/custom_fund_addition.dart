import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomFundAddition extends StatefulWidget {
  @override
  State<CustomFundAddition> createState() => _CustomFundAdditionState();
}

class _CustomFundAdditionState extends State<CustomFundAddition> {
  TextStyle? hintStyle;
  TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    hintStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    textStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
    return Padding(
      padding: const EdgeInsets.all(30).copyWith(
        bottom: max(30, MediaQuery.of(context).viewInsets.bottom),
      ),
      child: GetBuilder<ClientEditSipController>(
        builder: (ClientEditSipController controller) {
          if (controller.customFundsResponse.state == NetworkState.loading) {
            return SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.customFundsResponse.state == NetworkState.error) {
            return SizedBox(
              height: 300,
              child: Center(
                child: RetryWidget(
                  controller.customFundsResponse.message,
                  onPressed: () {
                    controller.getCustomFundsData();
                  },
                ),
              ),
            );
          }
          if (controller.customFundsResponse.state == NetworkState.loaded) {
            if (controller.customFundsData!.schemeMetas.isNullOrEmpty) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    'No funds available to add',
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                ),
              );
            }
            return Form(
              key: controller.editFundFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Fund',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          color: ColorConstants.black,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildChooseFundDropDown(controller),
                  ),
                  _buildAmountTextField(controller),
                  _buildAddFundCTA(controller),
                ],
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }

  Widget _buildChooseFundDropDown(ClientEditSipController controller) {
    return SimpleDropdownFormField<String>(
      hintText: 'Choose Fund',
      useLabelAsHint: false,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      value: controller.selectedCustomFund?.displayName,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      borderRadius: 15,
      items: List<String>.generate(
          controller.customFundsData!.schemeMetas!.length,
          (index) =>
              controller.customFundsData!.schemeMetas![index].displayName ??
              ''),
      onChanged: (value) {
        controller.onSelectCustomFund(value);
      },
    );
  }

  Widget _buildAmountTextField(ClientEditSipController controller) {
    return SimpleTextFormField(
      controller: controller.customFundAmountController,
      keyboardType: TextInputType.number,
      label: 'Enter Amount',
      useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.borderColor,
      style: textStyle,
      prefixIconSize: Size(20, 30),
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      prefixIcon: Align(
        alignment: Alignment.bottomLeft,
        child: Text("\₹ "),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onSubmitted: (value) {},
      onChanged: (value) {
        controller.onChangeCustomFundAmountController(value);
      },
      validator: (value) {
        if (value.isNullOrEmpty) {
          return 'Amount is required.';
        }
        final minSipAmount = controller.selectedCustomFund?.minSipDepositAmt;
        if (minSipAmount.isNotNullOrZero) {
          double amount = value![0] == '₹'
              ? double.parse(value.substring(2).replaceAll(',', ''))
              : double.parse(value.replaceAll(',', ''));
          if (amount < minSipAmount!) {
            return 'Min Sip Amount is $minSipAmount';
          }
        }

        return null;
      },
    );
  }

  Widget _buildAddFundCTA(ClientEditSipController controller) {
    return ActionButton(
      text: 'Add Fund',
      margin: EdgeInsets.symmetric(vertical: 30),
      isDisabled: controller.selectedCustomFund == null,
      onPressed: () {
        if (controller.editFundFormKey.currentState!.validate()) {
          final text = controller.customFundAmountController.text;
          double amount = text.isEmpty
              ? 0
              : text[0] == '₹'
                  ? double.parse(text.substring(2).replaceAll(',', ''))
                  : double.parse(text.replaceAll(',', ''));
          controller.selectedCustomFund!.amountEntered = amount;
          controller.addCustomFunds();
          AutoRouter.of(context).popForced();
        }
      },
    );
  }
}
