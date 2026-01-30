import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GoalStatusSwitch extends StatelessWidget {
  const GoalStatusSwitch({
    Key? key,
    required this.isActive,
    required this.onChanged,
    required this.orderType,
  }) : super(key: key);

  final bool isActive;
  final String orderType;
  final Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ColorConstants.borderColor.withOpacity(0.2),
          ),
          child: Row(
            children: [
              InkWell(
                child: Icon(
                  !isActive ? Icons.pause : Icons.play_arrow,
                  size: 20,
                  color: !isActive
                      ? ColorConstants.yellowAccentColor
                      : ColorConstants.greenAccentColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '$orderType ${isActive ? 'Active' : 'Paused'}',
                style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 25,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: CupertinoSwitch(
                        trackColor:
                            ColorConstants.primaryAppColor.withOpacity(0.2),
                        value: isActive,
                        activeColor: ColorConstants.primaryAppColor,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: !isActive
                      ? '$orderType is Paused, Switch to '
                      : '$orderType is Active, Switch to ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                          ),
                ),
                TextSpan(
                  text: !isActive ? 'Activate ' : 'Pause ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w400,
                          ),
                ),
                // TextSpan(
                //   text: 'now',
                //   style:
                //       Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                //             color: ColorConstants.tertiaryBlack,
                //             fontWeight: FontWeight.w400,
                //           ),
                // ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
