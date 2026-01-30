import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'revenue_sheet_overview_breakdown.dart';

class RevenueSheetOverview extends StatelessWidget {
  const RevenueSheetOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.aliceBlueColor,
      child: Column(
        children: [
          CustomAppBar(
            titleText: 'Revenue Sheet',
            trailingWidgets: [
              GetBuilder<RevenueSheetController>(
                builder: (controller) {
                  return PartnerOfficeDropdown(
                    tag: 'revenue-sheet',
                    title: 'Revenue Sheet',
                    onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                      MixPanelAnalytics.trackWithAgentId(
                        "employee_selection",
                        screen: 'revenue_sheet',
                        screenLocation: 'revenue_summary',
                      );
                      controller
                          .updatePartnerEmployeeSelected(partnerOfficeModel);
                    },
                    canSelectAllEmployees: true,
                    canSelectPartnerOffice: true,
                  );
                },
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 25),
            child: Column(
              children: [
                _buildMonthSelector(context),
                SizedBox(height: 25),
                GetBuilder<RevenueSheetController>(
                  id: GetxId.overview,
                  builder: (controller) {
                    if (controller.revenueSheetOverviewResponse.state ==
                        NetworkState.loading) {
                      return SkeltonLoaderCard(height: 100);
                    }

                    if (controller.revenueSheetOverviewResponse.state ==
                        NetworkState.error) {
                      return RetryWidget(
                        'Something went wrong.\n Please try again',
                        onPressed: controller.getRevenueSheetOverview,
                      );
                    }

                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonUI.buildColumnTextInfo(
                              title: 'Current Revenue',
                              titleStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                              subtitle: WealthyAmount
                                  .currencyFormatWithoutTrailingZero(
                                      controller
                                          .revenueSheetOverview?.currentRevenue,
                                      2),
                              subtitleStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(fontSize: 18)),
                          SizedBox(height: 30),
                          RevenueSheetOverviewBreakdown()
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );

    return GetBuilder<RevenueSheetController>(
      id: GetxId.overview,
      builder: (controller) {
        return InkWell(
          onTap: () {
            if (controller.revenueSheetOverviewResponse.state ==
                NetworkState.loading) {
              return;
            }

            MixPanelAnalytics.trackWithAgentId(
              "month_selection",
              screen: 'revenue_sheet',
              screenLocation: 'revenue_summary',
            );

            CommonUI.monthYearSelector(
              context,
              selectedDate: controller.overviewDate,
              onDateSelect: controller.updateOverviewDate,
            );
          },
          child: Row(
            children: [
              Image.asset(
                AllImages().calendarCheckIcon,
                width: 26,
                height: 26,
              ),
              SizedBox(width: 3),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      DateFormat('MMM yyyy').format(controller.overviewDate),
                      style: style!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.primaryAppColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: ColorConstants.primaryAppColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
