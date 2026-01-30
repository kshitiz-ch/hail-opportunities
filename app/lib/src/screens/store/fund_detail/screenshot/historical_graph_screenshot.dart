import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/chart_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoricalGraphScreenshot {
  final fundDetailcontroller = Get.find<FundDetailController>();

  Widget getHistoricalGraphScreenshotWidget(BuildContext context) {
    final fund = fundDetailcontroller.fund!;
    final tag = fund.wschemecode ?? '';
    final chartController = Get.find<ChartController>(tag: tag);
    int? selectedTab = chartController.selectedTab;

    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 18.0, 18.0),
        decoration: BoxDecoration(
          color: ColorConstants.secondaryWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Range Tab Bar
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: ButtonBar(
                        mainAxisSize: MainAxisSize.min,
                        buttonPadding: EdgeInsets.zero,
                        alignment: MainAxisAlignment.center,
                        children: chartController.tabs
                            .map(
                              (tab) => _buildTabButton(
                                context,
                                tab,
                                selectedTab == tab,
                                onPressed: () async {},
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // if (controller.chartState != NetworkState.loading)
            _buildSchemeVsIndex(context, chartController),

            const SizedBox(height: 20),

            const SizedBox(height: 35.0),

            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: LineChart(
                  _chartData(chartController, context),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  InkWell _buildTabButton(
    BuildContext context,
    dynamic val,
    bool isSelected, {
    VoidCallback? onPressed,
  }) {
    return InkWell(
      child: AnimatedContainer(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        // margin: const EdgeInsets.only(bottom: 4.0),
        duration: Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.secondaryAppColor
              : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(40) : null,
          border: isSelected
              ? Border.all(
                  width: 1,
                  color: ColorConstants.primaryAppColor,
                )
              : null,
        ),
        child: Center(
          child: Text(
            val is int
                ? "${val < 12 ? val % 12 : val ~/ 12}${val < 12 ? ' M' : ' Y'}"
                : val,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                ),
          ),
        ),
      ),
      onTap: onPressed,
    );
  }

  Widget _buildSchemeVsIndex(BuildContext context, ChartController controller) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: EdgeInsets.only(top: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 10, right: 20, bottom: 5, top: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorConstants.borderColor),
                ),
                child: Row(
                  children: [
                    Text('●',
                        style: textStyle.copyWith(
                            color: ColorConstants.primaryAppColor)),
                    SizedBox(width: 5),
                    Text('This Fund', style: textStyle),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  controller.navPercentage.isNotNullOrZero
                      ? "${controller.navPercentage.toStringAsFixed(2)} %"
                      : '-',
                  style: textStyle.copyWith(
                      color: ColorConstants.primaryAppColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          if (!controller.isDebtFund)
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Text(
                    'vs',
                    style:
                        textStyle.copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ),
                Column(
                  children: [
                    // _buildIndexDropdown(context, controller),

                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 5, top: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ColorConstants.borderColor),
                      ),
                      child: controller.selectedMfIndex != null
                          ? Row(
                              children: [
                                Text('●',
                                    style: textStyle.copyWith(
                                        color:
                                            ColorConstants.greenAccentColor)),
                                SizedBox(width: 5),
                                Text(controller.selectedMfIndex?.name ?? '-',
                                    style: textStyle),
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 5),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: ColorConstants.greenAccentColor,
                                  ),
                                )
                              ],
                            )
                          : Text(
                              'Choose an index',
                              style: textStyle.copyWith(
                                  color: ColorConstants.tertiaryBlack),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        controller.indexPercentage.isNotNullOrZero
                            ? "${controller.indexPercentage.toStringAsFixed(2)} %"
                            : '-',
                        style: textStyle.copyWith(
                            color: ColorConstants.greenAccentColor,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            )
        ],
      ),
    );
  }

  LineChartData _chartData(ChartController controller, BuildContext context) {
    return LineChartData(
      gridData: _gridData(controller.minPercentage, controller.maxPercentage),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: _bottomTitles(controller.selectedTab, context),
        ),
        leftTitles: AxisTitles(
          sideTitles: _leftTitles(
              controller.minPercentage, controller.maxPercentage, context),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineBarsData: [
        _lineBarData(controller),
        if (!controller.isDebtFund) _indexBarData(controller),
      ],
      borderData: FlBorderData(show: false),
      // lineTouchData: controller.chartState == NetworkState.loaded
      //     ? _lineTouchData(context, controller)
      //     : LineTouchData(enabled: false),
      minY: (controller.maxPercentage == controller.minPercentage)
          ? controller.minPercentage - controller.minPercentage / 20
          : controller.minPercentage -
              (controller.maxPercentage - controller.minPercentage) / 20,
      maxY: (controller.maxPercentage == controller.minPercentage)
          ? controller.maxPercentage + controller.maxPercentage / 20
          : controller.maxPercentage +
              (controller.maxPercentage - controller.minPercentage) / 20,
    );
  }

  LineChartBarData _lineBarData(ChartController controller) {
    return LineChartBarData(
      spots: controller.chartDataResult
          .map(
            (data) =>
                FlSpot(data.millisecondsSinceEpoch.toDouble(), data.percentage),
          )
          .toList(),
      color: controller.chartState == NetworkState.loading
          ? ColorConstants.lightBackgroundColor
          : ColorConstants.primaryAppColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
    );
  }

  LineChartBarData _indexBarData(ChartController controller) {
    return LineChartBarData(
      spots: controller.indexChartData
          .map(
            (data) =>
                FlSpot(data.millisecondsSinceEpoch.toDouble(), data.percentage),
          )
          .toList(),
      color: controller.chartState == NetworkState.loading
          ? ColorConstants.lightBackgroundColor
          : ColorConstants.greenAccentColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
    );
  }

  SideTitles _bottomTitles(int? duration, BuildContext context) {
    return SideTitles(
      showTitles: true,
      reservedSize: 30,
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

  SideTitles _leftTitles(double min, double max, BuildContext context) {
    late bool shouldRoundPercentageDiff;
    if ((max == 0 && min == 0) || (max == min)) {
      shouldRoundPercentageDiff = true;
    } else if (((max - min) / 5) < 1) {
      // if the difference between each interval is less than 1
      // then dont round, instead show the decimal point of the percentage difference
      shouldRoundPercentageDiff = false;
    } else {
      shouldRoundPercentageDiff = true;
    }

    return SideTitles(
      showTitles: true,
      reservedSize: 40,
      interval: (max == 0 && min == 0)
          ? null
          : (max == min)
              ? ((max + max / 20) - (min - min / 20)) / 5
              : (max - min) / 5,
      getTitlesWidget: (value, meta) {
        if (meta.min != value && meta.max != value) {
          String percentage;
          if (shouldRoundPercentageDiff) {
            percentage = value.toInt().toString();
          } else {
            percentage = value.toStringWithoutTrailingZero(1) ?? '0';
          }

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              "$percentage %",
              style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          );
        }
        return SizedBox();
      },
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

  String _getBottomTitle(double millisecondsSinceEpoch, int? duration) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch.toInt(),
    );

    switch (duration) {
      case 1:
        return DateFormat.MMMd()
            .format(date)
            .splitMapJoin(' ', onMatch: (_) => '\n');
      case 3:
        return DateFormat.MMM().format(date);
      case 6:
        return DateFormat.MMM().format(date);
      case 12:
        return DateFormat.MMM().format(date);
      case 36:
        return DateFormat.yMMM()
            .format(date)
            .splitMapJoin(' ', onMatch: (_) => '\n');
      case 60:
        return DateFormat.yMMM()
            .format(date)
            .splitMapJoin(' ', onMatch: (_) => '\n');
      default:
        return DateFormat.MMM().format(date);
    }
  }
}
