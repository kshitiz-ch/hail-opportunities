import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/screens/calculator_new/view/calculator_screen.dart';
import 'package:app/src/screens/calculator_new/widgets/calculator_summary_section.dart';
import 'package:app/src/screens/calculator_new/widgets/graph_table_tabs.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_swp_bar_chart_section.dart';
import 'package:app/src/screens/calculator_new/widgets/sip_swp_data_table.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipSwpResultView extends StatelessWidget {
  final CalculatorController controller = Get.find<CalculatorController>();

  @override
  Widget build(BuildContext context) {
    final errorMessage = controller.precheckErrorMessage();

    if (errorMessage.isNotNullOrEmpty) {
      return buildErrorView(errorMessage!, context);
    }

    // Call the controller method to get SIP+SWP calculation results
    final data = controller.calculateSIPSWPData();

    // Calculate summary values from the data
    final corpusBeforeSwp = data['corpus_before_swp'] ?? 0;
    final totalWithdrawal = data['corpus_used'] ?? 0;
    final leftoverCorpus = data['leftover_corpus'] ?? 0;
    final sustainAge = WealthyCast.toInt(data['sustain_till_age']) ?? 0;

    final chartData = WealthyCast.toList(data['return_data']).map((entry) {
      final yearLabel = entry['year_label'] ?? '0';
      final corpus = entry['corpus'] ?? 0;
      final phase = entry['phase'] ?? 'SIP';
      return SipSwpChartData(
        xLabel: yearLabel,
        yValue: corpus,
        phase: phase,
      );
    }).toList();

    // Prepare table data
    final tableData = WealthyCast.toList(data['return_data'])
        .map((e) => e as Map<String, dynamic>)
        .toList();

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
                value: WealthyAmount.currencyFormat(corpusBeforeSwp, 0),
              ),
              CalculatorSummaryItem(
                label: 'Total Withdrawal',
                value: WealthyAmount.currencyFormat(totalWithdrawal, 0),
              ),
              CalculatorSummaryItem(
                label: 'Remaining Corpus',
                value: WealthyAmount.currencyFormat(leftoverCorpus, 0),
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
                ? SipSwpDataTable(data: tableData)
                : SipSwpBarChartSection(chartData: chartData),
          ),
        ],
      ),
    );
  }
}
