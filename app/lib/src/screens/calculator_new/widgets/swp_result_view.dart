import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/view/calculator_screen.dart';
import 'package:app/src/screens/calculator_new/widgets/bar_chart_section.dart';
import 'package:app/src/screens/calculator_new/widgets/calculator_summary_section.dart';
import 'package:app/src/screens/calculator_new/widgets/graph_table_tabs.dart';
import 'package:app/src/screens/calculator_new/widgets/investment_data_table.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwpResultView extends StatelessWidget {
  final CalculatorController controller = Get.find<CalculatorController>();

  @override
  Widget build(BuildContext context) {
    final errorMessage = controller.precheckErrorMessage();

    if (errorMessage.isNotNullOrEmpty) {
      return buildErrorView(errorMessage!, context);
    }
    // Call the controller method to get lumpsum calculation results
    final data = controller.calculateSWPData();

    // Calculate summary values from the data
    final corpusAtWithdrawalStart = data['corpus_before_swp'] ?? 0;
    final totalWithdrawal = data['corpus_used'] ?? 0;
    final remainingCorpus = data['final_corpus'] ?? 0;
    final sustainAge = WealthyCast.toInt(data['sustain_till_age']) ?? 0;

    final chartData = WealthyCast.toList(data['return_data']).map((entry) {
      final xLabel = entry['year'] ?? 0;
      final investment = entry['investment'] ?? 0;
      final gain = entry['gain'] ?? 0;
      return CalculatorBarChartData(
        xLabel: 'Age ${xLabel.toInt()}',
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
                label:
                    'Corpus at age ${controller.withdrawalStartAge.value.toInt()}',
                value: WealthyAmount.currencyFormat(corpusAtWithdrawalStart, 0),
              ),
              CalculatorSummaryItem(
                label: 'Total Withdrawal',
                value: WealthyAmount.currencyFormat(totalWithdrawal, 0),
              ),
              CalculatorSummaryItem(
                label: 'Remaining Corpus',
                value: WealthyAmount.currencyFormat(remainingCorpus, 0),
              ),
              CalculatorSummaryItem(
                label: 'Sustainable Till Age',
                value: sustainAge >= 100 ? '99+' : sustainAge.toString(),
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
                ? InvestmentDataTable.swp(data: data['return_data'])
                : BarChartSection(chartData: chartData),
          ),
        ],
      ),
    );
  }
}
