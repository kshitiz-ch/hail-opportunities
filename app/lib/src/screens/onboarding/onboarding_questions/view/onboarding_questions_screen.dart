import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:app/src/screens/onboarding/onboarding_questions/widgets/question_shimmer.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/onboarding_questions_list.dart';

@RoutePage()
class OnboardingQuestionsScreen extends StatelessWidget {
  DateTime? backButtonPressedSince;

  OnboardingQuestionsScreen({Key? key}) : super(key: key);

  void _navigteToDashboardScreen(context) async {
    final SharedPreferences sharedPreferences = await prefs;
    await sharedPreferences.setBool("onboarding_pending", false);
    AutoRouter.of(context).push(BaseRoute());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingQuestionController>(
      init: OnboardingQuestionController(),
      builder: (controller) {
        if (controller.fetchQuestionState == NetworkState.error) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _navigteToDashboardScreen(context);
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              backButtonPressedSince =
                  minimiseApplication(backButtonPressedSince, context);
            });
          },
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 32)
                  .copyWith(top: 50, bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.fetchQuestionState != NetworkState.loading &&
                      (controller.meta?.prev.isNotNullOrEmpty ?? false))
                    _buildPrevSkipButton(context, controller),
                  // if (controller.meta != null)
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _buildPrevSkipButton(context, controller),
                  //       SizedBox(height: 20),
                  //       Row(
                  //         children: [
                  //           for (int index = 0;
                  //               index < controller.meta!.totalCount!;
                  //               index++)
                  //             StepCircles(step: index + 1),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // SizedBox(height: 20),
                  if (controller.fetchQuestionState == NetworkState.loading)
                    QuestionShimmer()
                  else
                    OnboardingQuestionsList()
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Visibility(
              visible: controller.fetchQuestionState != NetworkState.loading &&
                  MediaQuery.of(context).viewInsets.bottom == 0,
              child: ActionButton(
                margin: EdgeInsets.symmetric(horizontal: 34.0, vertical: 32.0),
                showProgressIndicator:
                    controller.submitQuestionResponse.state ==
                        NetworkState.loading,
                heroTag: kDefaultHeroTag,
                isDisabled: !controller.isAllQuestionsAnswered,
                text: 'SUBMIT',
                onPressed: () async {
                  await controller.submitOnboardingAnswer();

                  if (controller.submitQuestionResponse.state ==
                      NetworkState.loaded) {
                    if (controller.isFinalQuestion) {
                      _navigteToDashboardScreen(context);
                    } else {
                      await controller.getOnboardingQuestions();

                      if (controller.fetchQuestionState ==
                              NetworkState.loaded &&
                          (controller.onboardingQuestions?.isEmpty ?? true)) {
                        _navigteToDashboardScreen(context);
                      }
                    }
                  }

                  if (controller.submitQuestionResponse.state ==
                      NetworkState.error) {
                    return showToast(
                      text: controller.submitQuestionResponse.message,
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrevSkipButton(
      BuildContext context, OnboardingQuestionController controller) {
    String prevStageId = controller.meta?.prev ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (prevStageId.isNotNullOrEmpty)
          ClickableText(
            padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
            text: '< Previous',
            onClick: () async {
              if (controller.fetchQuestionState != NetworkState.loading) {
                await controller.getOnboardingQuestions(stageId: prevStageId);
              }
            },
          )
        // else
        //   SizedBox(),
        // ClickableText(
        //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //   text: 'Skip',
        //   onClick: () async {
        //     if (controller.skipQuestionState != NetworkState.loading) {
        //       await controller.skipOnboardingQuestion();

        //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //         _navigteToDashboardScreen(context);
        //       });
        //     }
        //   },
        // )
      ],
    );
  }
}
