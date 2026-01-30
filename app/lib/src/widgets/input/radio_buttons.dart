import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:flutter/material.dart';

class RadioButtons extends StatelessWidget {
  final Function(dynamic)? onTap;
  final List<dynamic>? items;
  final Widget Function(BuildContext, dynamic, int index)? itemBuilder;
  final dynamic selectedValue;
  final Axis direction;
  final TextStyle? textStyle;

  // Vertical Spacing
  final double spacing;

  // Horizontal Spacing between buttons, only for Axis.horizontal
  final double runSpacing;

  final CrossAxisAlignment? crossAxisAlignment;

  RadioButtons({
    Key? key,
    this.onTap,
    this.items,
    this.textStyle,
    this.itemBuilder,
    this.selectedValue,
    this.spacing = 40,
    this.runSpacing = 20,
    this.crossAxisAlignment,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  late List<Widget> radioButtonItems;

  @override
  Widget build(BuildContext context) {
    radioButtonItems = items!.mapIndexed<Widget>((value, int index) {
      if (itemBuilder != null) {
        Widget radioTextWidget = itemBuilder!(context, value, index);

        return _buildRadioButtonTile(
          context,
          value,
          radioTextWidget: radioTextWidget,
        );
      } else {
        return _buildRadioButtonTile(context, value);
      }
    }).toList();

    return Wrap(
      direction: direction,
      runSpacing: runSpacing,
      spacing: spacing,
      children: radioButtonItems,
    );
  }

  Widget _buildRadioButtonTile(BuildContext context, dynamic value,
      {Widget? radioTextWidget}) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: ColorConstants.lightGrey,
      ),
      child: InkWell(
        onTap: () {
          onTap!(value);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: Radio(
                activeColor: ColorConstants.primaryAppColor,
                value: value,
                groupValue: selectedValue,
                onChanged: (dynamic value) {
                  onTap!(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: radioTextWidget != null
                  ? radioTextWidget
                  : Text(
                      value.toString(),
                      style: textStyle ??
                          Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                height: 18 / 12,
                                color: ColorConstants.black,
                              ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
