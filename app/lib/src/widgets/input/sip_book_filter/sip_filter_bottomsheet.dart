import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipBookFilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter SIPs by',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                  ),
                  CommonUI.bottomsheetCloseIcon(context)
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: RadioButtons(
                  spacing: 10,
                  runSpacing: 80,
                  direction: Axis.vertical,
                  items: SipUserDataFilter.values,
                  selectedValue: controller.tempFilter,
                  onTap: (filterSelected) {
                    MixPanelAnalytics.trackWithAgentId(
                      "${getFilterText(filterSelected)}",
                      screen: 'sip_book',
                      screenLocation: 'sip_book_filter',
                    );
                    controller.tempFilter = filterSelected;
                    controller.update();
                  },
                  itemBuilder: (context, value, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        getFilterText(value),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displayMedium!
                            .copyWith(
                              fontSize: 16,
                              color: controller.tempFilter == value
                                  ? ColorConstants.black
                                  : ColorConstants.tertiaryBlack,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildFilterCTA(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildFilterCTA(BuildContext context, SipBookController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryAppColor,
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              text: 'Clear All',
              margin: EdgeInsets.zero,
              bgColor: ColorConstants.secondaryButtonColor,
              textStyle: style,
              onPressed: () {
                MixPanelAnalytics.trackWithAgentId(
                  "clear_all",
                  screen: 'sip_book',
                  screenLocation: 'sip_book_filter',
                );
                controller.resetFilters();
                AutoRouter.of(context).popForced();
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              margin: EdgeInsets.zero,
              text: 'Apply',
              textStyle: style?.copyWith(color: ColorConstants.white),
              onPressed: () {
                MixPanelAnalytics.trackWithAgentId(
                  "filter_apply",
                  screen: 'sip_book',
                  screenLocation: 'sip_book_filter',
                );
                controller.saveFilters();
                AutoRouter.of(context).popForced();
              },
            ),
          ),
        ],
      ),
    );
  }

  String getFilterText(SipUserDataFilter filterType) {
    String filterDescription = filterType.name;
    if (filterType == SipUserDataFilter.isPaused) {
      filterDescription = 'Paused SIPs';
    }
    if (filterType == SipUserDataFilter.isActive) {
      filterDescription = 'Active SIPs';
    }
    if (filterType == SipUserDataFilter.isInactive) {
      filterDescription = 'Inactive SIPs';
    }
    if (filterType == SipUserDataFilter.pausedCurrentMonth) {
      filterDescription = 'Paused SIPs (Current Month)';
    }
    if (filterType == SipUserDataFilter.sipRegisteredCurrentMonth) {
      filterDescription = 'New SIP Registered (Current Month)';
    }
    if (filterType == SipUserDataFilter.notMandateApproved) {
      filterDescription = 'SIP(s) Pending at eMandate stage';
    }
    return filterDescription;
  }
}
