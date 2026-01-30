import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/widgets/bar_chart_section.dart';
import 'package:app/src/screens/calculator_new/widgets/calculator_summary_section.dart';
import 'package:app/src/screens/calculator_new/widgets/graph_table_tabs.dart';
import 'package:app/src/screens/calculator_new/widgets/investment_data_table.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LumpsumResultView extends StatelessWidget {
  final CalculatorController controller = Get.find<CalculatorController>();

  @override
  Widget build(BuildContext context) {
    // Call the controller method to get lumpsum calculation results
    final data = controller.calculateLumpsumData();

    // Calculate summary values from the data
    final totalValue = data.isNotEmpty ? data.last : {};
    final finalTotalInvested = totalValue['investment'] ?? 0;
    final finalFutureValue = totalValue['total_value'] ?? 0;
    final finalGain = totalValue['gain'] ?? 0;

    final String totalAmountStr =
        WealthyAmount.currencyFormat(finalFutureValue, 0);
    final String investedAmountStr =
        WealthyAmount.currencyFormat(finalTotalInvested, 0);
    final String gainStr =
        WealthyAmount.currencyFormat(finalGain < 0 ? 0 : finalGain, 0);
    final String tenureYearsStr =
        controller.investmentPeriod.value.floor().toStringAsFixed(0);

    final chartData = data.map((entry) {
      final xLabel = entry['year'] ?? 0;
      final investment = entry['investment'] ?? 0;
      final gain = entry['gain'] ?? 0;
      return CalculatorBarChartData(
        xLabel: 'Year ${xLabel.toInt()}',
        yValue: investment,
        yValue2: gain,
        yLabel: 'Investment',
        yLabel2: 'Gain',
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalculatorSummarySection(
            items: [
              CalculatorSummaryItem(
                label: 'Total Amount (in $tenureYearsStr years)',
                value: totalAmountStr,
                isHighlighted: true,
              ),
              CalculatorSummaryItem(
                label: 'Invested Amount',
                value: investedAmountStr,
              ),
              CalculatorSummaryItem(
                label: 'Gain',
                value: gainStr,
              ),
            ],
          ),
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
                ? InvestmentDataTable.investment(
                    data: data,
                    showMonthly: false,
                  )
                : BarChartSection(chartData: chartData),
          ),
        ],
      ),
    );
  }
}
