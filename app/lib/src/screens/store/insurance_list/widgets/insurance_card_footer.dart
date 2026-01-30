import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

class InsuranceCardFooter extends StatelessWidget {
  final String? title;
  final TextStyle? style;
  final double? imageRadius;
  final double overlapWidth;
  final String? productVariant;

  const InsuranceCardFooter({
    Key? key,
    this.title,
    this.style,
    this.imageRadius,
    this.overlapWidth = 9,
    this.productVariant,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final imageList =
        insuranceSectionData[productVariant]!['product_logos'] as List;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            // height: 36,
            child: OverflowView.flexible(
              spacing: -overlapWidth,
              children: <Widget>[]..addAll(
                  imageList.map<Widget>(
                    (imagePath) => ClipRRect(
                      child: Image.asset(
                        imagePath,
                        width: 22,
                        height: 22,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              builder: (_, remaining) => SizedBox(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 12),
          child: Text(
            title!,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right,
          color: ColorConstants.primaryAppColor,
        )
      ],
    );
  }
}
