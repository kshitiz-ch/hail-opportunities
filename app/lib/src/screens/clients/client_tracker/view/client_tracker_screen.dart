import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_tracker_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/send_tracker_request_bottom_sheet.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/allocation_line_chart.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/client_holdings.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ClientTrackerScreen extends StatelessWidget {
  final Client client;
  final FamilyReportModel? familyReport;

  ClientTrackerScreen(
      {Key? key, required this.client, required this.familyReport})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'Mutual Fund Tracker Value',
        showBackButton: true,
      ),
      body: GetBuilder<ClientTrackerController>(
        init: ClientTrackerController(client, familyReport),
        builder: (ClientTrackerController controller) {
          if (controller.clientAllocationDetailState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.clientAllocationDetailState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.clientAllocationDetailErrorMessage,
                onPressed: () {
                  controller.getClientAllocationDetails();
                },
              ),
            );
          }
          if (controller.clientAllocationDetailState == NetworkState.loaded) {
            // WidgetsBinding.instance.addPostFrameCallback(
            //   (_) async {
            //     if (!controller.isSwitchUpdateViewed) {
            //       controller.disableSwitchUpdateBottomSheet();
            //       await CommonUI.showBottomSheet(
            //         context,
            //         child: TrackerSwitchUpdateBottomSheet(),
            //       );
            //     }
            //   },
            // );

            if (controller.clientTrackerAllocation == null ||
                controller.clientTrackerAllocation!.allocation.isNullOrEmpty) {
              return Center(
                child: EmptyScreen(
                  imagePath: AllImages().trackerPng,
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w700,
                      ),
                  message:
                      'No Tracker related details found.\n Click to sync tracker details.',
                  onClick: () {
                    CommonUI.showBottomSheet(
                      context,
                      child: SendTrackerRequestBottomSheet(client: client),
                    );
                  },
                  actionButtonText: 'Trigger Tracker Sync',
                ),
              );
            }

            final trackerValue =
                controller.clientTrackerAllocation?.currentValue ?? 0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientOverview(
                    context,
                    trackerValue,
                  ),
                  _buildSyncInformation(context),
                  AllocationLineChart(
                    allocationMapping: controller.allocationMapping,
                  ),
                  ClientHoldings(),
                ],
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildClientOverview(BuildContext context, double trackerValue) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: CommonUI.buildColumnTextInfo(
                title: client.name ?? '',
                titleMaxLength: 2,
                subtitle: familyReport?.panNumber ?? 'NA',
                titleStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CommonUI.buildColumnTextInfo(
                title: 'Tracker Value',
                subtitle: WealthyAmount.currencyFormat(trackerValue, 0),
                titleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                          overflow: TextOverflow.ellipsis,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSyncInformation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Row(
        children: [
          if (familyReport?.syncDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text.rich(
                TextSpan(
                  text: 'Last Synced ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                  children: [
                    TextSpan(
                      text: DateFormat('MMM d, yyy')
                          .format(familyReport!.syncDate!),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.black,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          CommonUI.triggerSyncUI(context, client),
        ],
      ),
    );
  }
}
