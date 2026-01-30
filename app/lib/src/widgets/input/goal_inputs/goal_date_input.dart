import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalDateInput extends StatelessWidget {
  const GoalDateInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.onDateSelect,
    this.startDate,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final Function(DateTime date) onDateSelect;
  final DateTime? startDate;

  @override
  Widget build(BuildContext context) {
    TextStyle hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    TextStyle textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );

    DateTime initialDate;

    // For Initial end date
    if (startDate != null) {
      initialDate = startDate!.add(Duration(days: 1));

      // If initial date is already passed (happens, if start date is passed),
      // then initial end date should be today
      if (initialDate.isBefore(DateTime.now())) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    return SimpleTextFormField(
      controller: controller,
      useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      label: label,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: true,
      textInputAction: TextInputAction.next,
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        size: 16.0,
        color: ColorConstants.tertiaryGrey,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          initialDate: initialDate,
          firstDate: initialDate,
          lastDate: DateTime.now().add(Duration(days: 365 * 30)),
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
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          onDateSelect(pickedDate);
        }
      },
      validator: (value) {
        if (value?.isNullOrEmpty ?? true) {
          return 'This field is required.';
        }

        return null;
      },
    );
  }
}
