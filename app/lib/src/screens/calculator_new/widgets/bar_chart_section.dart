import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Data model for chart points
class CalculatorBarChartData {
  final String xLabel;
  final double yValue;
  final double yValue2;
  final String yLabel;
  final String yLabel2;

  CalculatorBarChartData({
    required this.xLabel,
    required this.yValue,
    required this.yValue2,
    required this.yLabel,
    required this.yLabel2,
  });
}

class BarChartSection extends StatefulWidget {
  final List<CalculatorBarChartData> chartData;

  const BarChartSection({super.key, required this.chartData});

  @override
  State<BarChartSection> createState() => _BarChartSectionState();
}

class _BarChartSectionState extends State<BarChartSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartSection(context),
        const SizedBox(height: 10),
        _buildChartLegend(context),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final investedColor = ColorConstants.primaryAppColor;
    final returnColor = Color(0xffCAB2FF);

    if (widget.chartData.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: Text(
          "No chart data available.",
          style: context.headlineMedium,
        ),
      );
    }
    double maxY = 0;
    for (var data in widget.chartData) {
      final totalValue = data.yValue + data.yValue2;
      if (totalValue > maxY) {
        maxY = totalValue;
      }
    }
    if (maxY == 0)
      maxY = 1; // default to 1 to avoid division by zero if all values are 0

    // Adjust maxY to give some padding at the top of the chart
    maxY *= 1.2;

    final totalBars = widget.chartData.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for chart (subtract space for left axis labels)
        final availableWidth =
            constraints.maxWidth - 80; // Reserve 80px for left axis

        // Calculate optimal bar width based on available space and number of bars
        // Leave space for bars and gaps between them
        final totalSpacing = availableWidth * 0.2; // 20% for spacing
        final barAreaWidth = availableWidth - totalSpacing;
        final calculatedBarWidth = barAreaWidth / totalBars;

        // Set bar width with min/max constraints
        final barWidth = calculatedBarWidth.clamp(5.0, 25.0);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: 280, // Adjust height as needed for fl_chart
              padding: const EdgeInsets.only(
                  top: 40, right: 16), // padding for tooltip space
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= widget.chartData.length) {
                            return const Text('');
                          }

                          final totalLabels = widget.chartData.length;

                          // Always show first and last
                          if (index == 0 || index == totalLabels - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                widget.chartData[index].xLabel,
                                style: context.titleLarge?.copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }

                          // Calculate interval to show max 5-6 labels total
                          // (including first and last)
                          final maxLabels = 6;
                          if (totalLabels <= maxLabels) {
                            // Show all labels if total is less than or equal to maxLabels
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                widget.chartData[index].xLabel,
                                style: context.titleLarge?.copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }

                          // Calculate interval for middle labels
                          final middleLabels =
                              maxLabels - 2; // Exclude first and last
                          final interval =
                              (totalLabels - 1) / (middleLabels + 1);

                          // Check if this index should be shown
                          for (int i = 1; i <= middleLabels; i++) {
                            final targetIndex = (interval * i).round();
                            if (index == targetIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  widget.chartData[index].xLabel,
                                  style: context.titleLarge?.copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                          }

                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60, // Increased reserved size
                        interval:
                            maxY / 4, // Show 5 labels (0, 1/4, 1/2, 3/4, maxY)
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final label = WealthyAmount.currencyFormat(value, 0,
                              showSuffix: true);
                          return Text(
                            label,
                            style: context.titleLarge
                                ?.copyWith(color: ColorConstants.tertiaryBlack),
                            textAlign: TextAlign.left, // Align text to the left
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.5,
                      );
                    },
                    horizontalInterval: maxY / 4, // Match left titles interval
                  ),
                  barGroups: widget.chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final animatedY1 = data.yValue * _animation.value;
                    final animatedY2 = data.yValue2 * _animation.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: animatedY1 + animatedY2,
                          rodStackItems: [
                            BarChartRodStackItem(0, animatedY1, investedColor),
                            BarChartRodStackItem(animatedY1,
                                animatedY1 + animatedY2, returnColor),
                          ],
                          width: barWidth, // Adjust bar width dynamically
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    // For tooltips on touch/hover
                    enabled: true, // Enable touch events
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) =>
                          Colors.white,
                      tooltipBorder: BorderSide(color: Colors.grey.shade300),
                      tooltipPadding: const EdgeInsets.all(8),
                      maxContentWidth: 200, // Added to restrict tooltip width
                      fitInsideHorizontally:
                          true, // Prevent tooltip from going outside screen horizontally
                      fitInsideVertically:
                          true, // Prevent tooltip from going outside screen vertically
                      direction: TooltipDirection
                          .auto, // Auto adjust direction based on available space
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = widget.chartData[group.x.toInt()];

                        final baseStyle = context.titleSmall!
                            .copyWith(fontWeight: FontWeight.w400);

                        return BarTooltipItem(
                          '',
                          baseStyle,
                          children: <TextSpan>[
                            TextSpan(
                              text: '${data.xLabel}\n',
                              style: baseStyle.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '● ',
                                  style: baseStyle.copyWith(
                                      color: investedColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text:
                                      '${data.yLabel}: ${WealthyAmount.currencyFormat(data.yValue, 2, showSuffix: true)}',
                                  style: baseStyle.copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            TextSpan(text: '\n'), // Newline
                            TextSpan(children: [
                              TextSpan(
                                text: '● ',
                                style: baseStyle.copyWith(
                                    color: returnColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text:
                                    '${data.yLabel2}: ${WealthyAmount.currencyFormat(data.yValue2, 2, showSuffix: true)}',
                                style: baseStyle.copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]),
                          ],
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          ColorConstants.primaryAppColor,
          'Invested Amount',
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          context,
          Color(0xffCAB2FF),
          'Estimated Return',
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.titleLarge?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
