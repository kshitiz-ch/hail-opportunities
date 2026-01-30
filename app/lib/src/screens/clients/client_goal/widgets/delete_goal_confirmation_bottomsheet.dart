import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DeleteGoalConfirmationBottomsheet extends StatelessWidget {
  final String title;
  final String name;
  final Function onConfirm;
  final bool showProgressIndicator;

  const DeleteGoalConfirmationBottomsheet({
    super.key,
    required this.title,
    required this.name,
    required this.onConfirm,
    required this.showProgressIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delete $title',
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                  fontSize: 18,
                ),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 42, bottom: 10),
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: 'Are you sure you want to delete ',
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
                  children: [
                    TextSpan(
                      text: '$name $title ?',
                      style: context.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: _buildCTA(context),
          )
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    final style = context.headlineMedium?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            margin: EdgeInsets.zero,
            height: 56,
            text: 'Cancel',
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
            bgColor: ColorConstants.secondaryButtonColor,
            textStyle: style?.copyWith(color: ColorConstants.primaryAppColor),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            progressIndicatorColor: ColorConstants.errorColor,
            showProgressIndicator: showProgressIndicator,
            margin: EdgeInsets.zero,
            height: 56,
            text: 'Delete',
            onPressed: () {
              onConfirm();
            },
            bgColor: ColorConstants.lightRedColor,
            textStyle: style?.copyWith(color: ColorConstants.errorColor),
          ),
        ),
      ],
    );
  }
}
