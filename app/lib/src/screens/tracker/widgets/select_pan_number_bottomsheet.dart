import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/partner_tracker_metric_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPanNumberBottomSheet extends StatelessWidget {
  const SelectPanNumberBottomSheet({Key? key, required this.client})
      : super(key: key);

  final TrackerUserModel client;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: GetBuilder<TrackerListController>(
            initState: (_) {
              Get.find<TrackerListController>()
                  .getClientPanDetails(client.taxyId ?? '');
            },
            id: 'tracker',
            builder: (controller) {
              if (controller.clientPanResponse.state == NetworkState.cancel) {
                return SizedBox();
              }

              if (controller.clientPanResponse.state == NetworkState.loading) {
                return Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.clientPanResponse.state == NetworkState.error) {
                return RetryWidget(
                  controller.clientPanResponse.message,
                  onPressed: () {
                    controller.getClientPanDetails(client.taxyId ?? '');
                  },
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      'Select a Pan',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                    ),
                  ),
                  if (controller.familyReports.isEmpty)
                    _buildEmptyState()
                  else
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                      ),
                      color: ColorConstants.white,
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 10),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: controller.familyReports.length,
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: ColorConstants.borderColor,
                            ),
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          FamilyReportModel familyReport =
                              controller.familyReports[index];
                          return _buildPanCardTile(context, familyReport);
                        },
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyScreen(
      message: "No PAN found",
    );
  }

  Widget _buildPanCardTile(
      BuildContext context, FamilyReportModel familyReport) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          MixPanelAnalytics.trackWithAgentId(
            "select_pan",
            screen: 'tracker_list',
            screenLocation: 'tracker_card',
          );
          final clientSelected =
              Client(name: client.name, taxyID: client.taxyId, crn: client.crn);

          AutoRouter.of(context).push(
            ClientTrackerRoute(
              client: clientSelected,
              familyReport: familyReport,
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'PAN Number: ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w300),
                      ),
                      Text(
                        familyReport.panNumber ?? '',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineLarge!
                            .copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Tracker Value: ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w300),
                      ),
                      Text(
                        WealthyAmount.currencyFormat(
                            familyReport.currentValue, 2),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineLarge!
                            .copyWith(fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorConstants.primaryAppColor,
            )
          ],
        ),
      ),
    );
  }
}
