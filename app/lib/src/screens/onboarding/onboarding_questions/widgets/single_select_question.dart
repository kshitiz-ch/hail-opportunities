import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleSelectQuestion extends StatelessWidget {
  const SingleSelectQuestion({
    Key? key,
    required this.onboardingQuestion,
  }) : super(key: key);

  final OnboardingQuestionModel onboardingQuestion;

  @override
  Widget build(BuildContext context) {
    if ((onboardingQuestion.options ?? []).length > 4) {
      return _buildDropdown(context);
    } else {
      return _buildRadioButtons(context);
    }
  }

  Widget _buildDropdown(BuildContext context) {
    TextStyle textStyle = Theme.of(context).primaryTextTheme.headlineSmall!;

    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: GetBuilder<OnboardingQuestionController>(
        builder: (controller) {
          OnboardingAnswerModel? selectedOption;
          List<String> questionOptions = [];

          if (controller.questionAnswers
                  .containsKey(onboardingQuestion.externalId) &&
              controller.questionAnswers[onboardingQuestion.externalId]!
                  .selectedOptions.isNotEmpty) {
            selectedOption = controller
                .questionAnswers[onboardingQuestion.externalId]!
                .selectedOptions
                .first;
          }

          (onboardingQuestion.options ?? [])
              .forEach((OnboardingAnswerModel option) {
            questionOptions.add(option.answer.toString());
          });

          return SimpleDropdownFormField<String>(
            items: questionOptions,
            hintText: 'Choose one option',
            hintStyle: textStyle.copyWith(color: ColorConstants.secondaryBlack),
            borderRadius: 12,
            style: textStyle,
            value: selectedOption?.answer,
            onChanged: (value) {
              controller.updateOnboardingAnswer(
                  onboardingQuestion, value ?? '');
            },
          );
        },
      ),
    );
  }

  Widget _buildRadioButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: GetBuilder<OnboardingQuestionController>(
        builder: (controller) {
          OnboardingAnswerModel? selectedOption;
          List<String> questionOptions = [];

          if (controller.questionAnswers
                  .containsKey(onboardingQuestion.externalId) &&
              controller.questionAnswers[onboardingQuestion.externalId]!
                  .selectedOptions.isNotEmpty) {
            selectedOption = controller
                .questionAnswers[onboardingQuestion.externalId]!
                .selectedOptions
                .first;
          }

          (onboardingQuestion.options ?? [])
              .forEach((OnboardingAnswerModel option) {
            questionOptions.add(option.answer.toString());
          });

          return RadioButtons(
            items: questionOptions,
            textStyle: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(
                    color: ColorConstants.black, fontWeight: FontWeight.w500),
            spacing: 20,
            runSpacing: 0,
            selectedValue: selectedOption?.answer,
            direction: Axis.vertical,
            onTap: (value) {
              controller.updateOnboardingAnswer(onboardingQuestion, value);
            },
          );
        },
      ),
    );
  }
}
