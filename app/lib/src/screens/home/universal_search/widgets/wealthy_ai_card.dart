import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/commons/ai/ai_bottom_sheet.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class WealthyAiCard extends StatelessWidget {
  const WealthyAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(
      id: GetxId.search,
      builder: (controller) {
        if (controller.hasWealthyAIFAQAccess) {
          final suggestedQuestions = controller
                  .getAssistantByAssistantKey(AIAssistantType.faqAssistant.key)
                  ?.suggestedQuestions ??
              [];
          return Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.secondarySeparatorColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(AllImages().wealthyAiLogo, width: 68),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your AI partner for all your Product related queries.',
                        style: context.titleLarge!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        showAIBottomSheet(
                          context,
                          screenContext: AiScreenType.faq,
                          parameters: WealthyAIScreenParameters(
                            assistantKey: AIAssistantType.faqAssistant.key,
                            quickActions: suggestedQuestions,
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        AllImages().wealthyAiButton,
                        width: 105,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return SizedBox();
      },
    );
  }
}
