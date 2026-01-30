import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart' as enums;
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/basket/widgets/basket_amount_section.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/screens/store/common_new/widgets/activate_step_up_sip.dart';
import 'package:app/src/screens/store/common_new/widgets/sip_day_stepup_selector_section.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketFundListTile extends StatelessWidget {
  final String? tag;
  final int index;
  late BasketController controller;
  final SchemeMetaModel fund;
  final bool isLastItem;
  final GlobalKey<AnimatedListState>? listKey;

  BasketFundListTile({
    Key? key,
    this.tag,
    required this.index,
    required this.fund,
    this.isLastItem = false,
    this.listKey,
  }) : super(key: key) {
    controller = Get.find<BasketController>(tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFundLogo(context),
              _buildFundName(context),
              buildDeleteWidget(context),
            ],
          ),
          SizedBox(height: 20),
          BasketAmountSection(fund: fund, tag: tag),
          SizedBox(height: 12),
          _buildSipDetail(context),
        ],
      ),
    );
  }

  Widget _buildFundLogo(context) {
    return CommonUI.buildRoundedFullAMCLogo(
      radius: 18,
      amcName: fund.displayName,
    );
  }

  Widget _buildFundName(context) {
    return Expanded(
      // flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund.displayName ?? '',
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    getFundDescription(fund),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteWidget(BuildContext context) {
    if (controller.isTopUpPortfolio &&
        controller.portfolio?.productVariant == anyFundGoalSubtype) {
      return SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () async {
            if (controller.isUpdateProposal && controller.basket.length == 1) {
              return showToast(text: 'At least one fund is required');
            }

            // open delete fund bottom sheet
            CommonUI.showBottomSheet(
              context,
              child: DeleteFundBottomSheet(
                onCancel: () {
                  AutoRouter.of(context).popForced();
                },
                onDelete: () async {
                  await deleteFund(
                    context: context,
                    controller: controller,
                    index: index,
                    fund: fund,
                    // tag: tag,
                  );

                  // pop DeleteBottomSheet
                  AutoRouter.of(context).popForced();
                  // show toast
                  showCustomToast(
                    context: context,
                    child: Container(
                      width: SizeConfig().screenWidth,
                      // margin: const EdgeInsets.only(bottom: 136.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: ColorConstants.black.withOpacity(0.9),
                      ),
                      child: Text(
                        "Fund Deleted from Basket ✅",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.white,
                            ),
                      ),
                    ),
                  );

                  if (controller.anyFundSipData.containsKey(fund.basketKey)) {
                    controller.anyFundSipData.remove(fund.basketKey);
                  }
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSipDetail(BuildContext context) {
    if (controller.anyFundSipData.isEmpty || controller.fromCustomPortfolios) {
      return SizedBox();
    }
    return GetBuilder<BasketController>(
      id: 'basket-summary',
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      builder: (basketController) {
        final showSipSection =
            controller.investmentType == enums.InvestmentType.SIP;

        SipData? anyFundSipData =
            basketController.anyFundSipData[fund.basketKey];
        double? amountEntered =
            basketController.basket[fund.basketKey]?.amountEntered;
        return showSipSection
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SipDayStepUpSelectorSection(
                  sipData: anyFundSipData!,
                  allowedSipDays: controller.allowedSipDays.toList(),
                  onChooseDays: (data) {
                    anyFundSipData.updateSelectedSipDays(data);
                    controller.update(['basket-summary']);
                  },
                  openActivateStepUpSip: () {
                    openActivateStepUpSip(controller, context);
                  },
                  sipAmount: amountEntered ?? 0,
                  onToggleStepUpSip: (value) {
                    if (value) {
                      openActivateStepUpSip(controller, context);
                    } else {
                      anyFundSipData.updateIsStepUpSipEnabled(value);
                      controller.update(['basket-summary']);
                    }
                  },
                  onChooseEndDate: (endDate) {
                    anyFundSipData.updateEndDate(endDate);
                    controller.update(['basket-summary']);
                  },
                  onChooseStartDate: (startDate) {
                    anyFundSipData.updateStartDate(startDate);
                    controller.update(['basket-summary']);
                  },
                ),
              )
            : SizedBox(
                width: double.infinity,
              );
      },
    );
  }

  void openActivateStepUpSip(
      BasketController controller, BuildContext context) {
    SipData? anyFundSipData = controller.anyFundSipData[fund.basketKey];
    double? amountEntered = controller.basket[fund.basketKey]?.amountEntered;

    CommonUI.showBottomSheet(
      context,
      child: ActivateStepUpSip(
        onUpdateStepUpPeriod: (stepUpPeriod, stepUpPercentage) {
          anyFundSipData?.activateStepUpSip(
            stepUpPeriod,
            stepUpPercentage,
          );
          anyFundSipData?.updateIsStepUpSipEnabled(true);
          controller.update(['basket']);
          AutoRouter.of(context).popForced();
        },
        selectedStepUpPeriod: anyFundSipData!.stepUpPeriod,
        sipAmount: amountEntered ?? 0,
        stepUpPercentage: anyFundSipData.stepUpPercentage,
        stepUpPercentageController: anyFundSipData.stepUpPercentageController,
      ),
    );
  }
}
