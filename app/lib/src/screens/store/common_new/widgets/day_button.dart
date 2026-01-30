import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class DayButton extends StatelessWidget {
  const DayButton({
    Key? key,
    required this.day,
    this.selected = false,
    this.onTap,
    required this.isDisabled,
  }) : super(key: key);
  final int day;
  final bool selected;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isDisabled
              ? ColorConstants.secondaryWhite.withOpacity(0.3)
              : selected
                  ? ColorConstants.secondaryAppColor
                  : ColorConstants.secondaryWhite,
        ),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        foregroundColor: MaterialStateProperty.all(
          selected ? ColorConstants.primaryAppColor : Colors.transparent,
        ),
        side: MaterialStateProperty.all(
          BorderSide(
            color:
                selected ? ColorConstants.primaryAppColor : Colors.transparent,
            width: .5,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      onPressed: isDisabled ? null : onTap,
      child: Text(
        day.toString(),
        style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? ColorConstants.tertiaryBlack
                  : selected
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
            ),
      ),
    );
  }
}
