import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditAllocationCard extends StatelessWidget {
  final int goalIndex;

  EditAllocationCard({Key? key, required this.goalIndex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      id: goalIndex,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorConstants.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSchemeDetail(context, controller),
              _buildInvestmentOverview(context, controller),
              _buildAllocationInput(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchemeDetail(BuildContext context, GoalController controller) {
    final goalScheme = controller.editedGoalSchemes[goalIndex];
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: CommonUI.buildRoundedFullAMCLogo(
            radius: 20,
            amcName: goalScheme.schemeData?.displayName,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goalScheme.schemeData?.displayName ?? '',
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '${fundTypeDescription(goalScheme.schemeData?.fundType)} ${goalScheme.schemeData?.category != null ? "| ${goalScheme.schemeData?.category}" : ""}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontSize: 12.0,
                      ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 25,
          child: FittedBox(
            child: CupertinoSwitch(
              trackColor: ColorConstants.greenAccentColor.withOpacity(0.2),
              value: !(goalScheme.isDeprecated ?? false),
              activeColor: ColorConstants.greenAccentColor,
              onChanged: (isDeprecated) async {
                controller.updateGoalAllocationData(
                  goalIndex: goalIndex,
                  isDeprecated: !isDeprecated,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentOverview(
      BuildContext context, GoalController controller) {
    final goalScheme = controller.editedGoalSchemes[goalIndex];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          CommonClientUI.columnInfoText(
            context,
            title: 'Invested',
            subtitle: WealthyAmount.currencyFormat(
                goalScheme.currentInvestedValue, 1),
          ),
          CommonClientUI.columnInfoText(
            context,
            title: 'Current Value',
            subtitle: WealthyAmount.currencyFormat(goalScheme.currentValue, 1),
          ),
          if (goalScheme.isDeprecated ?? false)
            Expanded(
              child: Text(
                'Deprecated',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.errorColor),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    AllImages().verifiedIcon,
                    width: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Active',
                    style: Theme.of(context).primaryTextTheme.headlineSmall!,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildAllocationInput(
      BuildContext context, GoalController controller) {
    final goalScheme = controller.editedGoalSchemes[goalIndex];

    Widget _buildTextField(BuildContext context) {
      final isDeprecated = (goalScheme.isDeprecated == true);
      final textStyle =
          Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: isDeprecated
                    ? ColorConstants.tertiaryBlack
                    : ColorConstants.black,
                fontWeight: FontWeight.w600,
                height: 18 / 16,
              );

      final width = 60.0;
      final inputBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorConstants.primaryAppColor,
        ),
        borderRadius: BorderRadius.circular(4),
      );

      return SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              enabled: !isDeprecated,
              initialValue:
                  (isDeprecated ? 0 : (goalScheme.idealWeight ?? 0)).toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: textStyle,
              inputFormatters: [
                NoLeadingSpaceFormatter(),
                LengthLimitingTextInputFormatter(3),
                NoLeadingZeroFormatter()
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: isDeprecated
                    ? ColorConstants.white
                    : ColorConstants.primaryAppv3Color,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                focusedBorder: inputBorder,
                border: inputBorder,
                enabledBorder: inputBorder,
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ColorConstants.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                errorStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: ColorConstants.errorTextColor,
                        ),
                constraints: BoxConstraints(maxHeight: 35, minHeight: 35),
              ),
              onChanged: (value) {
                controller.updateGoalAllocationData(
                  goalIndex: goalIndex,
                  percentage:
                      value.isNullOrEmpty ? 0 : WealthyCast.toInt(value),
                );
              },
              validator: (value) {
                return null;
              },
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Percentage',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        ),
        Spacer(),
        _buildTextField(context),
        Text(
          ' %',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        )
      ],
    );
  }
}
