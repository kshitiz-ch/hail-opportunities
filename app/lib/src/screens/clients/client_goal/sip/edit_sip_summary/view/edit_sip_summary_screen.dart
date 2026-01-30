import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/client_store_card.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class EditSipSummaryScreen extends StatelessWidget {
  const EditSipSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Edit SIP Summary',
      ),
      body: GetBuilder<ClientEditSipController>(
        builder: (controller) {
          return ListView(
            padding: EdgeInsets.only(top: 30, bottom: 100),
            children: [
              ClientStoreCard(
                client: controller.client,
              ),
              _buildSipDetail(context, controller)
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildSipDetail(
      BuildContext context, ClientEditSipController controller) {
    controller.updatedSipData.startDate = controller.pickedStartDate;
    controller.updatedSipData.endDate = controller.pickedEndDate;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'SIP Details',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 24),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: ColorConstants.primaryCardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (controller.isWealthyFund)
                  _buildPortfolioDetails(context, controller)
                else
                  _buildFundDetails(context, controller),
                if (!controller.isWealthyFund &&
                    controller.addedCustomFunds.isNotNullOrEmpty)
                  _buildTotalAmount(context, controller)
              ],
            ),
          ),
          CommonMfUI.buildSipSummaryCard(
            data: controller.updatedSipData,
            context: context,
            isSipActive: controller.isSelectedSipActive,
            selectedMandate: controller.selectedMandate,
          )
        ],
      ),
    );
  }

  Widget _buildTotalAmount(
      BuildContext context, ClientEditSipController controller) {
    double totalAmount = controller.fundSelection == FundSelection.manual
        ? controller.customFundAmount
        : controller.amount;

    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ColorConstants.lightGrey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          Text(
            WealthyAmount.currencyFormat(totalAmount, 0),
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundDetails(
      BuildContext context, ClientEditSipController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.addedCustomFunds.isNotNullOrEmpty
          ? controller.addedCustomFunds.length
          : (controller.selectedSip.sipMetaFunds ?? []).length,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 25,
        );
      },
      itemBuilder: (context, index) {
        String? displayName;
        double? amount;
        if (controller.addedCustomFunds.isNotNullOrEmpty) {
          displayName = controller.addedCustomFunds[index].displayName;
          amount = controller.addedCustomFunds[index].amountEntered;
        } else {
          displayName = controller.selectedSip.sipMetaFunds![index].schemeName;
          amount = controller.amount;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                getAmcLogo(displayName),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  displayName ?? '-',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
              ),
            ),
            Text(
              WealthyAmount.currencyFormatWithoutTrailingZero(
                amount,
                2,
              ),
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
            )
          ],
        );
      },
    );
  }

  Widget _buildPortfolioDetails(
      BuildContext context, ClientEditSipController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          backgroundImage: AssetImage(
            AllImages().storeWealthyPortfolioIcon,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              controller.selectedSip.goalName ?? '-',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black,
                  ),
            ),
          ),
        ),
        Text(
          WealthyAmount.currencyFormatWithoutTrailingZero(
            controller.amount,
            2,
          ),
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
        )
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<ClientEditSipController>(
      builder: (controller) {
        return ActionButton(
          heroTag: kDefaultHeroTag,
          text: 'Update & Save',
          showProgressIndicator:
              controller.updateSipResponse.state == NetworkState.loading,
          margin: EdgeInsets.symmetric(
            vertical: 24.0,
            horizontal: 30.0,
          ),
          borderRadius: 51.0,
          onPressed: () async {
            if (!controller.client.isProposalEnabled) {
              CommonUI.showBottomSheet(
                context,
                child: ClientNonIndividualWarningBottomSheet(),
              );
            } else {
              await controller.updateSipProposal();
              if (controller.updateSipResponse.state == NetworkState.loaded) {
                String? proposalLink = controller.updateSipProposalLink;
                AutoRouter.of(context).push(
                  ProposalSuccessRoute(
                    client: controller.client,
                    productName: 'Edit Sip',
                    proposalUrl: proposalLink,
                  ),
                );
              } else if (controller.updateSipResponse.state ==
                  NetworkState.error) {
                showToast(
                  text: controller.updateSipResponse.message,
                );
              }
            }
          },
        );
      },
    );
  }
}
