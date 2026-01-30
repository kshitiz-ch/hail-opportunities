import 'dart:async';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/common/ai_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:get/get.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:auto_route/auto_route.dart';
// Import screen-specific widgets
import 'widgets/client_ai_widget.dart';
import 'widgets/faq_ai_widget.dart';
import 'widgets/ai_input_field.dart';

Future<void> showAIBottomSheet(
  BuildContext context, {
  required AiScreenType screenContext,
  required WealthyAIScreenParameters parameters,
}) async {
  AiScreenType screen = screenContext;
  final assistantKey = parameters.assistantKey;

  await CommonUI.showBottomSheet(
    context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    barrierColor: ColorConstants.black.withOpacity(0.5),
    child: GetBuilder<AIController>(
      init: AIController(
        assistantKey: assistantKey,
        screenContext: screen,
      ),
      tag: aiControllerTag,
      builder: (controller) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: AIBottomSheet(
          screenContext: screenContext,
          parameters: parameters,
        ),
      ),
    ),
  );
}

class AIBottomSheet extends StatelessWidget {
  final AiScreenType screenContext;
  final WealthyAIScreenParameters parameters;

  const AIBottomSheet({
    Key? key,
    required this.screenContext,
    required this.parameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
        decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
            color: ColorConstants.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: GetBuilder<AIController>(
          tag: aiControllerTag,
          builder: (controller) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, controller),
            Flexible(
              child: _buildScreenSpecificContent(context, controller),
              ),
              _buildInputField(context, controller, bottomPadding),
            ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AIController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            AllImages().wealthyAiLogo,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: ColorConstants.black,
              size: 24,
            ),
            onPressed: () {
              controller.endSession();
              AutoRouter.of(context).popForced();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScreenSpecificContent(
      BuildContext context, AIController controller) {

    switch (screenContext) {
      case AiScreenType.clients:
        return ClientAIWidget(
          controller: controller,
          parameters: parameters,
        );
      case AiScreenType.faq:
        return FAQAIWidget(
          controller: controller,
          parameters: parameters,
        );
      default:
        return ClientAIWidget(
          controller: controller,
          parameters: parameters,
        );
    }
  }

  Widget _buildInputField(
      BuildContext context, AIController controller, double bottomPadding) {
    List<String> suggestions = [];

    if (parameters.quickActions.isNotEmpty) {
      suggestions = List<String>.from(parameters.quickActions);
    }

    return AIInputField(
      controller: controller,
      suggestions: suggestions,
      bottomPadding: bottomPadding,
      initialQuestion: parameters.initialQuestion,
    );
  }
}
