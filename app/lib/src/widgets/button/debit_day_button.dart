import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:flutter/material.dart';

class DayButton extends StatelessWidget {
  // Feilds
  final int day;
  final bool isSelected;
  final VoidCallback? onPressed;

  // Constructor
  const DayButton({
    Key? key,
    required this.day,
    this.isSelected = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = 50;
    final double buttonHeight = 30;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(vertical: isSelected ? 0 : 3),
      height: isSelected ? buttonHeight + 6 : buttonHeight,
      width: isSelected ? buttonWidth + 6 : buttonWidth,
      child: ElevatedButton(
        child: Text(
          getOrdinalNumber(day),
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                height: 1.4,
                color: isSelected
                    ? ColorConstants.black
                    : ColorConstants.secondaryLightGrey,
                fontSize: 14.0,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isSelected ? ColorConstants.white : ColorConstants.secondaryWhite,
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          elevation: MaterialStateProperty.all(isSelected ? 10 : 0),
          shadowColor:
              MaterialStateProperty.all(Color.fromRGBO(66, 50, 178, 0.23)),
          side: isSelected
              ? MaterialStateProperty.all(BorderSide(
                  width: 1,
                  color: ColorConstants.primaryAppColor,
                ))
              : null,
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
