import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/stp_detail_controller.dart';
import 'package:app/src/screens/clients/client_goal/stp_detail/widgets/past_stp_orders.dart';
import 'package:app/src/screens/clients/client_goal/widgets/delete_goal_confirmation_bottomsheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../config/constants/util_constants.dart';
import '../widgets/scheme_data.dart';

@RoutePage()
class StpDetailScreen extends StatelessWidget {
  const StpDetailScreen({
    Key? key,
    required this.stp,
    required this.goal,
    required this.client,
  }) : super(key: key);

  final BaseSwitch stp;
  final GoalModel goal;
  final Client client;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StpDetailController>(
      init: StpDetailController(client: client, stp: stp, goal: goal),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: _getScreenTitle(),
            maxLine: 2,
            trailingWidgets: [
              Align(
                alignment: Alignment.centerRight,
                child: ClickableText(
                  text: 'Edit STP',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  onClick: () {
                    controller.initialiseFormStates();

                    AutoRouter.of(context).push(
                      EditStpFormRoute(),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStpSummary(context, controller),
                  SchemeData(),
                  PastStpOrders()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStpSummary(
      BuildContext context, StpDetailController controller) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );

    final sipStatus = getGoalTransactStatusData(
        controller.stp.isPaused, controller.stp.endDate)['statusText'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: 'STP is currently $sipStatus',
                    subtitle: 'Created on ${getFormattedDate(stp.createdAt)}',
                    gap: 4,
                    titleStyle: textStyle,
                    subtitleStyle: textStyle?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                ),
                CommonClientUI.goalTransactStatus(
                  context,
                  isPaused: stp.isPaused,
                  endDate: stp.endDate,
                )
                // _buildStatusUI(context)
                // CommonUI.buildColumnTextInfo(
                //   gap: 6,
                //   title: WealthyAmount.currencyFormat(stp.amount, 0),
                //   subtitle: 'Amount',
                //   titleStyle: textStyle?.copyWith(fontSize: 14),
                //   subtitleStyle: textStyle?.copyWith(
                //     fontSize: 14,
                //     color: ColorConstants.tertiaryBlack,
                //   ),
                // )
                // CommonUI.sipStatusUI(
                //   baseSip: controller.selectedSip!,
                //   context: context,
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CommonUI.buildProfileDataSeperator(
              width: double.infinity,
              height: 1,
              color: ColorConstants.borderColor,
            ),
          ),
          // _buildRowData(
          //   context: context,
          //   key: 'SIP Amount',
          //   value: WealthyAmount.currencyFormat(
          //       controller.selectedSip?.sipAmount, 0),
          // ),
          _buildRowData(
            context: context,
            key: 'STP Amount',
            value: WealthyAmount.currencyFormat(stp.amount, 0),
          ),
          _buildRowData(
            context: context,
            key: 'STP Days',
            value: stp.days ?? '-',
          ),
          _buildRowData(
            context: context,
            key: 'Start Date',
            value: getDateMonthYearFormat(
              stp.startDate,
            ),
          ),
          _buildRowData(
            context: context,
            key: 'End Date',
            value: getDateMonthYearFormat(
              stp.endDate,
            ),
          ),
          _buildRowData(
            context: context,
            key: 'Next STP Date',
            value: getDateMonthYearFormat(
              stp.nextSwitch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CommonUI.buildProfileDataSeperator(
              width: double.infinity,
              height: 1,
              color: ColorConstants.borderColor,
            ),
          ),
          _buildDeleteSTP(context)
        ],
      ),
    );
  }

  Widget _buildRowData({
    required BuildContext context,
    required String key,
    required String value,
  }) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: textStyle?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: textStyle,
          )
        ],
      ),
    );
  }

  Widget _buildDeleteSTP(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AllImages().deleteIcon,
            height: 20,
            width: 20,
            // fit: BoxFit.fitWidth,
          ),
          SizedBox(width: 6),
          Text(
            'Delete',
            style: context.headlineMedium!
                .copyWith(color: ColorConstants.errorTextColor),
          )
        ],
      ),
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: GetBuilder<StpDetailController>(
            id: GetxId.sendTicket,
            builder: (controller) {
              return DeleteGoalConfirmationBottomsheet(
                title: 'STP',
                name: _getScreenTitle(),
                showProgressIndicator:
                    controller.updateStpOrderResponse.state ==
                        NetworkState.loading,
                onConfirm: () async {
                  if (!controller.client.isClientIndividual) {
                    // TODO: Confirm with PM
                    CommonUI.showBottomSheet(
                      context,
                      child: ClientNonIndividualWarningBottomSheet(),
                    );
                  } else {
                    await controller.updateStpOrder(delete: true);
                    if (controller.updateStpOrderResponse.state ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).push(
                        ProposalSuccessRoute(
                          client: controller.client,
                          productName: 'Delete Stp',
                          proposalUrl: controller.ticketResponse?.customerUrl,
                        ),
                      );
                    } else if (controller.updateStpOrderResponse.state ==
                        NetworkState.error) {
                      showToast(
                        text: controller.updateStpOrderResponse.message,
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getScreenTitle() {
    if (stp.switchFunds.isNotNullOrEmpty &&
        stp.switchFunds!.first.switchoutSchemeName.isNotNullOrEmpty) {
      return stp.switchFunds!.first.switchoutSchemeName ?? '';
    } else {
      return goal.displayName ?? '';
    }
  }
}
