import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarkCustomBottomSheet extends StatelessWidget {
  const MarkCustomBottomSheet({Key? key, required this.onMarkCustom})
      : super(key: key);

  final Function() onMarkCustom;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      id: 'mark-custom',
      builder: (controller) {
        return Container(
          margin: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleAndCloseIcon(context),
              Padding(
                padding: EdgeInsets.only(top: 45, bottom: 20),
                child: Image.asset(
                  AllImages().markCustom,
                  width: 64,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'This is a wealthy controlled goal. In order to control this goal, please mark it as custom',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          fontSize: 12,
                          color: ColorConstants.tertiaryBlack,
                          height: 1.8),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 22),
                padding: EdgeInsets.symmetric(horizontal: 60)
                    .copyWith(top: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: hexToColor("#FFF8EA"),
                  border: Border.all(
                    color: ColorConstants.yellowAccentColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Once you mark this as custom,\nyou can\'t change it.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w500, height: 2),
                ),
              ),
              ActionButton(
                showProgressIndicator:
                    controller.markCustomResponse.state == NetworkState.loading,
                onPressed: () async {
                  await controller.markGoalAsCustom();

                  if (controller.markCustomResponse.state ==
                      NetworkState.error) {
                    return showToast(
                        text: controller.markCustomResponse.message);
                  }

                  if (controller.markCustomResponse.state ==
                      NetworkState.loaded) {
                    AutoRouter.of(context).popForced();
                    onMarkCustom();
                  }
                },
                margin: EdgeInsets.zero,
                text: 'Mark as Custom',
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleAndCloseIcon(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mark As Custom',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        CommonUI.bottomsheetCloseIcon(context)
      ],
    );
  }
}
