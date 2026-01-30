import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class TransactionSortFilterBottomsheet extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected;
  final String title;

  const TransactionSortFilterBottomsheet({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.title,
  });

  @override
  State<TransactionSortFilterBottomsheet> createState() =>
      _TransactionSortFilterBottomsheetState();
}

class _TransactionSortFilterBottomsheetState
    extends State<TransactionSortFilterBottomsheet> {
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: SizeConfig().screenHeight * 0.8,
      ),
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: ColorConstants.black,
                ),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: RadioButtons(
              runSpacing: 24,
              spacing: 24,
              direction: Axis.vertical,
              selectedValue: selectedOption,
              items: widget.options,
              itemBuilder: (context, val, index) {
                return Text(
                  val,
                  style: context.headlineSmall?.copyWith(
                    color: selectedOption == val
                        ? ColorConstants.black
                        : ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
              onTap: (val) {
                setState(() {
                  selectedOption = val.toString();
                });
              },
            ),
          ),
          ActionButton(
            text: 'Confirm',
            margin: EdgeInsets.symmetric(vertical: 30),
            onPressed: () {
              widget.onOptionSelected(selectedOption);
            },
          )
        ],
      ),
    );
  }
}
