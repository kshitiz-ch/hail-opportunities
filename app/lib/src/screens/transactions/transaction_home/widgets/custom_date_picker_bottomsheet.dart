import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CustomDatePickerBottomsheet extends StatefulWidget {
  final Function({required DateTime startDate, required DateTime endDate})
      onContinue;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const CustomDatePickerBottomsheet({
    super.key,
    required this.onContinue,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<CustomDatePickerBottomsheet> createState() =>
      _CustomDatePickerBottomsheetState();
}

class _CustomDatePickerBottomsheetState
    extends State<CustomDatePickerBottomsheet> {
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialStartDate;
    toDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Custom Dates',
                style: context.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: _buildDatePickerField(
              textController: TextEditingController(
                text: fromDate == null ? null : getFormattedDate(fromDate),
              ),
              context: context,
              label: 'Transactions from',
              onTap: (date) {
                setState(() {
                  fromDate = date;
                });
              },
            ),
          ),
          _buildDatePickerField(
            textController: TextEditingController(
              text: toDate == null ? null : getFormattedDate(toDate),
            ),
            context: context,
            label: 'Transactions till',
            onTap: (date) {
              setState(() {
                toDate = date;
              });
            },
          ),
          Spacer(),
          _buildCTA()
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController textController,
    required BuildContext context,
    required String label,
    required Function(DateTime) onTap,
  }) {
    final hintStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.tertiaryBlack,
      height: 0.7,
    );
    final textStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    return SimpleTextFormField(
      controller: textController,
      useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      label: label,
      readOnly: true,
      textInputAction: TextInputAction.next,
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        size: 16.0,
        color: ColorConstants.primaryAppColor,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('en', 'IN'),
          fieldHintText: label,
          initialDatePickerMode: DatePickerMode.year,
          context: context,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorConstants.primaryAppColor,
                  onPrimary: ColorConstants.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          onTap(pickedDate);
        }
      },
      validator: (value) {
        if (value.isNullOrEmpty) {
          return '$label is required.';
        }

        return null;
      },
    );
  }

  Widget _buildCTA() {
    return ActionButton(
      text: 'Continue',
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      isDisabled: fromDate == null || toDate == null,
      onPressed: () {
        if (toDate!.isBefore(fromDate!)) {
          showToast(text: 'To Date cannot be earlier than From Date');
          return;
        }
        widget.onContinue(startDate: fromDate!, endDate: toDate!);
        AutoRouter.of(context).popForced();
      },
    );
  }
}
