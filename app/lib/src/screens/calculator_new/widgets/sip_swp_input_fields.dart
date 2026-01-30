import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/view/calculator_screen.dart';
import 'package:app/src/screens/calculator_new/widgets/labeled_input_box.dart';
import 'package:app/src/screens/calculator_new/widgets/slider_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipSwpInputFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GetBuilder<CalculatorController>(
        builder: (controller) {
          return Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSipPhaseSection(context, controller),
                  const SizedBox(height: 20),
                  _buildSwpPhaseSection(context, controller),
                  buildErrorView(controller.precheckErrorMessage(), context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSipPhaseSection(
    BuildContext context,
    CalculatorController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'SIP Phase',
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ),
          Divider(color: ColorConstants.borderColor, height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: LabeledInputBox<int>(
                    labelText: 'Current Age',
                    value: controller.currentAge.value,
                    suffixText: '',
                    onChanged: (value) {
                      controller.updateCurrentAge(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LabeledInputBox<int>(
                    labelText: 'SIP End Age',
                    value: controller.sipEndAge.value,
                    suffixText: '',
                    onChanged: (value) {
                      controller.updateSipEndAge(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          SliderInput<int>(
            label: 'Monthly SIP Amount',
            value: controller.monthlyInvestment.value,
            min: controller.minMonthlyInvestment,
            max: controller.maxMonthlyInvestment,
            step: 1000,
            valuePrefix: '₹',
            onChanged: (newValue) {
              controller.updateMonthlyInvestment(newValue);
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: LabeledInputBox<double>(
                    labelText: 'Expected Return',
                    value: controller.expectedRateOfReturn.value,
                    suffixText: '%',
                    onChanged: (value) {
                      controller.updateExpectedRateOfReturn(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LabeledInputBox<double>(
                    labelText: 'Annual Step-Up',
                    value: controller.stepUpPercentage.value,
                    suffixText: '%',
                    onChanged: (value) {
                      controller.updateStepUpPercentage(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          SliderInput<int>(
            label: 'Lumpsum Amount',
            value: controller.lumpsumInvestment.value,
            min: controller.minLumpsumInvestment,
            max: controller.maxLumpsumInvestment,
            step: 1000,
            valuePrefix: '₹',
            onChanged: (newValue) {
              controller.updateLumpsumInvestment(newValue);
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSwpPhaseSection(
    BuildContext context,
    CalculatorController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'SWP Phase',
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ),
          Divider(color: ColorConstants.borderColor, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SliderInput<int>(
              label: 'SWP Start Age',
              value: controller.withdrawalStartAge.value,
              min: controller.minWithdrawalStartAge,
              max: controller.maxWithdrawalStartAge,
              step: 1,
              valuePrefix: '',
              valueSuffix: '',
              onChanged: (newValue) {
                controller.updateWithdrawalStartAge(newValue);
              },
            ),
          ),
          SliderInput<int>(
            label: 'Monthly Withdrawal',
            value: controller.monthlyWithdrawalAmount.value,
            min: controller.minMonthlyWithdrawal,
            max: controller.maxMonthlyWithdrawal,
            step: 5000,
            valuePrefix: '₹',
            onChanged: (newValue) {
              controller.updateMonthlyWithdrawalAmount(newValue);
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: LabeledInputBox<double>(
                    labelText: 'Yearly Increase',
                    value: controller.yearlyIncreaseInWithdrawal.value,
                    suffixText: '%',
                    onChanged: (value) {
                      controller.updateYearlyIncreaseInWithdrawal(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LabeledInputBox<double>(
                    labelText: 'Expected Return During Withdrawal',
                    value: controller.expectedReturnDuringWithdrawal.value,
                    suffixText: '%',
                    onChanged: (value) {
                      controller.updateExpectedReturnDuringWithdrawal(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
