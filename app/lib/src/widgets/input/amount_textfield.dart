import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTextField extends StatelessWidget {
  // Fields
  final TextEditingController? controller;
  final EdgeInsets scrollPadding;
  final Function(String)? onChanged;
  final TextStyle? labelStyle;
  final double? minAmount;
  final String? Function(String)? validator;
  final bool showIncrement;
  final Widget? captionWidget;
  final bool showAmountLabel;
  final FocusNode? focusNode;
  final String? minAmountLabel;
  final AutovalidateMode? autoValidateMode;
  final bool? enabled;

  // Constructor
  const AmountTextField({
    Key? key,
    required this.controller,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.onChanged,
    this.minAmount,
    this.validator,
    this.captionWidget,
    this.showIncrement = true,
    this.showAmountLabel = true,
    this.focusNode,
    this.labelStyle,
    this.autoValidateMode,
    this.minAmountLabel,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAmountLabel)
          Text(
            'Amount',
            style: labelStyle ??
                Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: ColorConstants.black,
                    ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextFormField(
            enabled: enabled,
            focusNode: focusNode,
            controller: controller,
            autovalidateMode: autoValidateMode,
            validator: validator != null
                ? (value) {
                    return validator!(value!.replaceAll(',', ''));
                  }
                : null,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
            textAlign: TextAlign.left,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            scrollPadding: scrollPadding,
            decoration: InputDecoration(
              errorMaxLines: 4,
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium!
                  .copyWith(color: ColorConstants.redAccentColor),
              contentPadding: EdgeInsets.only(bottom: 10),
              suffix: showIncrement
                  ? Container(
                      padding: EdgeInsets.all(5),
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //         color: ColorConstants.primaryAppColor)),
                      child: ClickableText(
                        text: '+1,000',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        onClick: () {
                          String enteredAmount = (controller?.value.text ?? '')
                              .replaceAll(',', '')
                              .trim()
                              .replaceAll('₹', '');
                          final amount = 1000 +
                              (enteredAmount.isNullOrEmpty
                                  ? 0
                                  : WealthyCast.toInt(enteredAmount)!);
                          final string =
                              '${WealthyAmount.formatNumber(amount.toString())}';
                          controller!.value = controller!.value.copyWith(
                            text: '$string',
                            selection:
                                TextSelection.collapsed(offset: string.length),
                          );
                          onChanged != null
                              ? onChanged!(string.replaceAll(',', ''))
                              : null;
                        },
                      ),
                    )
                  : null,
              // ToDo: show it always
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text("\₹ "),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: 'Enter Amount',
              hintStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.secondaryLightGrey,
                        height: 1.4,
                      ),
            ),
            onChanged: (string) {
              if (string.isEmpty) {
              } else {
                if (string[0] == '₹') {
                  string = string.substring(2);
                }

                if (string.length > 1 && double.parse(string) > 999) {
                  string = '${WealthyAmount.formatNumber(string)}';
                }
                controller!.value = controller!.value.copyWith(
                  text: '$string',
                  selection: TextSelection.collapsed(offset: string.length),
                );
              }
              onChanged != null ? onChanged!(string.replaceAll(',', '')) : null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: captionWidget ?? _buildMinAmountText(context),
        ),
      ],
    );
  }

  Widget _buildMinAmountText(context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: minAmountLabel ?? 'Minimum Purchase Amount ',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          TextSpan(
            text: WealthyAmount.currencyFormat(minAmount, 0),
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.black,
                ),
          )
        ],
      ),
    );
  }
}
