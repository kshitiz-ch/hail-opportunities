import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/demat/demats_controller.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipo_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/client_store_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

@RoutePage()
class PreIpoReviewProposalScreen extends StatelessWidget {
  // Fields
  final Client client;
  final UnlistedProductModel product;

  PreIpoReviewProposalScreen({
    Key? key,
    required this.client,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<PreIPOController>();

    return Scaffold(
      backgroundColor: ColorConstants.white,

      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Proposal Summary',
      ),

      // body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClientStoreCard(
              client: client,
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),

            SizedBox(
              height: 44,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Investment',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.tertiaryBlack),
              ),
            ),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  color: ColorConstants.primaryCardColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: ColorConstants.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: product.iconSvg != null &&
                                    product.iconSvg!.endsWith("svg")
                                ? SvgPicture.network(
                                    product.iconSvg!,
                                  )
                                : Image.network(product.iconSvg!),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            product.title!,
                            maxLines: 2,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineLarge!
                                .copyWith(
                                  fontSize: 16.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0)
                        .copyWith(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share Price',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: ColorConstants.tertiaryBlack,
                                        fontSize: 12),
                              ),
                              Text(
                                '${WealthyAmount.currencyFormatWithoutTrailingZero(
                                  _controller.sharePrice,
                                  2,
                                )}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No of Shares',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: ColorConstants.tertiaryBlack,
                                        fontSize: 12),
                              ),
                              Text(
                                '${_controller.shares!.toInt()}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: ColorConstants.lightGrey,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                        Text(
                          '${WealthyAmount.currencyFormatWithoutTrailingZero(
                            (_controller.sharePrice ?? 0) *
                                (_controller.shares ?? 0),
                            2,
                          )}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displayLarge!
                              .copyWith(fontSize: 16),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Share Price
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: GetBuilder<PreIPOController>(
        id: GetxId.createProposal,
        builder: (_) {
          return ActionButton(
            heroTag: kDefaultHeroTag,
            showProgressIndicator:
                _controller.createProposalState == NetworkState.loading,
            text: 'Send to Client',
            margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            onPressed: () async {
              // Check if kyc is approved
              int? agentKycStatus = await getAgentKycStatus();
              if (agentKycStatus != AgentKycStatus.APPROVED) {
                CommonUI.showBottomSheet(context,
                    child: ProposalKycAlertBottomSheet());
                return null;
              }

              await _controller.createProposal();

              if (_controller.createProposalState == NetworkState.error) {
                return showToast(
                  context: context,
                  text: _controller.createProposalErrorMessage,
                );
              }

              if (_controller.createProposalState == NetworkState.loaded &&
                  _controller.createProposalResponse != null) {
                final dematsController = Get.isRegistered<DematsController>()
                    ? Get.find<DematsController>()
                    : null;

                AutoRouter.of(context).push(ProposalSuccessRoute(
                  proposalUrl: _controller.proposalUrl,
                  client: _controller.selectedClient,
                  productName: product.title,
                  shouldPromptDemat: true,
                  expiryTime: product.expiryTime,
                  isBankAdded: dematsController?.isBankAccountExists ?? false,
                  isDematAdded: dematsController?.isDematAccountExists ?? false,
                )
                    // PreIPOSuccessRoute(
                    //   proposalUrl: _controller.proposalUrl,
                    //   client: _controller.selectedClient,
                    //   productName: product.title,
                    //   expiryTime: product.expiryTime,
                    //   isBankAdded: dematsController?.isBankAccountExists ?? false,
                    //   isDematAdded:
                    //       dematsController?.isDematAccountExists ?? false,
                    // ),
                    );
              }
            },
          );
        },
      ),
    );
  }
}
