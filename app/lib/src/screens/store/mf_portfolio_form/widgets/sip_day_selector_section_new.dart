import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/activate_step_up_sip.dart';
import 'package:app/src/screens/store/common_new/widgets/sip_day_stepup_selector_section.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipDaySelectorSectionNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'investment-type',
      builder: (controller) {
        bool isTaxSaver = controller.portfolio.isTaxSaver ||
            controller.portfolio.productVariant == "2025";
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
          child: controller.investmentType == InvestmentType.SIP
              ? SipDayStepUpSelectorSection(
                  allowedSipDays: controller.allowedSipDays.toList(),
                  showStepUp: !isTaxSaver,
                  sipData: controller.sipdata,
                  onChooseDays: (data) {
                    controller.updateSelectedSipDays(data);
                  },
                  openActivateStepUpSip: () {
                    openActivateStepUpSip(controller, context);
                  },
                  sipAmount: controller.isMicroSIP
                      ? controller.totalMicroSIPAmount
                      : controller.allotmentAmount,
                  onToggleStepUpSip: (value) {
                    if (value) {
                      openActivateStepUpSip(controller, context);
                    } else {
                      controller.updateIsStepUpSipEnabled(value);
                    }
                  },
                  onChooseEndDate: (endDate) {
                    controller.updateEndDate(endDate);
                  },
                  onChooseStartDate: (startDate) {
                    controller.updateStartDate(startDate);
                  },
                )
              : SizedBox.shrink(),
        );
      },
    );
  }

  void openActivateStepUpSip(
      MFPortfolioDetailController controller, BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      child: ActivateStepUpSip(
        onUpdateStepUpPeriod: (stepUpPeriod, stepUpPercentage) {
          controller.activateStepUpSip(
            stepUpPeriod,
            stepUpPercentage,
          );
          controller.updateIsStepUpSipEnabled(true);
          AutoRouter.of(context).popForced();
        },
        selectedStepUpPeriod: controller.sipdata.stepUpPeriod,
        sipAmount: controller.allotmentAmount,
        stepUpPercentage: controller.sipdata.stepUpPercentage,
        stepUpPercentageController:
            controller.sipdata.stepUpPercentageController,
      ),
    );
  }
}
