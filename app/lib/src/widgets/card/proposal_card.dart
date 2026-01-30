import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;

class ProposalCard extends StatelessWidget {
  final ProposalModel? proposal;
  final int? index;
  final bool showProposalActions;
  final bool isEmployeeFlow;

  const ProposalCard(
      {this.proposal,
      this.index,
      this.showProposalActions = true,
      this.isEmployeeFlow = false});

  @override
  Widget build(BuildContext context) {
    if (proposal == null) return SizedBox();
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "proposal_card_click",
          screen: 'proposals',
          screenLocation: 'proposal_card',
        );

        AutoRouter.of(context).push(
          ProposalDetailsRoute(
              proposal: proposal,
              showProposalActions: showProposalActions,
              isEmployeeFlow: isEmployeeFlow),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: update show order status logic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProposalData(context, true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildOrderStatus(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: ColorConstants.borderColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProposalClientDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalData(
    BuildContext context,
    bool showOrderStatus,
  ) {
    final investmentType = proposal?.productExtrasJson?['order_type'] != null
        ? getInvestmentTypeFromString(
            proposal?.productExtrasJson?['order_type'],
          )
        : null;

    String investmentTypeText = '';
    if (investmentType == InvestmentType.SIP) {
      investmentTypeText = 'Sip';
    } else if (investmentType == InvestmentType.oneTime) {
      investmentTypeText = 'Purchase';
    } else {
      investmentTypeText = '';
    }

    bool canTopUp = (showProposalActions) &&
        (proposal?.canTopup ?? false) &&
        proposal?.productType?.toLowerCase() == ProductType.MF &&
        proposal?.productTypeVariant != anyFundGoalSubtype;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              proposal?.displayName == null
                  ? SizedBox.shrink()
                  : Text(
                      proposal?.displayName ?? '',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal?.productType?.toTitleCase() ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge
                          ?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                    // ONE TIME or SIP
                    if (proposal?.productType?.toLowerCase() == ProductType.MF)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: CommonUI.buildProfileDataSeperator(
                              height: 14,
                              color: ColorConstants.lightGrey,
                              width: 1,
                            ),
                          ),
                          Text(
                            investmentTypeText,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (canTopUp)
                Text(
                  'Created on ${getFormattedDate(proposal?.createdAt)}',
                  textAlign: TextAlign.right,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                )
              else
                CommonUI.buildColumnTextInfo(
                  title: 'Created on',
                  subtitle: getFormattedDate(proposal?.createdAt),
                  titleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                  subtitleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                  gap: 4,
                ),
              if (canTopUp)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 95,
                    height: 36,
                    child: GetBuilder<MFPortfoliosController>(
                        id: GetxId.topUpPortfolios,
                        dispose: (_) {
                          // Get.delete<MFPortfoliosController>();
                        },
                        builder: (controller) {
                          final showLoader =
                              controller.selectedProposalExternalId ==
                                      proposal?.externalId &&
                                  (controller.proposalDetailState ==
                                          NetworkState.loading ||
                                      controller.portfolioDetailState ==
                                          NetworkState.loading);

                          // controller.portfolioDetailState == NetworkState.loading &&
                          //     controller.selectedProposalExternalId ==
                          //         proposal.externalId;

                          return ActionButton(
                            customLoader: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: ColorConstants.primaryAppColor,
                              ),
                            ),
                            showProgressIndicator: showLoader,
                            showBorder: true,
                            borderColor: ColorConstants.primaryAppColor,
                            borderRadius: 50,
                            onPressed: () async {
                              if (showLoader) {
                                return null;
                              }

                              controller.updateProposalExternalId(
                                  proposal?.externalId);
                              final proposalDetail =
                                  await controller.getUpdatedProposalDetail(
                                      proposal!.externalId!);
                              if (proposalDetail == null) {
                                return showToast(
                                    text:
                                        'This proposal is not currently available for top up');
                              }
                              await onTopUpPortfolioClick(
                                proposal: proposalDetail,
                                controller: controller,
                                context: context,
                              );
                            },
                            margin: EdgeInsets.only(left: 15),
                            bgColor: ColorConstants.secondaryAppColor,
                            text: 'Top Up',
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: ColorConstants.primaryAppColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          );
                        }),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOrderStatus(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (proposal?.status == ProposalStatus.FAILURE)
            Icon(
              Icons.close,
              color: ColorConstants.redAccentColor,
            )
          else
            Image.asset(
              proposal?.status == ProposalStatus.COMPLETED
                  ? AllImages().proposalCompletedIcon
                  : AllImages().proposalPendingIcon,
              height: 20,
              width: 20,
            ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                proposal?.statusStr ?? '',
                maxLines: 2,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalClientDetails(BuildContext context) {
    return _responsiveRow(context);
  }

  Widget _buildCallUI(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            MixPanelAnalytics.trackWithAgentId(
              "call_now",
              screen: 'proposals',
              screenLocation: 'proposal_card',
            );
            if (proposal?.customer?.phoneNumber.isNotNullOrEmpty ?? false) {
              callNumber(number: proposal?.customer?.phoneNumber);
            } else {
              showToast(
                  text: 'Client phone number not available for this proposal');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.call,
                size: 13,
                color: ColorConstants.primaryAppColor,
              ),
              SizedBox(width: 4),
              Text(
                'Call Now',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.primaryAppColor,
                        ),
              )
            ],
          ),
        ),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          onPressed: () {
            MixPanelAnalytics.trackWithAgentId(
              "copy_phone_number",
              screen: 'proposals',
              screenLocation: 'proposal_card',
            );

            if (proposal?.customer?.phoneNumber.isNotNullOrEmpty ?? false) {
              copyData(data: proposal?.customer?.phoneNumber);
            } else {
              showToast(
                  text: 'Client phone number not available for this proposal');
            }
          },
          icon: Icon(
            Icons.copy,
            size: 12,
            color: ColorConstants.primaryAppColor,
          ),
        )
      ],
    );
  }

  Widget _responsiveRow(BuildContext context) {
    final investmentType = proposal?.productExtrasJson?['order_type'] != null
        ? getInvestmentTypeFromString(
            proposal?.productExtrasJson?['order_type'],
          )
        : null;

    String? sipDate;
    if (investmentType == InvestmentType.SIP &&
        proposal?.productExtrasJson?['sip'] != null &&
        proposal?.productExtrasJson?['sip']['sip_day'] != null) {
      try {
        sipDate =
            getOrdinalNumber(proposal?.productExtrasJson?['sip']['sip_day']);
      } catch (error) {
        LogUtil.printLog(error);
      }
    }

    Widget firstChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          normaliseName(proposal?.customer?.name ?? ''),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        ),
        _buildCallUI(context),
      ],
    );
    Widget secondChild = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sipDate.isNotNullOrEmpty)
          Text(
            'SIP Day: $sipDate',
            style: Theme.of(context)
                .primaryTextTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        LayoutBuilder(
          builder: (context, size) {
            final paymentStr = proposal?.isMandate == true
                ? 'Mandate Amount'
                : proposal?.isSip == true
                    ? "Sip Amount"
                    : proposal?.paymentStatusStr ?? '';
            final span = TextSpan(
              text: paymentStr,
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    color: ColorConstants.black,
                    overflow: TextOverflow.ellipsis,
                  ),
            );

            // Use a textpainter to determine if it will exceed max lines
            final tp = TextPainter(
              maxLines: 2,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              text: span,
            );
            tp.layout(maxWidth: size.maxWidth);
            final exceeded = tp.didExceedMaxLines;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    paymentStr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (exceeded)
                  CommonUI.buildPaymentToolTip(
                    context: context,
                    message: proposal?.paymentStatusStr,
                  )
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            proposal?.amount == null
                ? ''
                : '${WealthyAmount.currencyFormatWithoutTrailingZero(proposal?.amount, 2)}',
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.greenAccentColor,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
    return Responsive.ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: firstChild),
          Expanded(child: secondChild),
        ],
      ),
      replacement: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: SizeConfig().screenWidth! * 0.2, child: firstChild),
          SizedBox(width: SizeConfig().screenWidth! * 0.2),
          SizedBox(width: SizeConfig().screenWidth! * 0.2, child: secondChild),
        ],
      ),
    );
  }
}
