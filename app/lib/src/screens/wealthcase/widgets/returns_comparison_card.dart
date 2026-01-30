import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:app/src/screens/wealthcase/widgets/benchmark_selection_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnsComparisonCard extends StatelessWidget {
  final controller = Get.find<WealthcaseController>();

  @override
  Widget build(BuildContext context) {
    final wealthcaseModel = controller.selectedWealthcase!;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstants.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstants.borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basket returns
                  _buildReturnsRow(
                    context: context,
                    label: 'This Basket',
                    returnsText: _getBasketReturnForPeriod(),
                  ),

                  // Show benchmark comparison if showBenchmark is true
                  if (controller.showBenchmarkComparison)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: CommonUI.buildProfileDataSeperator(
                                  color: ColorConstants.borderColor,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Color(0xffF9F6FF),
                                  shape: BoxShape.circle),
                              child: Text(
                                'VS',
                                style: context.titleLarge?.copyWith(
                                  color: ColorConstants.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: CommonUI.buildProfileDataSeperator(
                                  color: ColorConstants.borderColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildReturnsRow(
                          context: context,
                          label: controller.selectedBenchmark?.name
                                  ?.toTitleCase() ??
                              'Benchmark',
                          returnsText: _getBenchmarkReturnForPeriod(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Header positioned on the border
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                color: ColorConstants.white,
                child: Text(
                  '${wealthcaseModel.selectedPeriod} Returns',
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Toggle button
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClickableText(
                text: controller.showBenchmarkComparison
                    ? 'Change Benchmark'
                    : 'Compare Benchmark',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                onClick: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: BenchmarkSelectionBottomSheet(
                      wealthcaseModel: wealthcaseModel,
                    ),
                  );
                },
              ),
              if (controller.showBenchmarkComparison)
                Text(
                  ' | ',
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (controller.showBenchmarkComparison)
                ClickableText(
                  text: 'Hide',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  textColor: ColorConstants.black,
                  onClick: () {
                    controller.selectedBenchmark = null;
                    controller.showBenchmarkComparison = false;
                    controller.update();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  String? _getBasketReturnForPeriod() {
    final wealthcaseModel = controller.selectedWealthcase!;

    final selectedPeriod = wealthcaseModel.selectedPeriod.toLowerCase();
    final periodData = wealthcaseModel.tableData[selectedPeriod];

    if (periodData == null) return 'N/A';

    final basketName = wealthcaseModel.name ?? 'Basket';
    final basketReturn = periodData[basketName];

    if (basketReturn == null) return 'N/A';

    // Format the return value
    final sign = basketReturn >= 0 ? '+' : '';
    return '$sign${basketReturn.toStringAsFixed(1)}%';
  }

  String? _getBenchmarkReturnForPeriod() {
    final wealthcaseModel = controller.selectedWealthcase!;

    final selectedBenchmark = controller.selectedBenchmark;
    if (selectedBenchmark == null) return 'N/A';

    final selectedPeriod = wealthcaseModel.selectedPeriod.toLowerCase();
    final periodData = wealthcaseModel.tableData[selectedPeriod];

    if (periodData == null) return 'N/A';

    final benchmarkReturn = periodData[selectedBenchmark.name];

    if (benchmarkReturn == null) return 'N/A';

    // Format the return value
    final sign = benchmarkReturn >= 0 ? '+' : '';
    return '$sign${benchmarkReturn.toStringAsFixed(1)}%';
  }

  Widget _buildReturnsRow({
    required BuildContext context,
    required String label,
    String? returnsText,
  }) {
    String finalReturnsText;
    Color returnsColor;

    if (returnsText != null) {
      // Use provided returnsText
      finalReturnsText = returnsText;
      if (returnsText == 'N/A' || returnsText == '-') {
        returnsColor = ColorConstants.tertiaryBlack;
      } else {
        // Determine color based on the text (check if it starts with + or -)
        returnsColor = returnsText.startsWith('-')
            ? ColorConstants.redAccentColor
            : ColorConstants.greenAccentColor;
      }
    } else {
      // Fallback
      finalReturnsText = 'N/A';
      returnsColor = ColorConstants.tertiaryBlack;
    }

    return Row(
      children: [
        Text(
          label,
          style: context.titleLarge?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          finalReturnsText,
          style: context.headlineMedium?.copyWith(
            color: returnsColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
