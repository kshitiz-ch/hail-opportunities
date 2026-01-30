import 'dart:math' as math;

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/select_switch_fund.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/switch_basket_bottom_bar.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_tracker_fund_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/scheme_card.dart';

@RoutePage()
class ClientTrackerSwitchScreen extends StatelessWidget {
  final Client client;
  final List<ClientTrackerFundModel> clientTrackerHoldings;

  const ClientTrackerSwitchScreen(
      {Key? key, required this.client, required this.clientTrackerHoldings})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Tap fund to be switched',
      ),
      body: GetBuilder<ClientTrackerSwitchController>(
        init: ClientTrackerSwitchController(client, clientTrackerHoldings),
        builder: (ClientTrackerSwitchController controller) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24)
                .copyWith(top: 20, bottom: 150),
            itemCount: controller.clientTrackerHoldings.length,
            separatorBuilder: (BuildContext context, int index) {
              // if (controller.switchBasket.containsKey(index + 1) ||
              //     controller.switchBasket.containsKey(index)) {
              //   return SizedBox(height: 30);
              // }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CommonUI.buildProfileDataSeperator(
                  color: ColorConstants.borderColor,
                ),
              );
            },
            itemBuilder: (BuildContext context, int index) {
              ClientTrackerFundModel clientTrackerFund =
                  controller.clientTrackerHoldings[index];

              // Check if widget should be disabled
              final folioOverview =
                  clientTrackerFund.schemeMetaModel?.folioOverview;
              final isDemat = folioOverview?.isDemat == true;
              final units = folioOverview?.units ?? 0.0;
              final lockedUnits = folioOverview?.lockedUnits ?? 0.0;
              final isUnitsLocked = units == lockedUnits && units > 0;
              final isDisabled = isDemat || isUnitsLocked;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    ignoring: isDisabled,
                    child: Opacity(
                      opacity: isDisabled ? 0.5 : 1.0,
                      child: InkWell(
                        splashColor: Colors.white,
                        onTap: () {
                          if (clientTrackerFund
                                  .schemeMetaModel?.folioOverview?.isDemat ==
                              true) {
                            return showToast(
                                text: 'Demat units switch not allowed');
                          }

                          if (clientTrackerFund.schemeMetaModel == null) {
                            return showToast(text: 'Fund details missing');
                          }

                          controller.updateSelectedTrackerFund(index);
                        },
                        child: SchemeCard(
                          clientTrackerFund: clientTrackerFund,
                          fromSwitchScreen: true,
                          isSelected:
                              controller.selectedTrackerFundIndex == index,
                        ),
                      ),
                    ),
                  ),
                  if (controller.selectedTrackerFundIndex == index)
                    SelectSwitchFund(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SwitchBasketBottomBar(),
    );
  }

  Widget _buildCard(BuildContext context,
      ClientTrackerFundModel clientTrackerFundModel, bool isSelected) {
    final returns = (clientTrackerFundModel.absoluteReturns ?? 0.0) * 100.0;
    String returnType = mfReturnTypeDescription(
        clientTrackerFundModel.schemeMetaModel?.returnType);
    String planType = fundPlanTypeDescription(
        clientTrackerFundModel.schemeMetaModel?.planType);
    String fundType =
        fundTypeDescription(clientTrackerFundModel.schemeMetaModel?.fundType);
    final subtitle =
        "${returnType.isNotEmpty ? '$returnType | ' : ''}${planType.isNotEmpty ? '$planType | ' : ''}$fundType";
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            border: Border.all(color: ColorConstants.secondarySeparatorColor),
            shape: BoxShape.circle,
          ),
          child: CommonUI.buildRoundedFullAMCLogo(
              radius: 18,
              amcName:
                  clientTrackerFundModel.schemeMetaModel?.displayName ?? ''),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CommonUI.buildColumnTextInfo(
              title: clientTrackerFundModel.schemeMetaModel?.displayName ?? '',
              subtitle: subtitle,
              titleMaxLength: 4,
              subtitleMaxLength: 2,
              titleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WealthyAmount.currencyFormat(
                clientTrackerFundModel.currentValue,
                2,
                showSuffix: true,
              ),
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  !returns.isNegative
                      ? AllImages().gainIcon
                      : AllImages().lossIcon,
                  height: 10,
                  width: 10,
                ),
                Text(
                  ' ${returns.toStringAsFixed(2)}%',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: !returns.isNegative
                                ? ColorConstants.greenAccentColor
                                : ColorConstants.errorColor,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                )
              ],
            )
          ],
        ),
        SizedBox(width: 12),
        Transform.rotate(
          angle: isSelected ? math.pi / 2 : 0,
          child: Image.asset(
            AllImages().trackerSwitchIcon,
            color: ColorConstants.primaryAppColor,
            height: 14,
            width: 14,
          ),
        ),
      ],
    );
  }
}
