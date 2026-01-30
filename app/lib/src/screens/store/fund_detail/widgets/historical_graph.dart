import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/chart_controller.dart';
import 'package:core/modules/mutual_funds/models/mf_index_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoricalGraph extends StatelessWidget {
  // fields
  final String? productVariant;
  final String? wSchemeCode;
  final Color? backgroundColor;
  final bool isFund;
  final GoalSubtypeModel? portfolio;
  final SchemeMetaModel? fund;
  final EdgeInsetsGeometry? padding;

  // Constructor
  const HistoricalGraph({
    Key? key,
    this.productVariant,
    this.backgroundColor,
    this.wSchemeCode,
    this.isFund = false,
    this.portfolio,
    this.fund,
    this.padding,
  })  : assert(productVariant != null ? portfolio != null : true),
        assert(isFund ? wSchemeCode != null && fund != null : true),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    String tag = productVariant ?? wSchemeCode ?? '';
    Get.put(
      ChartController(
        isFund,
        productVariant: productVariant,
        wSchemeCode: wSchemeCode,
        portfolio: portfolio,
        fund: fund,
      ),
      tag: tag,
    );

    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        padding: padding ?? const EdgeInsets.fromLTRB(12.0, 16.0, 18.0, 18.0),
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorConstants.lightScaffoldBackgroundColor,
        ),
        child: GetBuilder<ChartController>(
          // global: false,
          tag: tag,
          // init: Get.find<ChartController>(tag: tag),
          // dispose: (_) {
          //   Get.delete<ChartController>(tag: tag);
          // },
          builder: (controller) {
            int? selectedTab = controller.selectedTab;

            return Column(
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
                              children: controller.tabs
                                  .map((tab) => _buildTabButton(
                                        context,
                                        tab,
                                        selectedTab == tab,
                                        onPressed: () async {
                                          controller.updateTab(tab);

                                          await controller.getChartData();
                                        },
                                      ))
                                  .toList()
                              // ..add(
                              //   _buildTabButton(
                              //     context,
                              //     "Max",
                              //     controller.isMaxTabSelected,
                              //     onPressed: () async {
                              //       controller.setMaxTab();

                              //       await controller.getChartData();
                              //     },
                              //   ),
                              // ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // if (controller.chartState != NetworkState.loading)
                _buildSchemeVsIndex(context, controller),

                const SizedBox(height: 20),
                // Nav Percentage
                // GetBuilder<ChartController>(
                //   global: false,
                //   init: Get.find<ChartController>(tag: tag),
                //   id: 'chart',
                //   builder: (controller) {
                //     return Center(
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           controller.navPercentage == 0 ||
                //                   controller.chartState != NetworkState.loaded
                //               ? SizedBox()
                //               : controller.navPercentage > 0
                //                   ? Icon(
                //                       Icons.arrow_drop_up,
                //                       size: 32,
                //                       color: ColorConstants
                //                           .secondaryGreenAccentColor,
                //                     )
                //                   : Icon(
                //                       Icons.arrow_drop_down,
                //                       size: 32,
                //                       color: ColorConstants.redAccentColor,
                //                     ),
                //           Padding(
                //             padding:
                //                 const EdgeInsets.only(left: 7.0, right: 12),
                //             child: Text(
                //               controller.navPercentage == 0 ||
                //                       controller.chartState !=
                //                           NetworkState.loaded
                //                   ? ' --'
                //                   : '${controller.navPercentage.toStringAsFixed(2)}%',
                //               style: Theme.of(context)
                //                   .primaryTextTheme
                //                   .headlineMedium!
                //                   .copyWith(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.w600,
                //                     color: controller.navPercentage == 0 ||
                //                             controller.chartState !=
                //                                 NetworkState.loaded
                //                         ? ColorConstants.lightGrey
                //                         : ColorConstants.black,
                //                   ),
                //             ),
                //           ),
                //           if (selectedTab != null)
                //             Text(
                //               "Last ${selectedTab < 12 ? selectedTab % 12 : selectedTab ~/ 12} ${selectedTab < 12 ? 'Month' : 'Year'}${selectedTab < 12 ? (selectedTab % 12) == 1 ? '' : 's' : (selectedTab / 12) == 1 ? '' : 's'}",
                //               style: Theme.of(context)
                //                   .primaryTextTheme
                //                   .headlineSmall!
                //                   .copyWith(
                //                     color: ColorConstants.tertiaryBlack,
                //                   ),
                //             )
                //           else if (controller.isMaxTabSelected)
                //             Text(
                //               "Max",
                //               style: Theme.of(context)
                //                   .primaryTextTheme
                //                   .headlineSmall!
                //                   .copyWith(
                //                     color: ColorConstants.tertiaryBlack,
                //                   ),
                //             ),
                //         ],
                //       ),
                //     );
                //   },
                // ),

                const SizedBox(height: 35.0),

                // Chart
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: GetBuilder<ChartController>(
                      global: false,
                      init: Get.find<ChartController>(tag: tag),
                      builder: (controller) {
                        return Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Visibility(
                              replacement: SizedBox.expand(),
                              visible: controller.chartState ==
                                      NetworkState.loaded &&
                                  controller.chartDataResult.isNotEmpty,
                              child: LineChart(
                                _chartData(controller, context),
                                duration: Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                              ),
                            ),
                            if (controller.chartState == NetworkState.loading)
                              CircularProgressIndicator(),
                            if (controller.chartState == NetworkState.error ||
                                (controller.chartState == NetworkState.loaded &&
                                    controller.chartDataResult.isEmpty))
                              Text(
                                controller.chartErrorMessage!.isEmpty
                                    ? dataNotPresentText
                                    : controller.chartErrorMessage!,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 13,
                                      color: ColorConstants.darkGrey,
                                    ),
                              )
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          },
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
      lineTouchData: controller.chartState == NetworkState.loaded
          ? _lineTouchData(context, controller)
          : LineTouchData(enabled: false),
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
      // colors: [
      //   controller.chartState == NetworkState.loading
      //       ? ColorConstants.lightBackgroundColor
      //       : ColorConstants.primaryAppColor,
      // ],
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
      // getTextStyles: (context, value) =>
      //     Theme.of(context).primaryTextTheme.bodySmall.copyWith(
      //           color: ColorConstants.tertiaryBlack,
      //           fontSize: 9,
      //           fontWeight: FontWeight.w400,
      //         ),
      // getTitles: (value) {
      //   return _getBottomTitle(value, duration);
      // },
      // checkToShowTitle: (double minValue, double maxValue,
      //     SideTitles sideTitles, double appliedInterval, double value) {
      //   return minValue != value && maxValue != value;
      // },
      // margin: 8,
      // interval: _getBottomInterval(duration),
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
        LogUtil.printLog(value);
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

  LineTouchData _lineTouchData(
      BuildContext context, ChartController controller) {
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
      touchTooltipData: _lineTouchTooltipData(context, controller),
      getTouchLineStart: (_, __) => double.negativeInfinity,
      getTouchLineEnd: (_, __) => double.infinity,
    );
  }

  LineTouchTooltipData _lineTouchTooltipData(
      BuildContext context, ChartController controller) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .bodySmall!
        .copyWith(fontWeight: FontWeight.w500, fontSize: 10);

    return LineTouchTooltipData(
      getTooltipColor: (LineBarSpot _) {
        return Colors.white;
      },
      fitInsideHorizontally: true,
      tooltipMargin: 60,
      maxContentWidth: double.infinity,
      tooltipPadding: const EdgeInsets.all(2),
      showOnTopOfTheChartBoxArea: false,
      getTooltipItems: (lineBarSpots) {
        if (isFund) {
          return lineBarSpots.mapIndexed((spot, index) {
            double? nav;
            String displayName;
            // Use spot.barIndex to determine which line this spot belongs to
            // barIndex 0 = fund data (first line), barIndex 1 = index data (second line)
            if (spot.barIndex == 0) {
              displayName = 'This fund';
              if (controller.chartDataResult.length > spot.spotIndex) {
                nav = controller.chartDataResult[spot.spotIndex].nav;
              }
            } else {
              if (controller.indexChartData.length > spot.spotIndex) {
                nav = controller.indexChartData[spot.spotIndex].nav;
              }
              displayName = controller.selectedMfIndex?.name ?? '';
            }

            return LineTooltipItem(
                '● ',
                textStyle.copyWith(
                    color: spot.barIndex == 0
                        ? ColorConstants.primaryAppColor
                        : ColorConstants.greenAccentColor,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(text: ' $displayName ', style: textStyle),
                  TextSpan(
                      text:
                          '${nav != null ? 'NAV $nav (${spot.y.toStringAsFixed(2)}%)' : '${spot.y.toStringAsFixed(2)}%'} | ${DateFormat('MMM dd yyyy').format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                      style: textStyle.copyWith(
                          color: ColorConstants.tertiaryBlack)),
                ]
                // 'NAV ${spot.y.toStringAsFixed(2)} | ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                // Theme.of(context)
                //     .primaryTextTheme
                //     .bodySmall!
                //     .copyWith(fontWeight: FontWeight.w500, fontSize: 10),
                );
          }).toList();
        } else {
          return lineBarSpots
              .map(
                (spot) => LineTooltipItem(
                  'NAV ${spot.y.toStringAsFixed(2)} | ${DateFormat('MMM DD YYYY').format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                  Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 10),
                ),
              )
              .toList();
        }
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

  // double _getBottomInterval(int duration) {
  //   switch (duration) {
  //     case 1:
  //       return Duration(days: 8).inMilliseconds.toDouble();
  //     case 3:
  //       return Duration(days: 15).inMilliseconds.toDouble();
  //     case 6:
  //       return Duration(days: 30).inMilliseconds.toDouble();
  //     case 12:
  //       return Duration(days: 50).inMilliseconds.toDouble();
  //     case 36:
  //       return Duration(days: 360).inMilliseconds.toDouble();
  //     case 60:
  //       return Duration(days: 360).inMilliseconds.toDouble();
  //     default:
  //       return Duration(days: duration * 5).inMilliseconds.toDouble();
  //   }
  // }

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
                    _buildIndexDropdown(context, controller),
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

  Widget _buildIndexDropdown(BuildContext context, ChartController controller) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w600);

    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Container(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ColorConstants.borderColor),
          ),
          child: controller.selectedMfIndex != null
              ? Row(
                  children: [
                    Text('●',
                        style: textStyle.copyWith(
                            color: ColorConstants.greenAccentColor)),
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
                  style:
                      textStyle.copyWith(color: ColorConstants.tertiaryBlack),
                ),
        ),
        items: controller.mfIndices
            .map(
              (MfIndexModel mfIndex) => DropdownMenuItem(
                value: mfIndex,
                onTap: () {
                  if (controller.chartState != NetworkState.loading) {
                    controller.updateSelectedMfIndex(mfIndex);
                  }
                },
                child: Text(
                  '${mfIndex.name}',
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {},
        dropdownStyleData: DropdownStyleData(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          offset: const Offset(-40, -10),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}
