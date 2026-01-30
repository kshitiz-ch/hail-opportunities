import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class AmountTextFieldShowCase extends StatefulWidget {
  // Fields
  final TextEditingController? controller;
  final FocusNode focusNode;
  final EdgeInsets scrollPadding;
  final Function(String)? onChanged;
  final TextStyle? labelStyle;
  final double? minAmount;
  final String Function(String)? validator;
  final bool showIncrement;
  final Widget? captionWidget;
  final bool showAmountLabel;
  final Function? onClickFinished;

  // Constructor
  const AmountTextFieldShowCase(
      {Key? key,
      required this.controller,
      required this.focusNode,
      this.scrollPadding = const EdgeInsets.all(20.0),
      this.onChanged,
      this.minAmount,
      this.validator,
      this.captionWidget,
      this.showIncrement = true,
      this.showAmountLabel = true,
      this.onClickFinished,
      this.labelStyle})
      : super(key: key);

  @override
  State<AmountTextFieldShowCase> createState() =>
      AmountTextFieldShowCaseState();
}

class AmountTextFieldShowCaseState extends State<AmountTextFieldShowCase> {
  Key showCaseWrapperKey = UniqueKey();
  late ShowCaseController showCaseController;

  void initState() {
    if (Get.isRegistered<ShowCaseController>()) {
      showCaseController = Get.find<ShowCaseController>();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId != showCaseIds.AmountTextField.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              widget.onClickFinished!();
            });
            return SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showAmountLabel)
                Text(
                  'Amount',
                  style: widget.labelStyle ??
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.4,
                            color: ColorConstants.black,
                          ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ShowCaseWidget(
                  disableScaleAnimation: true,
                  disableBarrierInteraction: false,
                  onStart: (index, key) {},
                  onFinish: () async {
                    if (showCaseController.activeShowCaseId ==
                        showCaseIds.AmountTextField.id) {
                      await showCaseController.setActiveShowCase();
                      widget.onClickFinished!();
                    }
                  },
                  builder: (context) {
                    return ShowCaseWrapper(
                      key: showCaseWrapperKey,
                      focusNode: widget.focusNode,
                      onTargetClick: () async {
                        if (showCaseController.activeShowCaseId ==
                            showCaseIds.AmountTextField.id) {
                          await showCaseController.setActiveShowCase();
                          widget.onClickFinished!();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.focusNode.requestFocus();
                          });
                        }
                      },
                      extraSpacing:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      rippleExpandingHeight: 56,
                      rippleExpandingWidth: MediaQuery.of(context).size.width,
                      currentShowCaseId: showCaseIds.AmountTextField.id,
                      minRadius: 5,
                      maxRadius: 10,
                      constraints: BoxConstraints(
                        maxHeight: 66,
                        minHeight: 46,
                        maxWidth: MediaQuery.of(context).size.width + 10,
                        minWidth: MediaQuery.of(context).size.width - 60,
                      ),
                      child: Container(
                        color: Colors.white,
                        key: showCaseWrapperKey,
                        child: _buildTextForm(widget.onClickFinished),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: widget.captionWidget ?? _buildMinAmountText(context),
              ),
            ],
          );
        });
  }

  Widget _buildMinAmountText(context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Minimum Purchase Amount',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.4,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          TextSpan(
            text: WealthyAmount.currencyFormat(widget.minAmount, 0),
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

  Widget _buildTextForm(Function? onClickFinished) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator != null
          ? (value) {
              return widget.validator!(value!.replaceAll(',', ''));
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
      scrollPadding: widget.scrollPadding,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(bottom: 5),
        suffix: widget.showIncrement
            ? Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorConstants.primaryAppColor)),
                child: ClickableText(
                  text: '+1,000',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  onClick: () {
                    String enteredAmount = (widget.controller?.value.text ?? '')
                        .replaceAll(',', '')
                        .trim()
                        .replaceAll('₹', '');
                    final amount = 1000 +
                        (enteredAmount.isNullOrEmpty
                            ? 0
                            : WealthyCast.toInt(enteredAmount)!);
                    final string =
                        '${WealthyAmount.formatNumber(amount.toString())}';
                    widget.controller!.value =
                        widget.controller!.value.copyWith(
                      text: '$string',
                      selection: TextSelection.collapsed(offset: string.length),
                    );
                  },
                ),
              )
            : null,
        // ToDo: show it always
        prefix: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            '₹',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                  height: 1.4,
                ),
          ),
        ),
        hintText: 'Enter Amount',
        hintStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.secondaryLightGrey,
              height: 1.4,
            ),
        isDense: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Text("\₹ "),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      onTap: () async {
        String activeShowCaseId = showCaseController.activeShowCaseId;

        if (activeShowCaseId == showCaseIds.AmountTextField.id) {
          await showCaseController.setActiveShowCase();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.focusNode.requestFocus();
          });
          onClickFinished!();
        }
      },
      onChanged: (string) {
        if (string.isEmpty) {
        } else {
          if (string[0] == '₹') {
            string = string.substring(2);
          }

          if (string.length > 1 && double.parse(string) > 999) {
            string = '${WealthyAmount.formatNumber(string)}';
          }
          widget.controller!.value = widget.controller!.value.copyWith(
            text: '$string',
            selection: TextSelection.collapsed(offset: string.length),
          );
        }
        widget.onChanged != null
            ? widget.onChanged!(string.replaceAll(',', ''))
            : null;
      },
    );
  }
}
