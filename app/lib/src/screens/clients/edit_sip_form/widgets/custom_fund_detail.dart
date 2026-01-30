import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/custom_fund_addition.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/edit_custom_fund.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFundDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: GetBuilder<ClientEditSipController>(
        builder: (ClientEditSipController controller) {
          if (controller.customFundsResponse.state == NetworkState.loading) {
            return SkeltonLoaderCard(height: 100);
          }
          if (controller.customFundsResponse.state == NetworkState.error) {
            return SizedBox(
              height: 100,
              child: Center(
                child: RetryWidget(
                  genericErrorMessage,
                  onPressed: () {
                    controller.getCustomFundsData();
                  },
                ),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.addedCustomFunds.isNullOrEmpty
                        ? 'No Funds Added'
                        : 'Funds Added',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(color: ColorConstants.black),
                  ),
                  ClickableText(
                    text: (controller.addedCustomFunds.length !=
                            controller.selectedSip.sipMetaFunds!.length)
                        ? 'Add Fund'
                        : controller.customFundsData?.schemeMetas?.length ==
                                controller.selectedSip.sipMetaFunds!.length
                            ? ''
                            : controller.addedCustomFunds.isNullOrEmpty
                                ? 'Add Fund'
                                : 'Add more + ',
                    fontSize: 14,
                    onClick: () {
                      controller.customFundAmountController =
                          TextEditingController();
                      CommonUI.showBottomSheet(
                        context,
                        child: CustomFundAddition(),
                      );
                    },
                  )
                ],
              ),
              SizedBox(height: 20),
            ]..addAll(
                List<Widget>.generate(
                  controller.addedCustomFunds.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CommonUI.buildRoundedFullAMCLogo(
                                radius: 20,
                                amcName: controller
                                    .addedCustomFunds[index].displayName,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.addedCustomFunds[index]
                                          .displayName ??
                                      '',
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: ColorConstants.tertiaryBlack,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  WealthyAmount.currencyFormat(
                                      controller.addedCustomFunds[index]
                                              .amountEntered ??
                                          0,
                                      0),
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: ColorConstants.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          _buildEditDeleteAction(controller, index, context),
                        ],
                      ),
                    );
                  },
                ),
              ),
          );
        },
      ),
    );
  }

  Widget _buildEditDeleteAction(
    ClientEditSipController controller,
    int addedFundIndex,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Delete button
        InkWell(
          onTap: () {
            controller.deleteCustomFunds(
              controller.addedCustomFunds[addedFundIndex],
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 119, 119, 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(
                  AllImages().deleteIcon,
                  height: 12,
                  width: 10,
                ),
              ),
              Text(
                ' Delete',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
              )
            ],
          ),
        ),
        SizedBox(width: 16),
        // Edit Button
        InkWell(
          onTap: () {
            CommonUI.showBottomSheet(
              context,
              child: EditCustomFund(
                customFundEditIndex: addedFundIndex,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AllImages().editIcon,
                height: 10,
                width: 10,
                color: ColorConstants.primaryAppColor,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  'Edit',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
