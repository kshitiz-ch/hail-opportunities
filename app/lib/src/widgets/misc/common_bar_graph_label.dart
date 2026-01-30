import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';

final barLabelColorList = <Color>[
  Color(0xffA4D15E),
  Color(0xffBA73B4),
  Color(0xff244794),
  Color(0xffFFAD5B),
  Color(0xffbbaa5c),
  Color(0xffff7366),
  Color(0xff7B96F2),
  Color(0xffFBD68B),
  Color(0xff5BE3F3),
  Color(0xffFF92D1),
  Color(0xffDC8FE8),
];

class CommonBarGraphLabel extends StatelessWidget {
  final List<BarGraphLabel> barGraphLabels;
  late double totalValue;

  CommonBarGraphLabel({
    Key? key,
    required this.barGraphLabels,
  }) : super(key: key) {
    totalValue = barGraphLabels.fold(
      0,
      (previousValue, element) => previousValue + element.value,
    );
  }

  Color getColor(int index) {
    if (index >= barLabelColorList.length) {
      // default color
      return ColorConstants.secondaryGreenAccentColor;
    }
    return barLabelColorList[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLineGraph(context),
          _buildLabels(context),
        ],
      ),
    );
  }

  Widget _buildLineGraph(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 60;
    final lastNonZeroLabelIndex =
        barGraphLabels.lastIndexWhere((element) => element.value != 0);
    if (totalValue > 0) {
      return Container(
        margin: EdgeInsets.only(bottom: 30),
        width: screenWidth,
        height: 10,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            barGraphLabels.length,
            (index) => _buildRectBar(
              screenWidth,
              isFirstRectBar: index == 0,
              isLastRectBar: index == lastNonZeroLabelIndex,
              valuePercentage: barGraphLabels[index].percentage,
              color: getColor(index),
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildLabels(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.tertiaryBlack,
            );
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      childAspectRatio: 3.6,
      mainAxisSpacing: 24,
      crossAxisSpacing: 10,
      children: List<Widget>.generate(
        barGraphLabels.length,
        (index) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: getColor(index),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      barGraphLabels[index].labelText,
                      style: textStyle,
                      maxLines: 2,
                    ),
                  ),
                ),
                Text(
                  '${barGraphLabels[index].percentage.toStringAsFixed(1)}%',
                  style: textStyle?.copyWith(
                    color: getColor(index),
                  ),
                )
              ],
            ),
            Text(
              WealthyAmount.currencyFormat(barGraphLabels[index].value, 1),
              style: textStyle?.copyWith(
                color: ColorConstants.black,
                fontSize: 16,
              ),
            )
          ],
        ),
      ).toList(),
    );
  }

  Widget _buildRectBar(double screenWidth,
      {bool isFirstRectBar = false,
      bool isLastRectBar = false,
      required Color color,
      double valuePercentage = 0}) {
    return Container(
      width: (screenWidth * valuePercentage) / 100,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirstRectBar ? 5 : 0),
          bottomLeft: Radius.circular(isFirstRectBar ? 5 : 0),
          topRight: Radius.circular(isLastRectBar ? 5 : 0),
          bottomRight: Radius.circular(isLastRectBar ? 5 : 0),
        ),
      ),
    );
  }
}

class BarGraphLabel {
  final String labelText;
  final double percentage;
  final double value;

  BarGraphLabel({
    required this.labelText,
    required this.percentage,
    required this.value,
  });
}
