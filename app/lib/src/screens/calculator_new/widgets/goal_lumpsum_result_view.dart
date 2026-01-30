import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/widgets/graph_table_tabs.dart';
import 'package:app/src/screens/calculator_new/widgets/investment_data_table.dart';
import 'package:app/src/screens/calculator_new/widgets/investment_pie_chart.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalLumpsumResultView extends StatelessWidget {
  final CalculatorController controller = Get.find<CalculatorController>();

  @override
  Widget build(BuildContext context) {
    // Call the controller method to get Lumpsum goal planning results
    final data = controller.calculateLumpsumPlan();

    final yearWiseData = WealthyCast.toList(data['return_data'])
        .map((e) => e as Map<String, dynamic>)
        .toList();

    final lastYearData = yearWiseData.isNotEmpty ? yearWiseData.last : null;
    final totalInvested = lastYearData?['total_invested'] ?? 0.0;
    final totalGain = lastYearData?['total_gain'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: GraphTableTabs(
              onTabSelected: (value) {
                if (controller.selectedGraphTableTabIndex.value != value) {
                  controller.selectedGraphTableTabIndex.value = value;
                  controller.update();
                }
              },
              selectedGraphTableTabIndex:
                  controller.selectedGraphTableTabIndex.value,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.selectedGraphTableTabIndex.value == 1
                ? InvestmentDataTable.goalPlanning(data: yearWiseData)
                : InvestmentPieChart(
                    targetAmount: controller.targetCorpus.value.toDouble(),
                    years: controller.investmentPeriod.value,
                    investedAmount: totalInvested,
                    gainAmount: totalGain,
                    monthlyInvestment: data['initial_lumpsum'] ?? 0.0,
                    calculatorType: CalculatorType.GoalPlanningLumpsum,
                  ),
          ),
        ],
      ),
    );
  }
}
