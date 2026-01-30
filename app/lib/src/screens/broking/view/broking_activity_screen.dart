import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/broking/broking_activity_controller.dart';
import 'package:app/src/controllers/broking/broking_search_controller.dart';
import 'package:app/src/screens/broking/widgets/broking_client_activities.dart';
import 'package:app/src/screens/broking/widgets/broking_search_bar.dart';
import 'package:app/src/screens/broking/widgets/broking_search_results.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

@RoutePage()
class BrokingActivityScreen extends StatelessWidget {
  final brokingSearchController =
      Get.put<BrokingSearchController>(BrokingSearchController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingActivityController>(
      init: BrokingActivityController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(titleText: 'Brokerage'),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildHeader(context, controller),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: BrokingSearchBar(
                  onClearText: () {
                    controller.getBrokingActivityData();
                  },
                ),
              ),
              GetBuilder<BrokingSearchController>(
                builder: (searchController) {
                  return Expanded(
                    child: searchController.isInSearchMode
                        ? BrokingSearchResults(type: 'brokerage')
                        : BrokingClientActivities(),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, BrokingActivityController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSelectedDate(context, controller),
        PartnerOfficeDropdown(
          tag: 'Brokerage',
          onEmployeeSelect: controller.updatePartnerEmployeeSelected,
          title: 'Brokerage',
          canSelectAllEmployees: true,
          canSelectPartnerOffice: true,
        )
      ],
    );
  }

  Widget _buildSelectedDate(
      BuildContext context, BrokingActivityController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For Month of',
          style: style,
        ),
        InkWell(
          onTap: () {
            CommonUI.monthYearSelector(
              context,
              selectedDate: controller.brokingActivitySelectedDate,
              onDateSelect: controller.updateBrokingDateSelected,
              startDate: DateTime(2023, 3),
            );
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  DateFormat('MMM yyyy')
                      .format(controller.brokingActivitySelectedDate),
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
        ),
      ],
    );
  }
}
