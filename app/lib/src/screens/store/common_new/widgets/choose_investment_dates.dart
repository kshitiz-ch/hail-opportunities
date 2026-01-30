import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/store/common_new/widgets/day_button.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ChooseInvestmentDate extends StatefulWidget {
  final List<int> selectedSipDays;
  final Function(List<int>) onUpdateSipDays;
  final List<int> allowedSipDays;
  final bool disableMultipleSelect;
  final int? maxDaysLimit;
  final String? title;
  final String? description;
  final bool isSip;
  final bool allowModification;

  const ChooseInvestmentDate({
    Key? key,
    required this.selectedSipDays,
    required this.onUpdateSipDays,
    required this.allowedSipDays,
    this.maxDaysLimit,
    this.disableMultipleSelect = false,
    this.title,
    this.description,
    this.isSip = true,
    this.allowModification = true,
  }) : super(key: key);

  @override
  State<ChooseInvestmentDate> createState() => _ChooseInvestmentDateState();
}

class _ChooseInvestmentDateState extends State<ChooseInvestmentDate> {
  List<int> selectedDays = [];

  @override
  void initState() {
    selectedDays = List<int>.from(widget.selectedSipDays);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
          .copyWith(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? 'Choose Investment dates',
            style: context.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.allowModification)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.description ??
                    'You can choose multiple days to invest in SIP every month',
                style: context.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (_canSelectAllDays())
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildSelectAll(context),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: _buildDaySelector(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: _buildSelectedDays(context: context),
          ),
          _buildContinueButton(context: context),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return GridView.builder(
      itemCount: 28,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final day = index + 1;
        final isSelected = selectedDays.contains(day);
        final isDisabled = widget.allowedSipDays.isNullOrEmpty
            ? false
            : !widget.allowedSipDays.contains(day);
        return DayButton(
          isDisabled: isDisabled,
          day: day,
          selected: isSelected,
          onTap: () {
            _onDayTap(isSelected, day);
          },
        );
      },
    );
  }

  Widget _buildSelectedDays({
    required BuildContext context,
  }) {
    String dateStr = '';
    // if (selectedDays.isNullOrEmpty) {
    //   dateStr = '';
    // } else if (selectedDays.length == 1) {
    //   dateStr = selectedDays.first.numberPattern;
    // } else {
    //   dateStr = selectedDays
    //       .sublist(0, selectedDays.length - 1)
    //       .map((day) => day.numberPattern)
    //       .join(' ,');
    //   dateStr += ' and ${selectedDays.last.numberPattern}';
    // }

    if (selectedDays.isNotNullOrEmpty) {
      if (selectedDays.length > 3) {
        dateStr = selectedDays
            .sublist(0, 3)
            .map((day) => day.numberPattern)
            .join(', ');
      } else {
        dateStr = selectedDays.map((day) => day.numberPattern).join(', ');
      }
      final remainingDays = selectedDays.length - 3;
      if (remainingDays > 0) {
        dateStr += ', +$remainingDays days';
      }
    }

    if (dateStr.isNullOrEmpty) return SizedBox();
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: ColorConstants.greenAccentColor,
          child: Icon(
            Icons.check,
            size: 8,
            color: ColorConstants.white,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedDays.length} Days Selected ($dateStr)',
                  style: context.headlineSmall!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 5),
                if (selectedDays.isNotNullOrEmpty && widget.isSip)
                  Text(
                    'SIP will debit ${selectedDays.length} time(s) per month',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContinueButton({
    required BuildContext context,
  }) {
    return ActionButton(
      text: !widget.allowModification ? 'Close' : 'Update',
      isDisabled: selectedDays.isNullOrEmpty,
      margin: EdgeInsets.zero,
      onPressed: () {
        widget.onUpdateSipDays(selectedDays);
        AutoRouter.of(context).popForced();
      },
    );
  }

  void _onDayTap(bool isSelected, int day) {
    if (mounted && widget.allowModification) {
      setState(
        () {
          if (widget.disableMultipleSelect) {
            selectedDays.clear();
            selectedDays.add(day);
            return;
          }
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            // Limit Max No of Days if maxDaysLimit is not NULL
            if (widget.maxDaysLimit.isNotNullOrZero &&
                (widget.maxDaysLimit! <= selectedDays.length)) {
              showToast(
                  text: 'Maximum No. of days allowed: ${widget.maxDaysLimit}');
            } else {
              selectedDays
                ..add(day)
                ..sort();
            }
          }
        },
      );
    }
  }

  bool _canSelectAllDays() {
    if (widget.allowModification && !widget.disableMultipleSelect) {
      if (widget.maxDaysLimit.isNotNullOrZero) {
        return widget.maxDaysLimit == widget.allowedSipDays.length;
      }
      return true;
    }
    return false;
  }

  void _onTapAllDays(bool? value) {
    if (mounted) {
      setState(() {
        if (value == true) {
          selectedDays = List<int>.from(widget.allowedSipDays);
          selectedDays.sort();
        } else {
          selectedDays = [];
        }
      });
    }
  }

  Widget _buildSelectAll(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 16,
          width: 16,
          child: CommonUI.buildCheckbox(
            value: selectedDays.length == widget.allowedSipDays.length,
            unselectedBorderColor: ColorConstants.borderColor,
            onChanged: _onTapAllDays,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Select All Dates',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
