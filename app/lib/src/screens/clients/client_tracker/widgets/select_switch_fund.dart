import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/fund_search_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectSwitchFund extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Select fund to be switched',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        ),
        FundSearchSection(),
        GetBuilder<ClientTrackerSwitchController>(
          builder: (controller) {
            if (controller.fundListSwitchState == NetworkState.loading) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (controller.fundListSwitchState == NetworkState.error) {
              return SizedBox(
                height: 200,
                child: RetryWidget(
                  controller.fundListSwitchErrorMessage,
                  onPressed: () {
                    controller.getFundListForSwitch();
                  },
                ),
              );
            }

            if (controller.availableSwitchFunds.isNullOrEmpty) {
              return EmptyScreen(
                message: 'No funds found',
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RadioButtons(
                    items: List<int>.generate(
                      controller.availableSwitchFunds.length,
                      (index) => index,
                    ),
                    selectedValue: controller.selectedSwitchFundIndex,
                    spacing: 30,
                    itemBuilder: (context, value, index) {
                      final subtitle =
                          '${fundTypeDescription(controller.availableSwitchFunds[index].fundType)} ${controller.availableSwitchFunds[index].fundCategory != null ? "| ${controller.availableSwitchFunds[index].fundCategory}" : ""}';

                      return Container(
                        padding: const EdgeInsets.only(left: 15),
                        width: SizeConfig().screenWidth! - 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorConstants.white,
                                border: Border.all(
                                    color:
                                        ColorConstants.secondarySeparatorColor),
                                shape: BoxShape.circle,
                              ),
                              child: CommonUI.buildRoundedFullAMCLogo(
                                  radius: 18,
                                  amcName: controller
                                          .availableSwitchFunds[index]
                                          .displayName ??
                                      ''),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: CommonUI.buildColumnTextInfo(
                                  title: controller.availableSwitchFunds[index]
                                          .displayName ??
                                      '',
                                  titleMaxLength: 10,
                                  subtitle: subtitle,
                                  subtitleMaxLength: 2,
                                  gap: 8,
                                  titleStyle: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                  subtitleStyle: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.tertiaryGrey,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    direction: Axis.vertical,
                    onTap: (value) {
                      controller.updateSelectedSwitchFund(value);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
