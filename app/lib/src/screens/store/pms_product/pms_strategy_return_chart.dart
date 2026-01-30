import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PmsStrategyReturnChart extends StatelessWidget {
  final PMSVariantModel? product;

  PmsStrategyReturnChart({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (product == null ||
        product!.strategyVsBenchmarkLine == null ||
        product!.strategyVsBenchmarkLine!.isEmpty) {
      return Container(
        height: 300,
        child: Center(child: Text('No chart data available')),
      );
    }

    return Container(
      color: ColorConstants.secondaryWhite,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0)
                .copyWith(top: 15, bottom: 22),
            child: Text(
              'Strategy Returns',
              style: context.headlineSmall?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                product?.title ?? 'Strategy',
                ColorConstants.primaryAppColor,
                context,
              ),
              SizedBox(width: 12),
              Text(
                'vs',
                style: context.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              _buildLegendItem(
                product?.benchmarkName ?? 'Benchmark',
                Color(0xFFCAB2FF),
                context,
              ),
            ],
          ),
          SizedBox(height: 30),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 40,
                bottom: 10,
              ),
              child: LineChart(_buildLineChartData(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8).copyWith(left: 10, right: 15),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150),
            child: MarqueeWidget(
              child: Text(
                label,
                style: context.titleLarge?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(BuildContext context) {
    List<PMSLineChartModel> data = product!.strategyVsBenchmarkLine!;
    final toolTipStyle = context.titleLarge?.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < data.length) {
                String period = data[index].year ?? '';

                return SideTitleWidget(
                  meta: meta,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 8.0 : 0.0,
                      right: index == data.length - 1 ? 8.0 : 0.0,
                    ),
                    child: Text(
                      period,
                      style: context.headlineSmall?.copyWith(
                          color: ColorConstants.tertiaryBlack, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  '${value.toInt()}',
                  style: context.headlineSmall?.copyWith(
                      color: ColorConstants.tertiaryBlack, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: _getMinY() - 2,
      maxY: _getMaxY() + 5,
      lineBarsData: [
        // Strategy line
        LineChartBarData(
          spots: _getStrategySpots(),
          isCurved: true,
          color: ColorConstants.primaryAppColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: ColorConstants.primaryAppColor,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
        // Benchmark line
        LineChartBarData(
          spots: _getBenchmarkSpots(),
          isCurved: true,
          color: Color(0xFFCAB2FF),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Color(0xFFCAB2FF),
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: ColorConstants.primaryAppColor,
                strokeWidth: 1,
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percentage, bar, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: ColorConstants.primaryAppColor,
                    strokeColor: ColorConstants.white,
                    strokeWidth: 2,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipBorder: BorderSide(color: Colors.grey.shade300),
          getTooltipColor: (LineBarSpot _) => ColorConstants.white,
          fitInsideHorizontally: true,
          tooltipMargin: 12,
          maxContentWidth: 180,
          showOnTopOfTheChartBoxArea: true,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            // Get the data index from the first touched spot
            int dataIndex = touchedSpots.first.x.toInt();
            if (dataIndex < 0 || dataIndex >= data.length) return [];

            // Get values from data to ensure correct Strategy/Benchmark values
            double strategyValue = data[dataIndex].strategy ?? 0;
            double benchmarkValue = data[dataIndex].benchmark ?? 0;

            // Always show Strategy first, then Benchmark
            List<LineTooltipItem> tooltipItems = [];

            // Add Strategy tooltip item
            tooltipItems.add(
              LineTooltipItem(
                '● ',
                toolTipStyle!.copyWith(color: ColorConstants.primaryAppColor),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(
                    text: product?.title ?? 'Strategy',
                    style: toolTipStyle!.copyWith(color: ColorConstants.black),
                  ),
                  TextSpan(
                    text: ' - ${strategyValue.toInt()}%',
                    style: toolTipStyle!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ],
              ),
            );

            // Add Benchmark tooltip item
            tooltipItems.add(
              LineTooltipItem(
                '● ',
                toolTipStyle!.copyWith(color: Color(0xFFCAB2FF)),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(
                    text: product?.benchmarkName ?? 'Benchmark',
                    style: toolTipStyle!.copyWith(color: ColorConstants.black),
                  ),
                  TextSpan(
                    text: ' - ${benchmarkValue.toInt()}%',
                    style: toolTipStyle!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ],
              ),
            );

            return tooltipItems;
          },
        ),
        getTouchLineStart: (_, __) => double.negativeInfinity,
        getTouchLineEnd: (_, __) => double.infinity,
      ),
    );
  }

  List<FlSpot> _getStrategySpots() {
    List<PMSLineChartModel> data = product!.strategyVsBenchmarkLine!;
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.strategy ?? 0);
    }).toList();
  }

  List<FlSpot> _getBenchmarkSpots() {
    List<PMSLineChartModel> data = product!.strategyVsBenchmarkLine!;
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.benchmark ?? 0);
    }).toList();
  }

  double _getMinY() {
    List<PMSLineChartModel> data = product!.strategyVsBenchmarkLine!;
    double minStrategy =
        data.map((e) => e.strategy ?? 0).reduce((a, b) => a < b ? a : b);
    double minBenchmark =
        data.map((e) => e.benchmark ?? 0).reduce((a, b) => a < b ? a : b);
    return [minStrategy, minBenchmark].reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY() {
    List<PMSLineChartModel> data = product!.strategyVsBenchmarkLine!;
    double maxStrategy =
        data.map((e) => e.strategy ?? 0).reduce((a, b) => a > b ? a : b);
    double maxBenchmark =
        data.map((e) => e.benchmark ?? 0).reduce((a, b) => a > b ? a : b);
    return [maxStrategy, maxBenchmark].reduce((a, b) => a > b ? a : b);
  }
}
