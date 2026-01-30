import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'city_question.dart';
import 'custom_answer_question.dart';
import 'multi_select_question.dart';
import 'single_select_question.dart';

class OnboardingQuestionsList extends StatelessWidget {
  const OnboardingQuestionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingQuestionController>(
      builder: (controller) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                bottom: controller.isCityQuestionInFocus ? 70 : 0),
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              children: [
                _buildTitle(context, controller),
                _buildSubTitle(context, controller),
                _buildQuestions(controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(
      BuildContext context, OnboardingQuestionController controller) {
    if (controller.meta?.title?.isNullOrEmpty ?? true) return SizedBox();
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        controller.meta!.title!,
        style: Theme.of(context)
            .primaryTextTheme
            .headlineMedium!
            .copyWith(fontWeight: FontWeight.w500, fontSize: 18),
      ),
    );
  }

  Widget _buildSubTitle(
      BuildContext context, OnboardingQuestionController controller) {
    if (controller.meta?.subtitle?.isNullOrEmpty ?? true) return SizedBox();

    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Text(
        controller.meta!.subtitle!,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.tertiaryBlack, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildQuestions(OnboardingQuestionController controller) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 80, top: 30),
      shrinkWrap: true,
      itemCount: controller.onboardingQuestions!.length,
      itemBuilder: (BuildContext context, int index) {
        OnboardingQuestionModel onboardingQuestion =
            controller.onboardingQuestions![index];

        bool isCityQuestion = onboardingQuestion.question?.qtype == "city";
        bool isNotFirstQuestion = index != 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${onboardingQuestion.question?.title ?? ''}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w700, height: 1.5),
                  ),
                  if (onboardingQuestion.multiSelect ?? false)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '(Choose one or more options)',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (isCityQuestion)
              CityQuestion(
                controller: controller,
                cityQuestion: onboardingQuestion,
                isNotFirstQuestion: isNotFirstQuestion,
              )
            else if (onboardingQuestion.isCustomQuestion)
              CustomAnswerQuestion(
                onboardingQuestion: onboardingQuestion,
              )
            else if (onboardingQuestion.multiSelect ?? false)
              MultiSelectQuestion(onboardingQuestion: onboardingQuestion)
            else
              SingleSelectQuestion(
                onboardingQuestion: onboardingQuestion,
              ),
            SizedBox(height: 50),
          ],
        );
      },
    );
  }
}
