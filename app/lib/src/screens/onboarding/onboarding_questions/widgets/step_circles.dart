import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepCircles extends StatelessWidget {
  const StepCircles({Key? key, this.step}) : super(key: key);

  final int? step;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingQuestionController>(
      builder: (controller) {
        bool isLastStep = false;
        bool isCurrentStep = step == (controller.meta!.level! + 1);
        bool isComplete = step! < (controller.meta!.level! + 1);
        return Container(
          margin: EdgeInsets.only(right: isLastStep ? 0.0 : 10.0),
          padding: isComplete
              ? EdgeInsets.symmetric(vertical: 2, horizontal: 2)
              : EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete ? ColorConstants.primaryAppColor : Colors.white,
            border: Border.all(
              color: (isCurrentStep || isComplete)
                  ? ColorConstants.primaryAppColor
                  : hexToColor("#7A7A7A"),
            ),
          ),
          child: isComplete
              ? Icon(
                  Icons.done,
                  size: 14,
                )
              : Text(
                  step.toString(),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: isCurrentStep
                            ? ColorConstants.primaryAppColor
                            : hexToColor("#7A7A7A"),
                        fontSize: 12,
                      ),
                ),
        );
      },
    );
  }
}
