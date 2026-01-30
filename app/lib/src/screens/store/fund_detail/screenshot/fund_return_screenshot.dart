import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_return_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/investment_slider.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FundReturnCalculatorScreenshot {
  final fundDetailcontroller = Get.find<FundDetailController>();
  final fundReturnCalculator = Get.find<FundReturnController>();

  Widget getFundReturnCalculatorScreenshotWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvestmentType(context, fundReturnCalculator),
          _buildInvestmentSlider(
              inputType: FundReturnInputType.Amount, context: context),
          SizedBox(height: 40),
          _buildInvestmentSlider(
            inputType: FundReturnInputType.Period,
            context: context,
          ),
          SizedBox(height: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReturnOverview(context, fundReturnCalculator),
              ),
              _buildFundReturnChart(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundReturnChart(BuildContext context) {
    if (fundReturnCalculator.fundReturnModel!.chartDataResult.isNullOrEmpty) {
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
    final minCurrentValue =
        fundReturnCalculator.fundReturnModel!.minCurrentValue;
    final maxCurrentValue =
        fundReturnCalculator.fundReturnModel!.maxCurrentValue;
    final duration =
        (int.tryParse(fundReturnCalculator.periodController.text) ?? 0);

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
      // lineTouchData: _lineTouchData(context),
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
      spots: fundReturnCalculator.fundReturnModel!.chartDataResult
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

  Widget _buildReturnOverview(
    BuildContext context,
    FundReturnController controller,
  ) {
    final currentValue = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.currentValue, 0);
    final investedValue = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.investedValue, 0);
    String irr = '-';
    if (controller.fundReturnModel!.xirrPercentage != null) {
      irr =
          '${controller.fundReturnModel!.xirrPercentage?.toStringAsFixed(1)}%';
    }
    String absoluteGain = '-';
    if (controller.fundReturnModel!.absoluteGain != null) {
      absoluteGain = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.absoluteGain,
        0,
      );
      if (controller.fundReturnModel!.absoluteGainPercentage != null) {
        absoluteGain += ' (${WealthyAmount.formatNumber(
          controller.fundReturnModel!.absoluteGainPercentage!
              .toStringAsFixed(1),
        )}%)';
      }
    }

    final data = [
      ['Invested Amount', investedValue],
      ['Current Value', currentValue],
      ['IRR ', irr],
      ['Absolute Gain', absoluteGain]
    ];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            2,
            (col) {
              return Padding(
                padding: EdgeInsets.only(bottom: col == 0 ? 15 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<Widget>.generate(
                    2,
                    (row) {
                      final item = data[2 * col + row];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: CommonUI.buildColumnTextInfo(
                            title: item.first,
                            subtitle: item.last,
                            subtitleMaxLength: 2,
                            gap: 5,
                            titleStyle: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.tertiaryBlack,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            subtitleStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '*Calculations are as on ${DateFormat('dd MMM yyyy').format(controller.fund.navDate!)}',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 10,
                  color: ColorConstants.tertiaryBlack,
                  fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInvestmentSlider({
    required FundReturnInputType inputType,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Investment ${inputType == FundReturnInputType.Amount ? 'Amount' : 'Period'}',
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black,
                  ),
            ),
            Spacer(),
            _buildTextField(context, fundReturnCalculator, inputType)
          ],
        ),
        SizedBox(height: 20),
        _buildSlider(context, fundReturnCalculator, inputType),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    FundReturnController controller,
    FundReturnInputType inputType,
  ) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              height: 18 / 16,
            );

    late TextEditingController textController;
    String? errorMessage;
    int maxLength = 11;

    final width = 120.0;
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorConstants.primaryAppColor,
      ),
      borderRadius: BorderRadius.circular(4),
    );
    if (inputType == FundReturnInputType.Amount) {
      textController = controller.amountController;
      errorMessage = controller.amountErrorText;
      // 1,00,00,000
      maxLength = 11;
    } else {
      textController = controller.periodController;
      errorMessage = controller.periodErrorText;
      // 40
      maxLength = 2;
    }
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: ColorConstants.primaryAppv3Color,
              border: Border.all(
                color: ColorConstants.primaryAppColor,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            alignment: Alignment.center,
            child: Text(
              textController.text,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          if (errorMessage.isNotNullOrEmpty)
            Text(
              errorMessage!,
              maxLines: 2,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.errorTextColor,
                  ),
            )
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    FundReturnController controller,
    FundReturnInputType inputType,
  ) {
    final min = controller.minSlider.toDouble();
    final max = controller.maxSlider(inputType).toDouble();
    final value = inputType == FundReturnInputType.Amount
        ? (controller.sliderAmountFromInput ?? controller.sliderAmount)
            .toDouble()
        : (controller.sliderPeriodFromInput ?? controller.sliderPeriod)
            .toDouble();

    final clampedValue = value.clamp(min, max);

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ColorConstants.primaryAppColor,
            inactiveTrackColor: ColorConstants.borderColor,
            trackHeight: 3.0,
            thumbShape: CustomThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            value: clampedValue,
            onChanged: (newValue) {},
            onChangeEnd: (newValue) {},
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (max - min).toInt() + 1,
              (index) {
                final labelValue = min + index;
                return Container(
                  width: 3,
                  child: Center(
                    child: Text(
                      getSliderLabelText(labelValue, controller, inputType),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall
                          ?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontSize: 10,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String getSliderLabelText(
    dynamic actualValue,
    FundReturnController controller,
    FundReturnInputType inputType,
  ) {
    final maxLength = inputType == FundReturnInputType.Period
        ? controller.sliderPeriodValues.length
        : controller.sliderAmountValues.length;
    final valueIndex = min(WealthyCast.toInt(actualValue) ?? 0, maxLength);
    String data = '';
    if (inputType == FundReturnInputType.Period) {
      data = controller.sliderPeriodValues[valueIndex].toInt().toString();
    } else {
      final amount = controller.sliderAmountValues[valueIndex];
      data =
          WealthyAmount.currencyFormat(amount.toString(), 0, showSuffix: true);
      data = data.replaceAll('₹', '');
    }
    return data;
  }

  Widget _buildInvestmentType(
    BuildContext context,
    FundReturnController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Type ',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 13, bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.darkBlack.withOpacity(0.05),
                offset: Offset(0.0, 0.0),
                spreadRadius: 0.0,
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: InvestmentType.values.map<Widget>(
              (investmentType) {
                final text = investmentType == InvestmentType.SIP
                    ? 'Monthly SIP'
                    : 'Lumpsum';
                final isSelected =
                    investmentType == controller.selectedInvestmentType;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: isSelected
                        ? ColorConstants.primaryAppv3Color
                        : ColorConstants.white,
                    border: isSelected
                        ? Border.all(color: ColorConstants.primaryAppColor)
                        : Border.fromBorderSide(BorderSide.none),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? ColorConstants.primaryAppColor
                              : ColorConstants.tertiaryBlack,
                        ),
                  ),
                );
              },
            ).toList(),
          ),
        )
      ],
    );
  }
}
