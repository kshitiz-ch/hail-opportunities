import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/widgets/slider_input.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class GoalLumpsumInputFields extends StatelessWidget {
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
                    label: 'Target Corpus',
                    value: controller.targetCorpus.value,
                    min: controller.minTargetCorpus,
                    max: controller.maxTargetCorpus,
                    step: 100000,
                    valuePrefix: '₹ ',
                    onChanged: (newValue) {
                      controller.updateTargetCorpus(newValue);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SliderInput<int>(
                      label: 'Time to Reach Target',
                      value: controller.investmentPeriod.value,
                      min: controller.minInvestmentPeriod,
                      max: controller.maxInvestmentPeriod,
                      step: 1,
                      valuePrefix: '',
                      valueSuffix: ' Years',
                      onChanged: (newValue) {
                        controller.updateInvestmentPeriod(newValue);
                      },
                    ),
                  ),
                  SliderInput<double>(
                    label: 'Expected Return Rate',
                    value: controller.expectedRateOfReturn.value,
                    min: controller.minExpectedRateOfReturn,
                    max: controller.maxExpectedRateOfReturn,
                    step: 0.5,
                    valuePrefix: '',
                    valueSuffix: ' %',
                    onChanged: (newValue) {
                      controller.updateExpectedRateOfReturn(newValue);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
