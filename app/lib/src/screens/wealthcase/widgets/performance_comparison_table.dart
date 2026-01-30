import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerformanceComparisonTable extends StatelessWidget {
  final controller = Get.find<WealthcaseController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Performance',
              style: context.headlineMedium?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                WidgetSpan(child: SizedBox(width: 8)),
                TextSpan(
                  text: 'vs Other',
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTable(context),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final wealthcaseModel = controller.selectedWealthcase!;

    if (wealthcaseModel.performance == null) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    final periods = wealthcaseModel.availablePeriods;
    final benchmarkNames = _getBenchmarkNames(wealthcaseModel);

    return Row(
      children: [
        // Fixed "Returns" column
        Container(
          width: 80,
          child: Column(
            children: [
              _buildHeaderCell('Returns', context, isFixed: true),
              ...periods.asMap().entries.map((entry) {
                final index = entry.key;
                final period = entry.value;
                final isFirstRow = index == 0;
                return _buildDataCell(
                  period,
                  context,
                  isLabel: true,
                  isFirstRow: isFirstRow,
                  isFixed: true,
                );
              }).toList(),
            ],
          ),
        ),
        // // Vertical divider
        // Container(
        //   width: 1,
        //   height: (periods.length + 1) * 48.0, // Approximate height
        //   color: ColorConstants.borderColor,
        // ),
        // Scrollable columns for basket and benchmarks
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: Column(
                children: [
                  // Header row for scrollable columns
                  Row(
                    children: [
                      _buildScrollableHeaderCell('This Basket', context),
                      ...benchmarkNames
                          .map((name) =>
                              _buildScrollableHeaderCell(name, context))
                          .toList(),
                    ],
                  ),
                  // Data rows for scrollable columns
                  ...periods.asMap().entries.map((entry) {
                    final index = entry.key;
                    final period = entry.value;
                    return _buildScrollableDataRow(period, index, context,
                        benchmarkNames, wealthcaseModel);
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getBenchmarkNames(WealthcaseModel wealthcaseModel) {
    if (wealthcaseModel.benchmarks.isNullOrEmpty) {
      return []; // Default fallback
    }
    return wealthcaseModel.benchmarks!
        .map((benchmark) => benchmark.name ?? 'Unknown')
        .toList();
  }

  Widget _buildHeaderCell(
    String text,
    BuildContext context, {
    bool isFixed = false,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isFixed ? ColorConstants.white : null,
        // border: isFixed
        //     ? Border(
        //         bottom: BorderSide(color: ColorConstants.borderColor),
        //       )
        //     : null,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.titleLarge?.copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    BuildContext context, {
    bool isLabel = false,
    bool isFirstRow = false,
    bool isFixed = false,
  }) {
    return Container(
      height: 48,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isFixed ? ColorConstants.white : null,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.titleLarge?.copyWith(
            color:
                isLabel ? ColorConstants.tertiaryBlack : ColorConstants.black,
            fontWeight: isLabel ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableHeaderCell(String text, BuildContext context) {
    return SizedBox(
      width: 120,
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableDataRow(
    String period,
    int periodIndex,
    BuildContext context,
    List<String> benchmarkNames,
    WealthcaseModel wealthcaseModel,
  ) {
    // Get performance data from performanceSummary
    final periodKey = period.toLowerCase();
    final periodData = wealthcaseModel.tableData[periodKey] ?? {};

    // Get basket performance
    final basketName = wealthcaseModel.name ?? 'Basket';
    final basketPerformance = periodData[basketName];

    // Get benchmark performances
    final benchmarkPerformances = benchmarkNames.map((benchmarkName) {
      return periodData[benchmarkName];
    }).toList();

    final isFirstRow = periodIndex == 0;

    return Row(
      children: [
        // This Basket column
        SizedBox(
          width: 120,
          height: 48,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Center(
              child: Text(
                _formatPercentage(basketPerformance),
                textAlign: TextAlign.center,
                style: context.titleLarge?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        // Benchmark columns
        ...benchmarkPerformances
            .map((performance) => SizedBox(
                  width: 120,
                  height: 48,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Center(
                      child: Text(
                        _formatPercentage(performance),
                        textAlign: TextAlign.center,
                        style: context.titleLarge?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  String _formatPercentage(double? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(1)}%';
  }
}
