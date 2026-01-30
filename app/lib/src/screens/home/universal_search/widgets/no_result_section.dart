import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/commons/ai/ai_bottom_sheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoResultSection extends StatelessWidget {
  const NoResultSection({super.key, this.message, this.searchQuery});

  final String? message;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(
      builder: (controller) {
        final suggestedQuestions = controller
                .getAssistantByAssistantKey(AIAssistantType.faqAssistant.key)
                ?.suggestedQuestions ??
            [];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AllImages().noResultFound,
              width: 100,
            ),
            SizedBox(height: 20),
            Text(message ?? 'Couldn\'t Find Result?',
                style: Theme.of(context).primaryTextTheme.titleLarge),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: ActionButton(
                  margin: EdgeInsets.zero,
                  height: 40,
                  borderColor: ColorConstants.primaryAppColor,
                  showBorder: true,
                  bgColor: Colors.white,
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .labelLarge!
                      .copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700),
                  text: 'Ask Wealthy AI',
                  onPressed: () {
                    showAIBottomSheet(
                      context,
                      screenContext: AiScreenType.faq,
                      parameters: WealthyAIScreenParameters(
                        assistantKey: AIAssistantType.faqAssistant.key,
                        quickActions: suggestedQuestions,
                        initialQuestion: searchQuery,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
