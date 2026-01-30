import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorBottomSheet extends StatefulWidget {
  final ReportController controller;
  DateSelectorBottomSheet({Key? key, required this.controller})
      : super(key: key);

  @override
  State<DateSelectorBottomSheet> createState() =>
      _DateSelectorBottomSheetState();
}

class _DateSelectorBottomSheetState extends State<DateSelectorBottomSheet> {
  late TextStyle hintStyle;
  late TextStyle textStyle;

  late TextEditingController investmentDate1Controller;
  DateTime? investmentDate1;
  late TextEditingController investmentDate2Controller;
  DateTime? investmentDate2;
  late String financialYear;

  void initState() {
    if (widget.controller.investmentDate1 != null) {
      investmentDate1Controller = TextEditingController(
          text: DateFormat('dd MMM yyyy')
              .format(widget.controller.investmentDate1!));
      investmentDate1 = widget.controller.investmentDate1;
    } else {
      investmentDate1Controller = TextEditingController();
    }

    if (widget.controller.investmentDate2 != null) {
      investmentDate2Controller = TextEditingController(
          text: DateFormat('dd MMM yyyy')
              .format(widget.controller.investmentDate2!));
      investmentDate2 = widget.controller.investmentDate2;
    } else {
      investmentDate2Controller = TextEditingController();
    }

    financialYear = widget.controller.financialYear ?? '';
    super.initState();
  }

  void dispose() {
    investmentDate1Controller.clear();
    investmentDate2Controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ReportDateType dateType = widget.controller.dateType;
    hintStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    textStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
    final title = getReportInputTitle(dateType);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Spacer(),
                CommonUI.bottomsheetCloseIcon(context)
              ],
            ),
          ),
          if (dateType == ReportDateType.SingleDate ||
              dateType == ReportDateType.IntervalDate)
            _buildDatePickerField(
              textController: investmentDate1Controller,
              context: context,
              label: dateType == ReportDateType.SingleDate
                  ? 'Investment as on'
                  : 'Transactions from',
              onTap: (date) {
                investmentDate1Controller.text =
                    DateFormat('dd MMM yyyy').format(date);
                investmentDate1 = date;
                if (investmentDate2 != null && date.isAfter(investmentDate2!)) {
                  investmentDate2Controller.clear();
                  investmentDate2 = null;
                }
                setState(() {});
              },
            ),
          if (dateType == ReportDateType.IntervalDate)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: _buildDatePickerField(
                textController: investmentDate2Controller,
                context: context,
                initialDate: investmentDate1,
                label: 'Transactions till',
                onTap: (date) {
                  setState(() {
                    investmentDate2Controller.text =
                        DateFormat('dd MMM yyyy').format(date);
                    investmentDate2 = date;
                  });
                },
              ),
            ),
          if (dateType == ReportDateType.SingleYear)
            _buildYearDropDown(widget.controller),
          ActionButton(
            margin: EdgeInsets.symmetric(vertical: 30),
            text: 'Save',
            onPressed: () {
              if (dateType == ReportDateType.SingleYear) {
                if (financialYear.isNullOrEmpty) {
                  return showToast(text: "Please select year");
                }
                AutoRouter.of(context).popForced();
                widget.controller.updateFinancialYear(financialYear);
              }

              if (dateType == ReportDateType.SingleDate) {
                if (investmentDate1 == null) {
                  return showToast(text: "Please provide date");
                }
                AutoRouter.of(context).popForced();
                widget.controller.updateInvestmentDate1(investmentDate1!);
              }

              if (dateType == ReportDateType.IntervalDate) {
                if (investmentDate1 == null || investmentDate2 == null) {
                  return showToast(text: "Please provide date");
                }
                AutoRouter.of(context).popForced();
                widget.controller.updateInvestmentDate1(investmentDate1!);
                widget.controller.updateInvestmentDate2(investmentDate2!);
              }
            },
          )
          // if (inputType != ReportDateType.None)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 100),
          //     child: ReportFormSection(inputType: inputType),
          //   ),
          // _buildGenerateReportButton(context, controller)
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController textController,
    required BuildContext context,
    required String label,
    required Function(DateTime) onTap,
    DateTime? initialDate,
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
          initialDate: initialDate ?? DateTime.now(),
          firstDate:
              initialDate ?? DateTime.now().subtract(Duration(days: 365 * 5)),
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

  Widget _buildYearDropDown(ReportController controller) {
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
          setState(() {
            financialYear = val!;
          });
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
