import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalSummary extends StatelessWidget {
  const GoalSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      builder: (controller) {
        if (controller.mfInvestmentType == MfInvestmentType.Funds &&
            controller.goalSchemes.isEmpty) {
          return SizedBox();
        }

        double? investedValue;
        double? currentIrr;
        double? currentValue;
        double? absoluteReturns;

        if (controller.mfInvestmentType == MfInvestmentType.Funds) {
          investedValue = controller.anyFundScheme?.currentInvestedValue;
          currentValue = controller.anyFundScheme?.currentValue;
          currentIrr = controller.anyFundScheme?.currentIrr;
          absoluteReturns = controller.anyFundScheme?.currentAbsoluteReturns;
        } else {
          investedValue = controller.goal?.currentInvestedValue;
          currentValue = controller.goal?.currentValue;
          currentIrr = controller.goal?.currentIrr;
          absoluteReturns = controller.goal?.currentAbsoluteReturns;
        }

        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ColorConstants.primaryCardColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CommonClientUI.columnInfoText(
                    context,
                    title: 'Invested',
                    subtitle: WealthyAmount.currencyFormat(investedValue, 1),
                  ),
                  if (controller.mfInvestmentType ==
                      MfInvestmentType.Portfolios)
                    CommonClientUI.columnInfoText(
                      context,
                      title: 'Debt',
                      subtitle: getPercentageText(
                          controller.goal?.currentDebtPercentage),
                    ),
                  CommonClientUI.columnInfoText(
                    context,
                    title: 'IRR',
                    subtitle: getPercentageText(currentIrr),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CommonClientUI.columnInfoText(
                    context,
                    title: 'Current Value',
                    subtitle: WealthyAmount.currencyFormat(currentValue, 1),
                  ),
                  if (controller.mfInvestmentType ==
                      MfInvestmentType.Portfolios)
                    CommonClientUI.columnInfoText(
                      context,
                      title: 'Equity',
                      subtitle: getPercentageText(
                          controller.goal?.currentEquityPercentage),
                    ),
                  CommonClientUI.columnInfoText(
                    context,
                    title: 'Absolute',
                    subtitle: getPercentageText(absoluteReturns),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
