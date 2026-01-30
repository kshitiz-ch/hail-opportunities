import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/view/calculator_screen.dart';
import 'package:app/src/screens/calculator_new/widgets/slider_input.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SwpInputFields extends StatelessWidget {
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
                  SliderInput<int>(
                    label: 'Current Corpus',
                    value: controller.currentCorpus.value,
                    min: controller.minCorpus,
                    max: controller.maxCorpus,
                    step: 50000,
                    valuePrefix: '₹ ',
                    onChanged: (newValue) {
                      controller.updateCurrentCorpus(newValue);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SliderInput<int>(
                      label: 'Current Age',
                      value: controller.currentAge.value,
                      min: controller.minAge,
                      max: controller.maxAge,
                      step: 1,
                      valuePrefix: '',
                      valueSuffix: ' Years',
                      onChanged: (newValue) {
                        controller.updateCurrentAge(newValue);
                      },
                    ),
                  ),
                  SliderInput<double>(
                    label: 'Expected Return Before Withdrawal Phase',
                    value: controller.expectedReturnBeforeWithdrawal.value,
                    min: controller.minReturnBeforeWithdrawal,
                    max: controller.maxReturnBeforeWithdrawal,
                    step: 0.5,
                    valuePrefix: '',
                    valueSuffix: ' %',
                    onChanged: (newValue) {
                      controller.updateExpectedReturnBeforeWithdrawal(newValue);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SliderInput<int>(
                      label: 'Withdrawal Start Age',
                      value: controller.withdrawalStartAge.value,
                      min: controller.minWithdrawalStartAge,
                      max: controller.maxWithdrawalStartAge,
                      step: 1,
                      valuePrefix: '',
                      valueSuffix: ' Years',
                      onChanged: (newValue) {
                        controller.updateWithdrawalStartAge(newValue);
                      },
                    ),
                  ),
                  SliderInput<int>(
                    label: 'Monthly Withdrawal Amount',
                    value: controller.monthlyWithdrawalAmount.value,
                    min: controller.minMonthlyWithdrawal,
                    max: controller.maxMonthlyWithdrawal,
                    step: 5000,
                    valuePrefix: '₹ ',
                    onChanged: (newValue) {
                      controller.updateMonthlyWithdrawalAmount(newValue);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SliderInput<double>(
                      label: 'Yearly Increase in Withdrawal',
                      value: controller.yearlyIncreaseInWithdrawal.value,
                      min: controller.minYearlyIncrease,
                      max: controller.maxYearlyIncrease,
                      step: 0.5,
                      valuePrefix: '',
                      valueSuffix: ' %',
                      onChanged: (newValue) {
                        controller.updateYearlyIncreaseInWithdrawal(newValue);
                      },
                    ),
                  ),
                  SliderInput<double>(
                    label: 'Expected Return During Withdrawal',
                    value: controller.expectedReturnDuringWithdrawal.value,
                    min: controller.minReturnDuringWithdrawal,
                    max: controller.maxReturnDuringWithdrawal,
                    step: 0.5,
                    valuePrefix: '',
                    valueSuffix: ' %',
                    onChanged: (newValue) {
                      controller.updateExpectedReturnDuringWithdrawal(newValue);
                    },
                  ),
                  buildErrorView(controller.precheckErrorMessage(), context),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
