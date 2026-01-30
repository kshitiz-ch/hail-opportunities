import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPanNumberBottomSheet extends StatelessWidget {
  const SelectPanNumberBottomSheet({Key? key, required this.onClick})
      : super(key: key);

  final void Function(FamilyReportModel familyReport) onClick;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientAdditionalDetailController>(
      id: 'tracker',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
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
                      return _buildPanCardTile(context, onClick, familyReport);
                    },
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyScreen(
      message: "No PAN found",
    );
  }

  Widget _buildPanCardTile(
      BuildContext context,
      void Function(FamilyReportModel familyReport) onClick,
      FamilyReportModel familyReport) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          MixPanelAnalytics.trackWithAgentId(
            "select_pan",
            screen: 'user_profile',
            screenLocation: 'tracker_card',
          );

          onClick(familyReport);
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
