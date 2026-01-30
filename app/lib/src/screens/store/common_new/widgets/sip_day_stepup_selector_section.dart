import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/store/common_new/widgets/choose_investment_dates.dart';
import 'package:app/src/screens/store/common_new/widgets/step_up_sip_info.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sip_day_selector_new.dart';

class SipDayStepUpSelectorSection extends StatelessWidget {
  final SipData sipData;
  final Function(List<int>) onChooseDays;
  final Function(bool) onToggleStepUpSip;
  final Function(DateTime) onChooseStartDate;
  final Function(DateTime) onChooseEndDate;

  final Function openActivateStepUpSip;
  final List<int> allowedSipDays;
  final double sipAmount;
  final bool showStepUp;

  const SipDayStepUpSelectorSection(
      {Key? key,
      required this.onChooseDays,
      required this.onToggleStepUpSip,
      required this.openActivateStepUpSip,
      required this.sipData,
      required this.sipAmount,
      required this.allowedSipDays,
      required this.onChooseStartDate,
      required this.onChooseEndDate,
      this.showStepUp = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SipDaySelectorNew(
          allowedSipDays: allowedSipDays,
          selectedSipDays: sipData.selectedSipDays,
          sipAmount: sipAmount,
          onUpdateSipDays: (selectedDays) {
            onChooseDays(selectedDays);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _buildStartDateEndDate(context),
        ),
        if (showStepUp) _buildStepUpSip(context: context),
      ],
    );
  }

  Widget _buildStepUpSip({required BuildContext context}) {
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryGrey,
            );
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: StepUpSipInfo(),
                  );
                },
                icon: Icon(Icons.info_outline),
                iconSize: 16,
                color: ColorConstants.primaryAppColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (sipData.isStepUpSipEnabled) {
                      openActivateStepUpSip();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: sipData.isStepUpSipEnabled
                        ? Text.rich(
                            TextSpan(
                              text: 'Step-up SIP is ',
                              style: titleStyle,
                              children: [
                                TextSpan(
                                  text: 'Active',
                                  style: titleStyle?.copyWith(
                                    color: ColorConstants.greenAccentColor,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Text(
                            'Activate Step-up SIP',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstants.tertiaryBlack,
                                ),
                          ),
                  ),
                ),
              ),
              Container(
                height: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: sipData.isStepUpSipEnabled
                          ? ColorConstants.greenAccentColor.withOpacity(0.15)
                          : ColorConstants.secondaryLightGrey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: FittedBox(
                  child: CupertinoSwitch(
                    thumbColor: sipData.isStepUpSipEnabled
                        ? ColorConstants.greenAccentColor
                        : ColorConstants.secondaryLightGrey,
                    trackColor: Colors.white,
                    value: sipData.isStepUpSipEnabled,
                    activeColor: Colors.white,
                    onChanged: (value) async {
                      onToggleStepUpSip(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (sipData.isStepUpSipEnabled &&
            sipData.stepUpPeriod.isNotNullOrEmpty &&
            sipData.stepUpPercentage != null)
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text.rich(
              TextSpan(
                  text: 'Step up Period ',
                  style: subtitleStyle,
                  children: [
                    TextSpan(
                      text: sipData.stepUpPeriod,
                      style: subtitleStyle?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                    TextSpan(
                      text: ', Step up Percentage ',
                      style: subtitleStyle,
                    ),
                    TextSpan(
                      text: '${sipData.stepUpPercentage}%',
                      style: subtitleStyle?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                  ]),
            ),
          ),
      ],
    );
  }

  Widget _buildStartDateEndDate(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GoalDateInput(
            controller: sipData.startDateController,
            label: 'Start Date',
            onDateSelect: onChooseStartDate,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: GoalDateInput(
            controller: sipData.endDateController,
            label: 'End Date',
            onDateSelect: onChooseEndDate,
            startDate: sipData.startDate,
          ),
        ),
      ],
    );
  }
}
