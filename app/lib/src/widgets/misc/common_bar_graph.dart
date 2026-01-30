import 'package:app/src/config/constants/color_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CommonBarGraph extends StatefulWidget {
  final int totalBar;
  final String Function(double) getLeftTitle;
  final String Function(double) getBottomTitle;
  final bool isDailyGraph;
  final bool showMaxLeftTitle;
  final double Function(int) getBarHeight;
  final String Function(int) getToolTipText;

  const CommonBarGraph({
    Key? key,
    required this.totalBar,
    required this.getLeftTitle,
    required this.getBottomTitle,
    this.isDailyGraph = false,
    this.showMaxLeftTitle = true,
    required this.getBarHeight,
    required this.getToolTipText,
  }) : super(key: key);

  @override
  State<CommonBarGraph> createState() => _CommonBarGraphtate();
}

class _CommonBarGraphtate extends State<CommonBarGraph> {
  int showingTooltip = -1;
  int touchedGroupIndex = -1;

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 20,
          borderRadius: BorderRadius.zero,
        ),
      ],
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(
          border: Border(
            bottom: BorderSide(
              color: ColorConstants.silverSandColor,
              width: 0.55,
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                final isMaxValue =
                    (value == meta.max && value % meta.appliedInterval != 0);
                // show title only for scale values eg 100, 150, 200
                // not for 205
                if (isMaxValue && widget.showMaxLeftTitle == false) {
                  return SizedBox();
                }

                return Text(
                  widget.getLeftTitle(value),
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.tertiaryBlack,
                          ),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final isLastBar = value.toInt() == (widget.totalBar - 1);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    widget.getBottomTitle(value),
                    style:
                        Theme.of(context).primaryTextTheme.titleSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: isLastBar
                                  ? ColorConstants.black
                                  : ColorConstants.tertiaryBlack,
                            ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: ColorConstants.silverSandColor,
            strokeWidth: 0.55,
          ),
        ),
        barGroups: List<BarChartGroupData>.generate(
          widget.totalBar,
          (index) {
            Color barColor = ColorConstants.primaryAppColor;
            if (!widget.isDailyGraph) {
              barColor = index == widget.totalBar - 1
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.paleLavenderColor;
            }
            return generateBarGroup(
              index,
              barColor,
              widget.getBarHeight(index),
            );
          },
        ).toList(),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData _) {
              return ColorConstants.lightBackgroundColor;
            },
            tooltipMargin: 2,
            tooltipPadding: EdgeInsets.all(2),
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              return BarTooltipItem(
                widget.getToolTipText(groupIndex),
                Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                      color: ColorConstants.primaryAppColor,
                      fontSize: 14,
                    ),
              );
            },
          ),
          touchCallback: (event, response) {
            if (response != null &&
                response.spot != null &&
                event is FlTapUpEvent) {
              setState(() {
                final x = response.spot!.touchedBarGroup.x;
                final isShowing = showingTooltip == x;
                if (isShowing) {
                  showingTooltip = -1;
                } else {
                  showingTooltip = x;
                }
              });
            }
          },
          mouseCursorResolver: (event, response) {
            return response == null || response.spot == null
                ? MouseCursor.defer
                : SystemMouseCursors.click;
          },
        ),
      ),
    );
  }
}
