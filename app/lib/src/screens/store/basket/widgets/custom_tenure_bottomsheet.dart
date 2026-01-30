import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_edit_fund_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTenureBottomSheet extends StatefulWidget {
  @override
  State<CustomTenureBottomSheet> createState() =>
      _CustomTenureBottomSheetState();
}

class _CustomTenureBottomSheetState extends State<CustomTenureBottomSheet> {
  final textEditingController = TextEditingController();
  bool isValidInput = false;

  int getYear(String text) {
    return WealthyCast.toInt(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter Custom Tenure in Years',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                CommonUI.bottomsheetCloseIcon(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: _buildTenureTextField(),
          ),
          _buildCTA(),
        ],
      ),
    );
  }

  Widget _buildTenureTextField() {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return SimpleTextFormField(
      contentPadding: EdgeInsets.only(bottom: 8),
      enabled: true,
      controller: textEditingController,
      label: 'Tenure',
      style: textStyle,
      useLabelAsHint: true,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      textInputAction: TextInputAction.next,
      borderColor: ColorConstants.lightGrey,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      prefixIconSize: Size(100, 36),
      suffixIcon: textEditingController.text.isEmpty
          ? null
          : Text(
              'Years',
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.black,
                  ),
            ),
      onChanged: (val) {
        setState(() {
          final tenure = getYear(val);
          isValidInput = tenure >= 1 && tenure <= 200;
        });
      },
      validator: (val) {
        return validateInput(val);
      },
    );
  }

  String? validateInput(String? value) {
    if (value.isNullOrEmpty) {
      return 'Tenure is required';
    }
    final tenureYear = getYear(value ?? '');
    if (tenureYear < 1) {
      return 'Minimum tenure is 1 year';
    }
    if (tenureYear > 200) {
      return 'Maximum tenure is 200 years';
    }
    return null;
  }

  Widget _buildCTA() {
    return GetBuilder<BasketEditFundController>(
      builder: (controller) {
        return ActionButton(
          text: 'Done',
          margin: EdgeInsets.all(30),
          isDisabled: !isValidInput,
          onPressed: () {
            controller.updateTenure(
              getYear(textEditingController.text),
              isCustomTenure: true,
            );
            // Pop CustomTenureBottomSheet
            AutoRouter.of(context).popForced();
            // pop SelectTenureBottomSheet
            AutoRouter.of(context).popForced();
          },
        );
      },
    );
  }
}
