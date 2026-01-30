import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_card.dart';
import 'package:app/src/screens/clients/client_goal/widgets/delete_goal_confirmation_bottomsheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SWPSummaryCard extends StatelessWidget {
  final controller = Get.find<SwpDetailController>();

  @override
  Widget build(BuildContext context) {
    final sipStatus = getGoalTransactStatusData(controller.selectedSwp.isPaused,
        controller.selectedSwp.endDate)['statusText'];

    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 20),
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
                CommonUI.buildColumnTextInfo(
                  title: 'SWP is currently $sipStatus',
                  subtitle:
                      'Created on ${getFormattedDate(controller.selectedSwp!.createdAt!)}',
                  gap: 4,
                  titleStyle: textStyle,
                  subtitleStyle: textStyle?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                  ),
                ),
                CommonClientUI.goalTransactStatus(
                  context,
                  isPaused: controller.selectedSwp.isPaused,
                  endDate: controller.selectedSwp.endDate,
                )
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
          _buildRowData(
            context: context,
            key: 'SWP Amount',
            value: WealthyAmount.currencyFormat(
              controller.selectedSwp.amount,
              0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: _buildRowData(
              context: context,
              key: 'SWP Dates',
              value: getGoalTransactDays(controller.selectedSwp.days),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildRowData(
              context: context,
              key: 'Next SWP Date',
              value: getDateMonthYearFormat(
                controller.selectedSwp.nextSwp,
              ),
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
          _buildDeleteSWP(context),
        ],
      ),
    );
  }

  Widget _buildDeleteSWP(BuildContext context) {
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
          child: GetBuilder<SwpDetailController>(
            builder: (controller) {
              return DeleteGoalConfirmationBottomsheet(
                title: 'SWP',
                name: getSWPDisplayName(controller.selectedSwp),
                showProgressIndicator:
                    controller.editSwpResponse.state == NetworkState.loading,
                onConfirm: () async {
                  if (!controller.client.isClientIndividual) {
                    // TODO: Confirm with PM
                    CommonUI.showBottomSheet(
                      context,
                      child: ClientNonIndividualWarningBottomSheet(),
                    );
                  } else {
                    await controller.editSWP(delete: true);
                    if (controller.editSwpResponse.state ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).push(
                        ProposalSuccessRoute(
                          client: controller.client,
                          productName: 'Delete Swp',
                          proposalUrl: controller.ticketResponse?.customerUrl,
                        ),
                      );
                    } else if (controller.editSwpResponse.state ==
                        NetworkState.error) {
                      showToast(
                        text: controller.editSwpResponse.message,
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
      padding: EdgeInsets.symmetric(horizontal: 20),
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
}
