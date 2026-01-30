import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class QuickNavButton extends StatelessWidget {
  // Fields
  final String text;
  final VoidCallback? onPressed;
  final String icon;
  final bool showNewBadge;

  // Constructor
  const QuickNavButton(this.text,
      {Key? key, this.onPressed, required this.icon, this.showNewBadge = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          if (showNewBadge)
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  padding: EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 8,
                  ),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorConstants.secondaryAppColor),
                  child: Center(
                    child: Image.asset(
                      icon,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 3,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ColorConstants.lightOrangeColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'New',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(fontSize: 8),
                    ),
                  ),
                )
              ],
            )
          else
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 8,
              ),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorConstants.secondaryAppColor),
              child: Center(
                child: Image.asset(
                  icon,
                ),
              ),
            ),
          SizedBox(height: 6),
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.titleLarge,
          )
        ],
      ),
    );
    // return TextButton(
    //   child: Padding(
    //     padding: EdgeInsets.only(right: 4),
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         if (icon != null)
    //           Padding(
    //             padding: const EdgeInsets.only(right: 6.0),
    //             child: Image.asset(
    //               icon!,
    //               width: 20,
    //               height: 20,
    //             ),
    //           ),
    //         Text(
    //           text,
    //           style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
    //                 fontSize: 12.0,
    //                 color: ColorConstants.tertiaryBlack,
    //               ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   style: ButtonStyle(
    //     padding: MaterialStateProperty.all<EdgeInsets>(
    //       EdgeInsets.symmetric(
    //         horizontal: 6.0,
    //         vertical: 12.0,
    //       ),
    //     ),
    //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //       RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(12.0),
    //         side: BorderSide(
    //           color: ColorConstants.borderColor,
    //           width: 0.5,
    //         ),
    //       ),
    //     ),
    //   ),
    //   onPressed: onPressed,
    // );
  }
}
