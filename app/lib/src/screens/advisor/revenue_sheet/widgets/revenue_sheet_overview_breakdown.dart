import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueSheetOverviewBreakdown extends StatefulWidget {
  const RevenueSheetOverviewBreakdown({Key? key}) : super(key: key);

  @override
  State<RevenueSheetOverviewBreakdown> createState() =>
      _RevenueSheetOverviewBreakdownState();
}

class _RevenueSheetOverviewBreakdownState
    extends State<RevenueSheetOverviewBreakdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenueSheetController>(
      id: GetxId.overview,
      builder: (controller) {
        return Column(
          children: [
            _buildRevenueBreakdown(context, controller),
            if (isExpanded)
              _buildAdditionalRevenueBreakdown(context, controller)
          ],
        );
      },
    );
  }

  Widget _buildRevenueBreakdown(
      BuildContext context, RevenueSheetController controller) {
    final currentDate = DateTime.now();
    bool showUnlockToolTip =
        DateUtils.isSameMonth(controller.overviewDate, currentDate);
    if (!showUnlockToolTip) {
      // o get the last date of the current month,
      // you need to refer to the 0th day of the next month
      final lastday = DateTime(controller.overviewDate.year,
              controller.overviewDate.month + 1, 0)
          .day;
      // 15th of month is payout date after 15th dont show tooltip
      final daysDiff = currentDate
          .difference(controller.overviewDate.copyWith(day: lastday))
          .inDays;
      if (daysDiff < 16) {
        showUnlockToolTip = true;
      } else {
        showUnlockToolTip = false;
      }
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showUnlockToolTip
                  ? CommonUI.buildInfoToolTip(
                      onTriggered: () {
                        MixPanelAnalytics.trackWithAgentId(
                          "i_click",
                          screen: 'revenue_sheet',
                          screenLocation: 'revenue_summary',
                        );
                      },
                      context: context,
                      titleText: 'Unlocked',
                      titleStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                      toolTipMessage: 'Revenue earned and to be released',
                    )
                  : Text(
                      'Unlocked',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
              SizedBox(height: 8),
              Row(
                children: [
                  Image.asset(
                    AllImages().unLockedIcon,
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    WealthyAmount.currencyFormatWithoutTrailingZero(
                        controller.revenueSheetOverview?.unlockedRevenue, 2),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUI.buildInfoToolTip(
                context: context,
                onTriggered: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "i_click",
                    screen: 'revenue_sheet',
                    screenLocation: 'revenue_summary',
                  );
                },
                titleText: 'Locked',
                titleStyle: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: ColorConstants.tertiaryBlack),
                toolTipMessage: 'Revenue earned but not released',
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Image.asset(
                    AllImages().lockedIcon,
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    WealthyAmount.currencyFormatWithoutTrailingZero(
                        controller.revenueSheetOverview?.lockedRevenue, 2),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                            fontSize: 14, color: ColorConstants.tangerineColor),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () {
              if (!isExpanded) {
                MixPanelAnalytics.trackWithAgentId(
                  "more",
                  screen: 'revenue_sheet',
                  screenLocation: 'revenue_summary',
                );
              }
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(5).copyWith(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorConstants.primaryAppColor.withOpacity(0.05),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: ColorConstants.primaryAppColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    isExpanded ? 'Less  ' : 'More',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.primaryAppColor),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalRevenueBreakdown(
      BuildContext context, RevenueSheetController controller) {
    final titleStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(color: ColorConstants.tertiaryBlack);
    final subTitleStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(fontWeight: FontWeight.w600);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonUI.buildColumnTextInfo(
            title: '',
            subtitle: WealthyAmount.currencyFormatWithoutTrailingZero(
                controller.revenueSheetOverview?.upfrontRevenue, 2),
            subtitleStyle: subTitleStyle,
            titleSuffixIcon: CommonUI.buildInfoToolTip(
              onTriggered: () {
                MixPanelAnalytics.trackWithAgentId(
                  "i_click",
                  screen: 'revenue_sheet',
                  screenLocation: 'revenue_summary',
                );
              },
              titleText: 'Upfront Revenue',
              titleStyle: titleStyle,
              context: context,
              toolTipMessage: 'One-time revenue earned',
            ),
          ),
          CommonUI.buildColumnTextInfo(
            title: '',
            subtitle: WealthyAmount.currencyFormatWithoutTrailingZero(
                controller.revenueSheetOverview?.trailRevenue, 2),
            subtitleStyle: subTitleStyle,
            titleSuffixIcon: CommonUI.buildInfoToolTip(
              onTriggered: () {
                MixPanelAnalytics.trackWithAgentId(
                  "i_click",
                  screen: 'revenue_sheet',
                  screenLocation: 'revenue_summary',
                );
              },
              titleText: 'Trail Revenue',
              titleStyle: titleStyle,
              context: context,
              toolTipMessage: 'Recurring revenue earned over period of time',
            ),
          ),
          CommonUI.buildColumnTextInfo(
            title: '',
            subtitle: WealthyAmount.currencyFormatWithoutTrailingZero(
                controller.revenueSheetOverview?.rewardRevenue, 2),
            subtitleStyle: subTitleStyle,
            titleSuffixIcon: CommonUI.buildInfoToolTip(
              onTriggered: () {
                MixPanelAnalytics.trackWithAgentId(
                  "i_click",
                  screen: 'revenue_sheet',
                  screenLocation: 'revenue_summary',
                );
              },
              titleText: 'Bonus / Reward',
              titleStyle: titleStyle,
              context: context,
              toolTipMessage: 'Additional revenue earned as bonus',
            ),
          ),
        ],
      ),
    );
  }
}
