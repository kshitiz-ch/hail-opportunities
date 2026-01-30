import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PerformanceChart extends StatelessWidget {
  final controller = Get.find<WealthcaseController>();

  PerformanceChart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wealthcase = controller.selectedWealthcase;
    if (wealthcase == null) {
      return const Center(child: Text('No data available'));
    }

    final selectedPeriod = wealthcase.selectedPeriod.toLowerCase();
    final chartData = wealthcase.chartData[selectedPeriod];

    if (chartData == null || chartData.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    final basketName = 'This Basket';

    // Use selected benchmark from controller, fallback to first available benchmark
    String primaryBenchmarkName = 'Benchmark';
    if (controller.selectedBenchmark != null) {
      primaryBenchmarkName = controller.selectedBenchmark!.name ?? 'Benchmark';
    } else {
      final benchmarkNames =
          chartData.keys.where((key) => key != basketName).toList();
      primaryBenchmarkName =
          benchmarkNames.isNotEmpty ? benchmarkNames.first : 'Benchmark';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                color: const Color(0xFF4ECDC4), // Teal color
                label: basketName,
              ),
              // Show benchmark legend only if comparison is enabled
              if (controller.showBenchmarkComparison)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _buildLegendItem(
                    color: Colors.black,
                    label: primaryBenchmarkName,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 220,
            child: LineChart(
              _buildLineChartData(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(BuildContext context) {
    final wealthcase = controller.selectedWealthcase;
    if (wealthcase == null) return LineChartData();

    final selectedPeriod = wealthcase.selectedPeriod.toLowerCase();
    final chartData = wealthcase.chartData[selectedPeriod];

    if (chartData == null || chartData.isEmpty) return LineChartData();

    final basketName = wealthcase.name ?? 'This Basket';
    final basketData = chartData[basketName] ?? [];

    // Use selected benchmark from controller, fallback to first available benchmark
    String primaryBenchmarkName =
        controller.selectedBenchmark?.name ?? 'Benchmark';

    // Only get benchmark data if comparison is enabled
    List<WealthcaseChartDataModel> benchmarkData = [];
    if (controller.showBenchmarkComparison) {
      if (controller.selectedBenchmark != null) {
        final selectedBenchmarkName = controller.selectedBenchmark!.name;
        benchmarkData = chartData[selectedBenchmarkName] ?? [];
      } else {
        final benchmarkNames =
            chartData.keys.where((key) => key != basketName).toList();
        if (benchmarkNames.isNotEmpty) {
          benchmarkData = chartData[benchmarkNames.first] ?? [];
        }
      }
    }

    // Convert to FlSpot lists using normalised values
    final basketSpots = _convertChartDataToFlSpots(basketData);
    final benchmarkSpots = controller.showBenchmarkComparison
        ? _convertChartDataToFlSpots(benchmarkData)
        : <FlSpot>[];

    // Find min and max values for Y-axis using normalised values
    List<double> allValues = [
      ...basketData
          .map((d) => d.normalisedValue)
          .where((v) => v != null)
          .cast<double>(),
    ];

    // Only include benchmark values if comparison is enabled
    if (controller.showBenchmarkComparison) {
      allValues.addAll(benchmarkData
          .map((d) => d.normalisedValue)
          .where((v) => v != null)
          .cast<double>());
    }

    if (allValues.isEmpty) return LineChartData();

    // Calculate Y-axis bounds with proper padding to prevent overlap with chart points
    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    // Add 10% padding to both top and bottom to prevent overlap between
    // plotted points and Y-axis labels (e.g., preventing max value 253 from
    // overlapping with the 256 Y-axis label)
    final padding = range * 0.1;
    final minY = minValue - padding;
    final maxY = maxValue + padding;

    return LineChartData(
      lineTouchData: _buildLineTouchData(
        basketData,
        benchmarkData,
        basketName,
        primaryBenchmarkName,
        context,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        // horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomTitleInterval(basketData),
            getTitlesWidget: (value, meta) {
              return _getBottomTitleWidget(
                  value, meta, basketData, selectedPeriod.toLowerCase());
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: false,
            minIncluded: false,
            // interval: (maxY - minY) / 4,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (basketSpots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        // Basket line
        if (basketSpots.isNotEmpty)
          LineChartBarData(
            spots: basketSpots,
            isCurved: true,
            color: const Color(0xFF4ECDC4),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Benchmark line - only show if comparison is enabled
        if (controller.showBenchmarkComparison && benchmarkSpots.isNotEmpty)
          LineChartBarData(
            spots: benchmarkSpots,
            isCurved: true,
            color: Colors.black,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
      ],
    );
  }

  LineTouchData _buildLineTouchData(
    List<WealthcaseChartDataModel> basketData,
    List<WealthcaseChartDataModel> benchmarkData,
    String basketName,
    String primaryBenchmarkName,
    BuildContext context,
  ) {
    return LineTouchData(
      enabled: true,
      touchSpotThreshold: 10, // Reduced touch sensitivity
      getTouchLineStart: (_, __) => double.negativeInfinity,
      getTouchLineEnd: (_, __) => double.infinity,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((index) {
          Color indicatorColor = barData.color ?? Colors.grey;
          return TouchedSpotIndicatorData(
            FlLine(
              color: indicatorColor,
              strokeWidth: 1, // Thin line
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percentage, bar, index) {
                return FlDotCirclePainter(
                  radius: 3, // Small radius
                  color: indicatorColor,
                  strokeColor: indicatorColor,
                );
              },
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (LineBarSpot _) => ColorConstants.primaryAppv3Color,
        fitInsideHorizontally: true,
        tooltipMargin: 4, // Reduced margin
        tooltipPadding: const EdgeInsets.all(6), // Reduced padding
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final spotIndex = barSpot.x.toInt();

            if (barSpot.barIndex == 0) {
              // Basket line (first line)
              if (spotIndex >= 0 && spotIndex < basketData.length) {
                final dataPoint = basketData[spotIndex];
                final closeValue = dataPoint.closeValue;
                if (closeValue != null) {
                  return LineTooltipItem(
                    '${basketName}\n₹${closeValue.toStringAsFixed(2)}',
                    context.titleLarge
                            ?.copyWith(color: const Color(0xFF4ECDC4)) ??
                        TextStyle(),
                  );
                }
              }
            } else if (barSpot.barIndex == 1 &&
                controller.showBenchmarkComparison) {
              // Benchmark line (second line)
              if (spotIndex >= 0 && spotIndex < benchmarkData.length) {
                final dataPoint = benchmarkData[spotIndex];
                final closeValue = dataPoint.closeValue;
                if (closeValue != null) {
                  return LineTooltipItem(
                    '${primaryBenchmarkName}\n₹${closeValue.toStringAsFixed(2)}',
                    context.titleLarge?.copyWith(color: Colors.black) ??
                        TextStyle(),
                  );
                }
              }
            }

            return null;
          }).toList();
        },
      ),
    );
  }

  double _getBottomTitleInterval(List<WealthcaseChartDataModel> data) {
    final dataLength = data.length;
    final wealthcase = controller.selectedWealthcase;
    if (wealthcase == null) return 1;

    final selectedPeriod = wealthcase.selectedPeriod;
    if (selectedPeriod == '1M') {
      // Show 4 titles for 1M
      return dataLength > 4 ? (dataLength - 1) / 3 : 1;
    } else {
      // Show 6 titles for others
      return dataLength > 6 ? (dataLength - 1) / 5 : 1;
    }
  }

  List<FlSpot> _convertChartDataToFlSpots(List<WealthcaseChartDataModel> data) {
    return data
        .asMap()
        .entries
        .where((entry) => entry.value.normalisedValue != null)
        .map((entry) =>
            FlSpot(entry.key.toDouble(), entry.value.normalisedValue!))
        .toList();
  }

  Widget _getBottomTitleWidget(double value, TitleMeta meta,
      List<WealthcaseChartDataModel> data, String selectedPeriod) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );

    final index = value.toInt();
    if (index >= 0 && index < data.length) {
      final chartDataPoint = data[index];
      if (chartDataPoint.date != null) {
        final displayText =
            _formatDateForDisplay(chartDataPoint.date!, selectedPeriod);
        return SideTitleWidget(
          meta: meta,
          child: Text(displayText, style: style),
        );
      }
    }

    return const SizedBox.shrink();
  }

  String _formatDateForDisplay(DateTime date, String selectedPeriod) {
    try {
      if (selectedPeriod == '1m' || selectedPeriod == '6m') {
        // For 1M period, show day and month (e.g., "25 Aug")
        final formatter = DateFormat('d MMM');
        return formatter.format(date);
      } else {
        // For periods > 1M, show month and year (e.g., "Aug 25")
        final formatter = DateFormat('MMM yy');
        return formatter.format(date);
      }
    } catch (e) {
      // Fallback if formatting fails
      return DateFormat('MMM yy').format(date);
    }
  }
}
