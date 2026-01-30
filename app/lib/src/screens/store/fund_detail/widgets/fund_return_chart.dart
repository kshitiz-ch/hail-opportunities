import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_return_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FundReturnChart extends StatelessWidget {
  final FundReturnController controller = Get.find<FundReturnController>();
  @override
  Widget build(BuildContext context) {
    if (controller.fundReturnModel!.chartDataResult.isNullOrEmpty) {
      return Center(
        child: Text(
          'No Graph Data available',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: LineChart(
        _chartData(context),
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  LineChartData _chartData(BuildContext context) {
    final minCurrentValue = controller.fundReturnModel!.minCurrentValue;
    final maxCurrentValue = controller.fundReturnModel!.maxCurrentValue;
    final duration = (int.tryParse(controller.periodController.text) ?? 0);

    return LineChartData(
      gridData: _gridData(minCurrentValue, maxCurrentValue),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: _bottomTitles(duration, context),
        ),
        leftTitles: AxisTitles(
          sideTitles: _leftTitles(
            minCurrentValue,
            maxCurrentValue,
            context,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineBarsData: [
        _lineBarData(),
      ],
      borderData: FlBorderData(show: false),
      lineTouchData: _lineTouchData(context),
      minY: (maxCurrentValue == minCurrentValue)
          ? minCurrentValue - minCurrentValue / 20
          : minCurrentValue - (maxCurrentValue - minCurrentValue) / 20,
      maxY: (maxCurrentValue == minCurrentValue)
          ? maxCurrentValue + maxCurrentValue / 20
          : maxCurrentValue + (maxCurrentValue - minCurrentValue) / 20,
    );
  }

  LineChartBarData _lineBarData() {
    return LineChartBarData(
      spots: controller.fundReturnModel!.chartDataResult
          .map(
            (data) => FlSpot(
              data.millisecondsSinceEpoch.toDouble(),
              data.currentValue,
            ),
          )
          .toList(),
      color: ColorConstants.primaryAppColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
    );
  }

  SideTitles _bottomTitles(int? duration, BuildContext context) {
    return SideTitles(
      reservedSize: 30,
      showTitles: true,
      getTitlesWidget: (value, meta) {
        if (meta.min != value && meta.max != value)
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getBottomTitle(value, duration),
              style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          );
        return SizedBox();
      },
    );
  }

  String _getBottomTitle(double millisecondsSinceEpoch, int? duration) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch.toInt(),
    );

    if (duration == 1) {
      return DateFormat.MMM().format(date);
    }

    return DateFormat.yMMM()
        .format(date)
        .splitMapJoin(' ', onMatch: (_) => '\n');
  }

  SideTitles _leftTitles(double min, double max, BuildContext context) {
    return SideTitles(
      showTitles: true,
      reservedSize: 45,
      getTitlesWidget: (value, meta) {
        if (meta.min != value && meta.max != value)
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              WealthyAmount.currencyFormat(value.toInt(), 1, showSuffix: true)
                  .substring(1),
              style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: ColorConstants.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          );
        return SizedBox();
      },
      // margin: 12,
      interval: (max == 0 && min == 0)
          ? null
          : (max == min)
              ? ((max + max / 20) - (min - min / 20)) / 5
              : (max - min) / 5,
    );
  }

  FlGridData _gridData(double min, double max) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: (max == 0 && min == 0)
          ? null
          : (max == min)
              ? ((max + max / 20) - (min - min / 20)) / 5
              : (max - min) / 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Color(0xFFE7E7E7),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  LineTouchData _lineTouchData(BuildContext context) {
    return LineTouchData(
      enabled: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: Color(0xFFd279ff),
              strokeWidth: 0.5,
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percentage, bar, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Color(0xFFd279ff),
                  strokeColor: Color(0xFFd279ff),
                );
              },
            ),
          );
        }).toList();
      },
      touchTooltipData: _lineTouchTooltipData(context),
      getTouchLineStart: (_, __) => double.negativeInfinity,
      getTouchLineEnd: (_, __) => double.infinity,
    );
  }

  LineTouchTooltipData _lineTouchTooltipData(BuildContext context) {
    return LineTouchTooltipData(
      tooltipBorderRadius: BorderRadius.circular(5),
      tooltipBorder: BorderSide(color: ColorConstants.white),
      getTooltipColor: (LineBarSpot _) {
        return ColorConstants.white;
      },
      fitInsideHorizontally: true,
      tooltipMargin: 12,
      maxContentWidth: 200,
      showOnTopOfTheChartBoxArea: true,
      getTooltipItems: (lineBarSpots) {
        return lineBarSpots.map(
          (spot) {
            final style = Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 11);

            final chartData =
                controller.fundReturnModel!.chartDataResult[spot.spotIndex];
            final date =
                '${getFormattedDate(DateTime.fromMillisecondsSinceEpoch(chartData.millisecondsSinceEpoch))}';

            final nav = chartData.nav;

            return LineTooltipItem(
              '$date | NAV (${nav})',
              style.copyWith(height: 2),
              textAlign: TextAlign.left,
              children: [
                ...getToolTipAmountRow(
                  context,
                  'Current: ',
                  chartData.currentValue,
                  0.6,
                ),
                ...getToolTipAmountRow(
                  context,
                  'Invested: ',
                  chartData.investedValue,
                  1,
                ),
              ],
            );
          },
        ).toList();
      },
    );
  }

  List<TextSpan> getToolTipAmountRow(
      BuildContext context, String key, double value, double opacity) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        );
    return [
      TextSpan(
        text: "\n${String.fromCharCode(0x2014)} ",
        style: TextStyle(
          color: ColorConstants.primaryAppColor.withOpacity(opacity),
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
      TextSpan(
        text: key,
        style: style.copyWith(color: ColorConstants.tertiaryBlack),
      ),
      TextSpan(
        text: '${WealthyAmount.currencyFormat(value, 2, showSuffix: true)}',
        style: style,
      ),
    ];
  }
}
