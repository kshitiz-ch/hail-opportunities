import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAnswerQuestion extends StatefulWidget {
  const CustomAnswerQuestion({
    Key? key,
    required this.onboardingQuestion,
  }) : super(key: key);

  final OnboardingQuestionModel onboardingQuestion;

  @override
  State<CustomAnswerQuestion> createState() => _CustomAnswerQuestionState();
}

class _CustomAnswerQuestionState extends State<CustomAnswerQuestion> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isArnQuestion =
        (widget.onboardingQuestion.question?.qtype ?? "").toLowerCase() ==
            "arn";

    return GetBuilder<OnboardingQuestionController>(
      builder: (controller) {
        if (textController.text.isEmpty) {
          String customAnswer;
          if (controller.questionAnswers
              .containsKey(widget.onboardingQuestion.externalId)) {
            customAnswer = controller
                    .questionAnswers[widget.onboardingQuestion.externalId]!
                    .customAnswer ??
                '';

            if (customAnswer.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                textController.text = customAnswer;
              });
            }
          }
        }

        return BorderedTextFormField(
          controller: textController,
          borderWidth: 1,
          prefixIcon: isArnQuestion
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 18),
                      child: Text(
                        'ARN-',
                        style: context.headlineSmall!,
                      ),
                    ),
                  ],
                )
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
          onChanged: (value) {
            controller.updateCustomAnswer(widget.onboardingQuestion, value);
          },
        );
      },
    );
  }
}
