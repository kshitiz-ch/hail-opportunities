import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InvestmentPieChart extends StatefulWidget {
  final double targetAmount;
  final int years;
  final double investedAmount;
  final double gainAmount;
  final double monthlyInvestment;
  final bool isInflationAdjusted;
  final CalculatorType calculatorType;

  InvestmentPieChart({
    Key? key,
    required this.targetAmount,
    required this.years,
    required this.investedAmount,
    required this.gainAmount,
    required this.monthlyInvestment,
    this.isInflationAdjusted = false,
    required this.calculatorType,
  }) : super(key: key);

  @override
  State<InvestmentPieChart> createState() => _InvestmentPieChartState();
}

class _InvestmentPieChartState extends State<InvestmentPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final chartRadius = 70.0;
  final investedColor = ColorConstants.primaryAppColor;
  final gainColor = Color(0xffCAB2FF);

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
    // Start animation immediately
    _animationController.forward();
  }

  @override
  void didUpdateWidget(InvestmentPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only restart animation if data actually changed
    if (oldWidget.investedAmount != widget.investedAmount ||
        oldWidget.gainAmount != widget.gainAmount ||
        oldWidget.targetAmount != widget.targetAmount) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.investedAmount + widget.gainAmount;
    final double investedPercentage =
        total > 0 ? (widget.investedAmount / total) * 100 : 0;
    final double gainPercentage =
        total > 0 ? (widget.gainAmount / total) * 100 : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text.rich(
          TextSpan(
            text: 'To reach a target of ',
            style: context.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.black,
            ),
            children: [
              TextSpan(
                text: WealthyAmount.currencyFormat(widget.targetAmount, 0),
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
              TextSpan(
                text: '\nin ${widget.years} years',
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.black,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        if (widget.calculatorType == CalculatorType.GoalPlanningSIPLumpsum) ...[
          const SizedBox(height: 8),
          Text(
            widget.isInflationAdjusted
                ? '(This projection is considering inflation)'
                : '(This projection does not consider inflation)',
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20),
        // Pie Chart with side legend
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    width: chartRadius * 2,
                    height: chartRadius * 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: chartRadius * 0.6,
                        startDegreeOffset: -90,
                        sections: _buildPieChartSections(
                          investedPercentage,
                          gainPercentage,
                        ),
                        borderData: FlBorderData(show: false),
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              // Legend on the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem(
                    context,
                    'Invested',
                    WealthyAmount.currencyFormat(widget.investedAmount, 0),
                    investedColor,
                    percentage: '(${investedPercentage.toStringAsFixed(2)}%)',
                  ),
                  const SizedBox(height: 24),
                  _buildLegendItem(
                    context,
                    'Gain',
                    WealthyAmount.currencyFormat(widget.gainAmount, 0),
                    gainColor,
                    percentage: '(${gainPercentage.toStringAsFixed(2)}%)',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // investment text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You need to invest ',
            style: context.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.black,
            ),
            children: [
              TextSpan(
                text: WealthyAmount.currencyFormat(widget.monthlyInvestment, 0),
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
              TextSpan(
                text:
                    widget.calculatorType == CalculatorType.GoalPlanningLumpsum
                        ? ' Onetime'
                        : ' Monthly',
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double investedPercentage,
    double gainPercentage,
  ) {
    // Animate the values progressively from 0 to their full amounts
    final animatedInvestedAmount = widget.investedAmount * _animation.value;
    final animatedGainAmount = widget.gainAmount * _animation.value;

    // Calculate remaining unfilled portion
    final totalAnimated = animatedInvestedAmount + animatedGainAmount;
    final totalActual = widget.investedAmount + widget.gainAmount;
    final remainingAmount =
        (totalActual - totalAnimated).clamp(0.0, double.infinity);

    List<PieChartSectionData> sections = [];

    // Always add invested section (use small value if animating from 0)
    sections.add(
      PieChartSectionData(
        color: investedColor,
        value: animatedInvestedAmount > 0.01 ? animatedInvestedAmount : 0.01,
        title: '',
        radius: chartRadius * 0.4,
        titleStyle: const TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    // Always add gain section (use small value if animating from 0)
    sections.add(
      PieChartSectionData(
        color: gainColor,
        value: animatedGainAmount > 0.01 ? animatedGainAmount : 0.01,
        title: '',
        radius: chartRadius * 0.4,
        titleStyle: const TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    // Add grey section for unfilled portion during animation
    if (remainingAmount > 0.1) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade200,
          value: remainingAmount,
          title: '',
          radius: chartRadius * 0.4,
          titleStyle: const TextStyle(
            fontSize: 0,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String value,
    Color color, {
    String? percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorConstants.black,
          ),
        ),
        if (percentage != null) ...[
          const SizedBox(height: 4),
          Text(
            percentage,
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.black,
            ),
          ),
        ],
      ],
    );
  }
}
