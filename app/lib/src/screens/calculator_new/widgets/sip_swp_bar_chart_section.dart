import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Data model for SIP+SWP bar chart with phase information
class SipSwpChartData {
  final String xLabel;
  final double yValue;
  final String phase; // 'SIP', 'HOLD', 'SWP', 'SIP+SWP'

  SipSwpChartData({
    required this.xLabel,
    required this.yValue,
    required this.phase,
  });
}

/// Specialized bar chart for SIP+SWP calculator showing three phases:
/// SIP Phase, Holding Phase, and SWP Phase
class SipSwpBarChartSection extends StatefulWidget {
  final List<SipSwpChartData> chartData;

  const SipSwpBarChartSection({super.key, required this.chartData});

  @override
  State<SipSwpBarChartSection> createState() => _SipSwpBarChartSectionState();
}

class _SipSwpBarChartSectionState extends State<SipSwpBarChartSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Define colors for three phases
  final Color sipPhaseColor = ColorConstants.primaryAppColor;
  final Color holdingPhaseColor = Color(0xffCAB2FF); // Light purple
  final Color swpPhaseColor = Color(0xff6DCFF6); // Light blue

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

  Color _getColorForPhase(String phase) {
    switch (phase) {
      case 'SIP':
      case 'SIP+SWP':
        return sipPhaseColor;
      case 'HOLD':
        return holdingPhaseColor;
      case 'SWP':
        return swpPhaseColor;
      default:
        return sipPhaseColor;
    }
  }

  Widget _buildChartSection(BuildContext context) {
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
      if (data.yValue > maxY) {
        maxY = data.yValue;
      }
    }
    if (maxY == 0) maxY = 1; // Avoid division by zero

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
              height: 280,
              padding: const EdgeInsets.only(
                  top: 40, right: 16), // Top padding for tooltip space
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
                        reservedSize: 60,
                        interval:
                            maxY / 4, // Show 5 labels (0, 1/4, 1/2, 3/4, maxY)
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final label = WealthyAmount.currencyFormat(value, 0,
                              showSuffix: true);
                          return Text(
                            label,
                            style: context.titleLarge
                                ?.copyWith(color: ColorConstants.tertiaryBlack),
                            textAlign: TextAlign.left,
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
                    horizontalInterval: maxY / 4,
                  ),
                  barGroups: widget.chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final animatedY = data.yValue * _animation.value;

                    // Get color based on phase
                    final phaseColor = _getColorForPhase(data.phase);

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: animatedY,
                          color: phaseColor,
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) =>
                          Colors.white,
                      tooltipBorder: BorderSide(color: Colors.grey.shade300),
                      tooltipPadding: const EdgeInsets.all(8),
                      maxContentWidth: 200,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      direction: TooltipDirection.auto,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = widget.chartData[group.x.toInt()];
                        final baseStyle = context.titleSmall!
                            .copyWith(fontWeight: FontWeight.w400);

                        // Get phase info
                        final phaseColor = _getColorForPhase(data.phase);
                        String phaseLabel = 'SIP Phase';
                        if (data.phase == 'HOLD') {
                          phaseLabel = 'Holding Phase';
                        } else if (data.phase == 'SWP') {
                          phaseLabel = 'SWP Phase';
                        } else if (data.phase == 'SIP+SWP') {
                          phaseLabel = 'SIP + SWP Phase';
                        }

                        return BarTooltipItem(
                          '',
                          baseStyle,
                          children: <TextSpan>[
                            TextSpan(
                              text: '${data.xLabel}\n',
                              style: baseStyle.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '$phaseLabel\n',
                              style: baseStyle.copyWith(
                                color: phaseColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Value: ${WealthyAmount.currencyFormat(data.yValue, 2, showSuffix: true)}',
                              style: baseStyle.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
        _buildLegendItem(context, sipPhaseColor, 'SIP Phase'),
        const SizedBox(width: 20),
        _buildLegendItem(context, holdingPhaseColor, 'Holding Phase'),
        const SizedBox(width: 20),
        _buildLegendItem(context, swpPhaseColor, 'SWP Phase'),
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
