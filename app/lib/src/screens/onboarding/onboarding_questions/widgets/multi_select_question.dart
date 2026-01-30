import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectQuestion extends StatelessWidget {
  const MultiSelectQuestion({Key? key, required this.onboardingQuestion})
      : super(key: key);

  final OnboardingQuestionModel onboardingQuestion;

  @override
  Widget build(BuildContext context) {
    if (onboardingQuestion.options.isNullOrEmpty) {
      return SizedBox();
    }

    return GetBuilder<OnboardingQuestionController>(
      builder: (controller) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: onboardingQuestion.options!.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(height: 20);
          },
          itemBuilder: (context, index) {
            OnboardingAnswerModel currentOption =
                onboardingQuestion.options![index];
            bool isSelected = false;
            if (controller.questionAnswers
                .containsKey(onboardingQuestion.externalId)) {
              List<OnboardingAnswerModel> selectedOptions = controller
                      .questionAnswers[onboardingQuestion.externalId]
                      ?.selectedOptions ??
                  [];

              for (OnboardingAnswerModel option in selectedOptions) {
                if (currentOption.externalId == option.externalId) {
                  isSelected = true;
                  break;
                }
              }
            }

            return InkWell(
              onTap: () {
                controller.updateOnboardingAnswer(
                    onboardingQuestion, currentOption.answer!);
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    child: Transform.scale(
                      scale: 1.2,
                      child: CommonUI.buildCheckbox(
                        checkColor: ColorConstants.white,
                        showFillColor: false,
                        value: isSelected,
                        borderWidth: 1.5,
                        onChanged: (bool? value) {
                          controller.updateOnboardingAnswer(
                              onboardingQuestion, currentOption.answer!);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    currentOption.answer!,
                    style: Theme.of(context).primaryTextTheme.headlineSmall!,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
