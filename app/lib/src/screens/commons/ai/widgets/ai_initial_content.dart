import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/common/ai_controller.dart';
import 'package:app/src/screens/commons/ai/widgets/suggestion_button.dart';

class AIInitialContent extends StatelessWidget {
  final AIController controller;
  final List<dynamic> quickActions;

  const AIInitialContent({
    Key? key,
    required this.controller,
    required this.quickActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'How can I help you today?',
                style: context.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (quickActions.isNotEmpty)
            Column(
              children: [
              for (final action in quickActions) ...[
                if (action != quickActions.first) const SizedBox(height: 10),
                SuggestionButton(
                  label: action as String,
                  onTap: () {
                    controller.messageController.text = action;
                    controller.processAIQuery(action);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
