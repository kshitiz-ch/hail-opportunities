import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/widgets/Lumpsum_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/goal_lumpsum_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/goal_lumpsum_result_view.dart';
import 'package:app/src/screens/calculator_new/widgets/goal_sip_lumpsum_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/goal_sip_lumpsum_result_view.dart';
import 'package:app/src/screens/calculator_new/widgets/lumpsum_result_view.dart';
import 'package:app/src/screens/calculator_new/widgets/share_calculator_report_bottomsheet.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_result_view.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_swp_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_swp_result_view.dart';
import 'package:app/src/screens/calculator_new/widgets/swp_input_fields.dart';
import 'package:app/src/screens/calculator_new/widgets/swp_result_view.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class CalculatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalculatorController>(
      builder: (controller) {
        final data = controller
            .getCalculatorIconTitle(controller.currentCalculatorType.value);
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(titleText: '${data['title']} Calculator'),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabs(context, controller),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      SingleChildScrollView(
                        child: _getInputView(
                            controller.currentCalculatorType.value),
                      ),
                      SingleChildScrollView(
                        child: _getResultView(
                            controller.currentCalculatorType.value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(
            controller.selectedTabIndex == 0,
            controller,
            context,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _getInputView(CalculatorType type) {
    switch (type) {
      case CalculatorType.SipStepUp:
        return SipInputFields();
      case CalculatorType.Lumpsum:
        return LumpsumInputFields();
      case CalculatorType.SWP:
        return SwpInputFields();
      case CalculatorType.SipSwp:
        return SipSwpInputFields();
      case CalculatorType.GoalPlanningLumpsum:
        return GoalLumpsumInputFields();
      case CalculatorType.GoalPlanningSIPLumpsum:
        return GoalSipLumpsumInputFields();
    }
  }

  Widget _getResultView(CalculatorType type) {
    switch (type) {
      case CalculatorType.SipStepUp:
        return SipResultView();
      case CalculatorType.Lumpsum:
        return LumpsumResultView();
      case CalculatorType.SWP:
        return SwpResultView();
      case CalculatorType.SipSwp:
        return SipSwpResultView();
      case CalculatorType.GoalPlanningLumpsum:
        return GoalLumpsumResultView();
      case CalculatorType.GoalPlanningSIPLumpsum:
        return GoalSipLumpsumResultView();
    }
  }

  Widget _buildTabs(BuildContext context, CalculatorController controller) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(
          controller.tabs.length,
          (index) {
            final isSelected = index == controller.selectedTabIndex;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    controller.changeTab(index);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConstants.paleLavenderColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      controller.tabs[index],
                      style: context.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? ColorConstants.primaryAppColor
                            : ColorConstants.tertiaryBlack,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAB(
    bool isInputTab,
    CalculatorController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final isDisabled = controller.precheckErrorMessage().isNotNullOrEmpty;
      return ActionButton(
        text: isInputTab ? 'Calculate Result ' : 'Generate & Share',
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        isDisabled: isDisabled,
        onPressed: () {
          if (isInputTab) {
            controller.changeTab(1);
          } else {
            // Open Share Report Bottom Sheet
            CommonUI.showBottomSheet(
              context,
              child: ShareCalculatorReportBottomSheet(),
            );
          }
        },
      );
    });
  }
}

Widget buildErrorView(String? message, BuildContext context) {
  if (message.isNotNullOrEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message!,
          style: context.headlineSmall
              ?.copyWith(color: ColorConstants.errorTextColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return SizedBox.shrink();
}
