import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportFormSection extends StatelessWidget {
  final ReportDateType inputType;
  late TextStyle hintStyle;
  late TextStyle textStyle;

  ReportFormSection({Key? key, required this.inputType}) : super(key: key);
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
    return GetBuilder<ClientReportController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (inputType == ReportDateType.SingleDate ||
                inputType == ReportDateType.IntervalDate)
              _buildDatePickerField(
                textController: controller.investmentDate1Controller!,
                context: context,
                label: inputType == ReportDateType.SingleDate
                    ? 'Investment as on'
                    : 'Transactions from',
                onTap: (date) {
                  controller.updateInvestmentDate1(date);
                },
              ),
            if (inputType == ReportDateType.IntervalDate)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: _buildDatePickerField(
                  textController: controller.investmentDate2Controller!,
                  context: context,
                  label: 'Transactions till',
                  onTap: (date) {
                    controller.updateInvestmentDate2(date);
                  },
                ),
              ),
            if (inputType == ReportDateType.SingleYear)
              _buildYearDropDown(controller),
          ],
        );
      },
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController textController,
    required BuildContext context,
    required String label,
    required Function(DateTime) onTap,
  }) {
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
          firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
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

  Widget _buildYearDropDown(ClientReportController controller) {
    final currentYear = DateTime.now().year;
    return SimpleDropdownFormField<String>(
      hintText: 'Financial year',
      dropdownMaxHeight: 500,
      customText: (value) {
        final year = int.parse(value!);
        final financialYear = '$year - ${year + 1}';
        return financialYear;
      },
      items: List.generate(10, (index) => (currentYear - index).toString()),
      value: controller.financialYear,
      borderRadius: 15,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      label: 'Financial year',
      onChanged: (val) {
        if (val.isNotNullOrEmpty) {
          controller.updateFinancialYear(val!);
        }
      },
      validator: (val) {
        if (val.isNullOrEmpty) {
          return 'Financial year is required.';
        }
        return null;
      },
    );
  }
}
