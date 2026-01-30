import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/advisor/models/product_revenue_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

final donutChartColorList = <Color>[
  Color(0xff7B96F2),
  Color(0xffFBD68B),
  Color(0xff5BE3F3),
  Color(0xffFF92D1),
  Color(0xffDC8FE8),
];

Color getColor(int index) {
  if (index >= donutChartColorList.length) {
    // default color
    return ColorConstants.secondaryGreenAccentColor;
  }
  return donutChartColorList[index];
}

class DonutChart extends StatefulWidget {
  final double radius;
  final List<ProductRevenueModel> productWiseRevenue;

  const DonutChart(
      {Key? key, required this.productWiseRevenue, required this.radius})
      : super(key: key);

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  /// Builds a semi-circular donut chart displaying product-wise revenue distribution
  ///
  /// The chart displays data in the top half (180 degrees) with:
  /// - Color-coded sections for each product
  /// - A transparent bottom half to create the semi-circle effect
  /// - Dynamic thickness based on the provided radius
  /// - Center space to create the donut hole effect
  @override
  Widget build(BuildContext context) {
    // Calculate total percentage to determine the dummy section size
    // This total is used to create an equal-sized transparent section
    // ensuring the visible sections occupy exactly 180 degrees (half circle)
    double totalPercentage = widget.productWiseRevenue
        .fold(0, (sum, item) => sum + (item.percentage ?? 0));

    // If no data is available, set a default value to prevent division by zero
    // This handles edge cases gracefully without crashing
    if (totalPercentage == 0) totalPercentage = 1;

    // Calculate the donut chart dimensions
    // Thickness is 35% of radius for a balanced appearance
    // Center radius is 65% to create appropriate donut hole size
    final double thickness = widget.radius * 0.35;
    final double centerRadius = widget.radius * 0.65;

    return ClipRect(
      // Clip to hide the bottom half of the circle
      child: SizedBox(
        height: widget.radius, // Half height to show only top semicircle
        width: widget.radius * 2, // Full width for complete semicircle
        child: OverflowBox(
          // OverflowBox allows the full circle to be drawn while only showing the top half
          maxHeight: widget.radius * 2,
          minHeight: widget.radius * 2,
          maxWidth: widget.radius * 2,
          minWidth: widget.radius * 2,
          alignment: Alignment.topCenter, // Align to show top half
          child: PieChart(
            PieChartData(
              startDegreeOffset:
                  180, // Start from left side (180°) to draw semicircle upward
              centerSpaceRadius: centerRadius, // Creates the donut hole
              sectionsSpace:
                  0, // No gaps between sections for seamless appearance
              sections: [
                // Map each product revenue to a colored chart section
                ...widget.productWiseRevenue.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return PieChartSectionData(
                    color: getColor(index), // Assign color based on index
                    value: data.percentage ??
                        0, // Percentage determines section size
                    title: '', // No inline titles - labels shown separately
                    radius: thickness,
                    showTitle: false,
                  );
                }).toList(),
                // Add transparent dummy section equal to total percentage
                // This completes the circle and pushes visible data to the top half
                PieChartSectionData(
                  color: Colors.transparent,
                  value: totalPercentage,
                  title: '',
                  radius: thickness,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DonutChartLabel extends StatefulWidget {
  final bool fromHomeScreen;
  final List<ProductRevenueModel> productWiseRevenue;
  final bool isMoreProducts;

  const DonutChartLabel({
    Key? key,
    required this.productWiseRevenue,
    this.fromHomeScreen = false,
  })  : isMoreProducts = productWiseRevenue.length > 5,
        super(key: key);

  @override
  State<DonutChartLabel> createState() => _DonutChartLabelState();
}

class _DonutChartLabelState extends State<DonutChartLabel> {
  bool isOtherLabelVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildLabels(
          data: widget.productWiseRevenue.sublist(
            0,
            (widget.isMoreProducts ? 4 : widget.productWiseRevenue.length),
          ),
        ),
        ..._buildOtherLabels(context),
      ],
    );
  }

  List<Widget> _buildLabels(
      {required List<ProductRevenueModel> data, Color? color}) {
    return List<Widget>.generate(
      (data.length / 2).ceil(),
      (rowIndex) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: List.generate(
            2,
            (colIndex) {
              final index = rowIndex * 2 + colIndex;
              return (index >= data.length)
                  ? SizedBox()
                  : Expanded(
                      child: _buildLabel(
                        data[index],
                        context,
                        color ?? getColor(index),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    ProductRevenueModel data,
    BuildContext context,
    Color color,
  ) {
    String title =
        getInvestmentProductTitle(data.productType?.toLowerCase() ?? '');
    if (title.isNullOrEmpty) {
      title = data.productType.toCapitalized();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.fromHomeScreen
                  ? Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(color: color),
                    )
                  : Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    title,
                    style: widget.fromHomeScreen
                        ? Theme.of(context)
                            .primaryTextTheme
                            .bodySmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            )
                        : Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall
                            ?.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                ),
              ),
              Text(
                data.percentage != null
                    ? '${data.percentage!.toStringAsFixed(2)}%'
                    : 'NA',
                style: widget.fromHomeScreen
                    ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          color: color,
                        )
                    : Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
              )
            ],
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              WealthyAmount.currencyFormat(data.revenue, 2),
              style: widget.fromHomeScreen
                  ? Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 14)
                  : Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildOtherLabels(BuildContext context) {
    List<Widget> labels = [];
    if (widget.isMoreProducts) {
      labels.add(
        CommonUI.buildProfileDataSeperator(
          height: 1,
          width: double.infinity,
          color: ColorConstants.borderColor,
        ),
      );
      labels.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: InkWell(
            onTap: () {
              setState(() {
                isOtherLabelVisible = !isOtherLabelVisible;
              });
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${widget.productWiseRevenue.length - 4} Others ',
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.primaryAppColor,
                            ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryAppColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOtherLabelVisible
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ColorConstants.primaryAppColor,
                      size: 12,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
      if (isOtherLabelVisible) {
        labels.addAll(
          _buildLabels(
            data: widget.productWiseRevenue.sublist(4),
            color: ColorConstants.greenAccentColor,
          ),
        );
      }
    }
    return labels;
  }
}
