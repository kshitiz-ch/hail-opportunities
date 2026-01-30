import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailsUpdateSuccess extends StatelessWidget {
  final String? text;
  final Widget? childWidget;
  final String? copyLink;

  DetailsUpdateSuccess({this.text, this.childWidget, this.copyLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                AutoRouter.of(context).popForced();
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
            ),
            child: Image.asset(
              AllImages().successTickIcon,
              width: 90,
              height: 90,
            ),
          ),
          Text(
            text!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontSize: 20,
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (childWidget != null)
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: childWidget,
            ),
          if (copyLink.isNotNullOrEmpty)
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Row(
                children: [
                  // if (copyLink.isNotNullOrEmpty)
                  //   Expanded(
                  //     child: Padding(
                  //       padding: EdgeInsets.only(right: 12),
                  //       child: ActionButton(
                  //         text: 'Copy Link',
                  //         margin:
                  //             EdgeInsets.symmetric(vertical: 24).copyWith(top: 0),
                  //         bgColor: ColorConstants.lightBackgroundColor,
                  //         textStyle: Theme.of(context)
                  //             .primaryTextTheme
                  //             .labelLarge!
                  //             .copyWith(color: ColorConstants.primaryAppColor),
                  //         onPressed: () async {
                  //           await Clipboard.setData(
                  //             ClipboardData(text: copyLink),
                  //           );
                  //           showToast(context: context, text: 'Copied!');
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  Expanded(
                    child: ActionButton(
                      text: 'Copy Link',
                      margin:
                          EdgeInsets.symmetric(vertical: 24).copyWith(top: 0),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: copyLink ?? ''),
                        );
                        showToast(context: context, text: 'Copied!');
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
