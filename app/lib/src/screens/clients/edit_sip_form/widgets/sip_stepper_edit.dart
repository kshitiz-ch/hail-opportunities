import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/activate_step_up_sip.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipStepperEdit extends StatelessWidget {
  final controller = Get.find<ClientEditSipController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSipStepperHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CommonUI.buildProfileDataSeperator(
              width: double.infinity,
              color: ColorConstants.borderColor,
              height: 1,
            ),
          ),
          if (controller.updatedSipData.isStepUpSipEnabled)
            _buildUpdatedSipInfo(context),
        ],
      ),
    );
  }

  Widget _buildSipStepperHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Incrementally increase my SIP ',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
          ),
        ),
        _buildStepperCTA(context),
      ],
    );
  }

  Widget _buildStepperCTA(BuildContext context) {
    final sipAmount = controller.fundSelection == FundSelection.manual &&
            controller.isCustomFund
        ? controller.customFundAmount
        : controller.amount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClickableText(
          text:
              !controller.updatedSipData.isStepUpSipEnabled ? 'Enable' : 'Edit',
          fontWeight: FontWeight.w600,
          onClick: () {
            CommonUI.showBottomSheet(
              context,
              child: ActivateStepUpSip(
                onUpdateStepUpPeriod: (stepUpPeriod, stepUpPercentage) {
                  controller.updatedSipData.activateStepUpSip(
                    stepUpPeriod,
                    stepUpPercentage,
                  );
                  if (!controller.updatedSipData.isStepUpSipEnabled) {
                    controller.updatedSipData.updateIsStepUpSipEnabled(true);
                  }
                  controller.update();
                  AutoRouter.of(context).popForced();
                },
                selectedStepUpPeriod: controller.updatedSipData.stepUpPeriod,
                sipAmount: sipAmount,
                stepUpPercentage: controller.updatedSipData.stepUpPercentage,
                stepUpPercentageController:
                    controller.updatedSipData.stepUpPercentageController,
              ),
            );
          },
        ),
        if (controller.updatedSipData.isStepUpSipEnabled)
          ClickableText(
            padding: EdgeInsets.only(left: 20),
            text: 'Disable',
            fontWeight: FontWeight.w600,
            textColor: ColorConstants.redAccentColor,
            onClick: () {
              controller.updatedSipData.isStepUpSipEnabled = false;
              controller.update();
            },
          ),
      ],
    );
  }

  Widget _buildUpdatedSipInfo(BuildContext context) {
    final sipAmount = controller.fundSelection == FundSelection.manual &&
            controller.isCustomFund
        ? controller.customFundAmount
        : controller.amount;
    final style = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w400,
          color: Colors.black.withOpacity(0.8),
        );

    int noOfStepUpMonths =
        getStepUpMonths(controller.updatedSipData.formattedStepUpPeriod);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Your Current SIP of ',
            style: style,
            children: [
              TextSpan(
                text: WealthyAmount.currencyFormat(sipAmount, 0),
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' will increase every ',
                style: style,
              ),
              TextSpan(
                text: controller.updatedSipData.stepUpPeriod,
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' by ',
                style: style,
              ),
              TextSpan(
                text: '${controller.updatedSipData.stepUpPercentage}%',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Updated SIP from \n',
                  style: style,
                  children: [
                    TextSpan(
                      text: '${noOfStepUpMonths.toString()} Months',
                      style: style.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                getStepUpSipAmount(
                  incrementPercentage:
                      controller.updatedSipData.stepUpPercentage,
                  sipAmount: sipAmount.toInt(),
                ),
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
