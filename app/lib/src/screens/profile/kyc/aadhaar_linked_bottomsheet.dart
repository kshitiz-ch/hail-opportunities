import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

Future<bool?> aadharLinkedBottomsheet(BuildContext context,
    {void Function({bool? isUserAadharLinked})? onActionClick}) async {
  return showModalBottomSheet<bool>(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.white,
    barrierColor: Colors.black.withOpacity(0.8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext context) =>
        _buildBottomSheet(context, onActionClick: onActionClick),
  );
}

Widget _buildBottomSheet(BuildContext context,
    {Function({bool? isUserAadharLinked})? onActionClick}) {
  return Container(
    margin: EdgeInsets.all(30).copyWith(top: 50),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        _buildActions(context, onActionClick: onActionClick),
      ],
    ),
  );
}

Widget _buildHeader(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Transform.scale(
        scale: getScaleValue(context: context, customScaleValue: 1.4),
        child: Image.asset(
          AllImages().aadharPhoneLink,
          width: 130,
          height: 67,
        ),
      ),
      Transform.scale(
        scale: getScaleValue(context: context, customScaleValue: 1.2),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 24),
          child: Text(
            'Is your phone number \nlinked to your Aadhaar?',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.black,
                  height: 24 / 14,
                ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildActions(BuildContext context,
    {Function({bool? isUserAadharLinked})? onActionClick}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            responsiveButtonMaxWidthRatio: 0.4,
            text: 'No',
            onPressed: () {
              onActionClick!(isUserAadharLinked: false);
            },
            bgColor: ColorConstants.secondaryAppColor,
            borderRadius: 51,
            margin: EdgeInsets.zero,
            textStyle:
                Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.primaryAppColor,
                      fontSize: 16,
                    ),
          ),
          SizedBox(
            width: 12,
          ),
          ActionButton(
            responsiveButtonMaxWidthRatio: 0.4,
            text: 'Yes',
            onPressed: () {
              onActionClick!(isUserAadharLinked: true);
            },
            borderRadius: 51,
            margin: EdgeInsets.zero,
            textStyle:
                Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.white,
                      fontSize: 16,
                    ),
          ),
        ],
      ),
      Center(
        child: ClickableText(
          fontWeight: FontWeight.w700,
          text: "i don't know".toTitleCase(),
          padding: EdgeInsets.only(top: 24),
          fontSize: 16,
          onClick: () {
            onActionClick!(isUserAadharLinked: false);
          },
        ),
      )
    ],
  );
}
