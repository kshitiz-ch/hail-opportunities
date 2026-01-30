import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tracker/select_pan_number_bottomsheet.dart';

class TrackerValueCard extends StatelessWidget {
  // Fields
  final double? trackerValue;
  final DateTime? lastSyncedAt;
  final Client? client;

  // Constructor
  const TrackerValueCard(
      {Key? key, required this.trackerValue, this.lastSyncedAt, this.client})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientAdditionalDetailController>(
        id: 'tracker',
        builder: (controller) {
          return InkWell(
            onTap: () {
              if (controller.familyReports.isNotEmpty) {
                CommonUI.showBottomSheet(
                  context,
                  child: SelectPanNumberBottomSheet(
                    onClick: (FamilyReportModel familyReport) {
                      AutoRouter.of(context).push(
                        ClientTrackerRoute(
                            client: client!, familyReport: familyReport),
                      );
                    },
                  ),
                );
              } else {
                AutoRouter.of(context).push(
                  ClientTrackerRoute(client: client!, familyReport: null),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: ColorConstants.primaryCardColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AllImages().trackerOutlinedIcon,
                          height: 20,
                          width: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            'Tracker Value',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  color: ColorConstants.black,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CommonUI.buildColumnTextInfo(
                            title: 'Mutual Fund Tracker Value',
                            gap: 4,
                            titleStyle: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                ),
                            subtitle:
                                WealthyAmount.currencyFormat(trackerValue, 2),
                            subtitleStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  color: ColorConstants.black,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // if (lastSyncedAt != null)
                        //   RichText(
                        //     text: TextSpan(
                        //       children: [
                        //         TextSpan(
                        //           text: 'Last Synced ',
                        //           style: Theme.of(context)
                        //               .primaryTextTheme
                        //               .titleLarge!
                        //               .copyWith(
                        //                 color: ColorConstants.tertiaryBlack,
                        //               ),
                        //         ),
                        //         // if (lastSyncedAt != null)
                        //         TextSpan(
                        //           text: DateFormat('MMM d, yyy')
                        //               .format(lastSyncedAt!),
                        //           style: Theme.of(context)
                        //               .primaryTextTheme
                        //               .titleLarge!
                        //               .copyWith(
                        //                 color: ColorConstants.black,
                        //               ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        CommonUI.triggerSyncUI(context, client!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
