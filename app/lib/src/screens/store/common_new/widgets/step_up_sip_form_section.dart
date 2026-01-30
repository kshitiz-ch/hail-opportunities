import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepUpSipFormSection extends StatelessWidget {
  final String selectedStepUpPeriod;
  final TextEditingController stepUpPercentageController;
  final Function(String) onUpdateStepUpPeriod;
  final Function(int) onUpdateStepUpPercentage;
  final GlobalKey<FormState> activateSipFormKey;

  const StepUpSipFormSection({
    Key? key,
    required this.selectedStepUpPeriod,
    required this.stepUpPercentageController,
    required this.onUpdateStepUpPeriod,
    required this.onUpdateStepUpPercentage,
    required this.activateSipFormKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: activateSipFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepUpPeriodUI(context),
          _buildStepUpPercentageUI(context),
        ],
      ),
    );
  }

  Widget _buildStepUpPeriodUI(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period /Step-up Interval',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.black,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 25),
          child: RadioButtons(
            selectedValue: selectedStepUpPeriod,
            onTap: (data) {
              onUpdateStepUpPeriod(data);
            },
            direction: Axis.horizontal,
            items: ['6 Months', '1 Year'],
            textStyle:
                Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: ColorConstants.tertiaryBlack,
                    ),
          ),
        )
      ],
    );
  }

  Widget _buildStepUpPercentageUI(BuildContext context) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Percentage',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.black,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SimpleTextFormField(
            autovalidateMode: AutovalidateMode.always,
            controller: stepUpPercentageController,
            label: "Enter Percentage of the Step-up SIP",
            useLabelAsHint: true,
            contentPadding: EdgeInsets.only(bottom: 8),
            borderColor: ColorConstants.lightGrey,
            style: textStyle,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onChanged: (value) {
              onUpdateStepUpPercentage(
                WealthyCast.toInt(stepUpPercentageController.text) ?? 0,
              );
            },
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Percentage of the Step-up SIP is required';
              }
              final percentage =
                  WealthyCast.toInt(stepUpPercentageController.text) ?? 0;
              if (percentage < 10) {
                return 'Percentage of the Step-up SIP should be minimum 10%';
              }
              if (percentage > 100) {
                return 'Maximum Percentage of the Step-up SIP is 100';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }
}
