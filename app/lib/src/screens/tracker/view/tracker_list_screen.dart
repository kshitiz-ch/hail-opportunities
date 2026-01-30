import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/partner_tracker_metric_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/select_pan_number_bottomsheet.dart';

@RoutePage()
class TrackerListScreen extends StatelessWidget {
  const TrackerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackerListController>(
      init: TrackerListController(isTrackerListing: true),
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Tracker',
            subtitleText:
                'Tracker will help you get latest mutual fund investment details of your clients',
          ),
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: _buildTrackerOverview(context, controller),
                ),
                Expanded(
                  child: _buildTrackerClients(context),
                )
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            text: 'Create Tracker Request',
            borderRadius: 130,
            onPressed: () {
              AutoRouter.of(context).push(SendTrackerRequestRoute());
            },
            showProgressIndicator: false,
          ),
        );
      },
    );
  }

  Widget _buildTrackerOverview(
      BuildContext context, TrackerListController controller) {
    if (controller.trackerMetricResponse.state == NetworkState.loading) {
      return SkeltonLoaderCard(height: 120);
    }

    if (controller.trackerMetricResponse.state == NetworkState.error) {
      return RetryWidget(
        controller.trackerMetricResponse.message,
        onPressed: controller.getTrackerMetrics,
      );
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    top: 12,
                    bottom: 12,
                  ),
                  child: CommonUI.buildColumnText(
                    context,
                    label: 'Total Tracker Amount',
                    value: WealthyAmount.currencyFormat(
                        controller.trackerAggMetrics?.totalFamilyMfCurrentValue,
                        1),
                    labelFontSize: 12,
                    valueFontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                  ),
                  child: CommonUI.buildColumnText(
                    context,
                    label: 'External Tracked Amount',
                    value: WealthyAmount.currencyFormat(
                        controller.trackerAggMetrics?.totalCobOpportunityValue,
                        1),
                    labelFontSize: 12,
                    valueFontSize: 16,
                  ),
                ),
              )
            ],
          ),
          Divider(color: ColorConstants.borderColor),
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              top: 12,
              bottom: 12,
            ),
            child: CommonUI.buildColumnText(
              context,
              label: 'Tracker Clients',
              value: (controller.trackerAggMetrics?.totalUsers ?? 0).toString(),
              labelFontSize: 12,
              valueFontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrackerClients(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracked Clients',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
        SizedBox(height: 10),
        Expanded(
          child: GetBuilder<TrackerListController>(
            builder: (controller) {
              if (controller.trackerMetricResponse.state ==
                  NetworkState.loading) {
                return ListView.separated(
                  padding: EdgeInsets.only(bottom: 100),
                  itemCount: 3,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return SkeltonLoaderCard(height: 100);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 15);
                  },
                );
              }

              if (controller.trackerMetricResponse.state ==
                  NetworkState.error) {
                return RetryWidget(
                  controller.trackerMetricResponse.message,
                  onPressed: controller.getTrackerMetrics,
                );
              }

              if (controller.trackedClients.isEmpty) {
                return EmptyScreen(
                  message: 'No Clients Found',
                );
              }

              return ListView.separated(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: controller.trackedClients.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildClientCard(
                      context, controller.trackedClients[index]);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 15);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(BuildContext context, TrackerUserModel user) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: CommonUI.buildColumnTextInfo(
                    title: user.name ?? '-',
                    subtitle: 'CRN ${user.crn ?? '-'}',
                    titleStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                    subtitleStyle: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: CommonUI.buildColumnText(
                    context,
                    label: 'Total Tracked Amount',
                    value: WealthyAmount.currencyFormat(
                        user.trakFamilyMfCurrentValue, 1),
                  ),
                ),
              )
            ],
          ),
          Divider(color: ColorConstants.borderColor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'External Tracker Amount',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                SizedBox(width: 5),
                Text(
                  WealthyAmount.currencyFormat(user.trakCobOpportunityValue, 1),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                ClickableText(
                  onClick: () {
                    CommonUI.showBottomSheet(
                      context,
                      child: SelectPanNumberBottomSheet(client: user),
                    );
                  },
                  prefixIcon: Icon(
                    Icons.sync,
                    color: ColorConstants.primaryAppColor,
                  ),
                  text: ' Switch',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
