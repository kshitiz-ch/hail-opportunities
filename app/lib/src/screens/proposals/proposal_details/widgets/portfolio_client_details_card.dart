import 'dart:math';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart' as enums;
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class PortfolioClientDetailsCard extends StatelessWidget {
  // Fields
  final ProposalModel? proposal;

  // Constructor
  const PortfolioClientDetailsCard({
    Key? key,
    required this.proposal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final investmentType = proposal?.productExtrasJson?['order_type'] != null
        ? getInvestmentTypeFromString(
            proposal?.productExtrasJson!['order_type'],
          )
        : null;

    String? sipDate;
    if (investmentType == enums.InvestmentType.SIP &&
        proposal?.productExtrasJson!['sip'] != null &&
        proposal?.productExtrasJson!['sip']['sip_day'] != null) {
      try {
        sipDate =
            getOrdinalNumber(proposal?.productExtrasJson!['sip']['sip_day']);
      } catch (error) {
        LogUtil.printLog(error);
      }
    }

    final amountText = proposal?.amount == null
        ? ''
        : proposal?.isWealthcaseProposal == true
            ? WealthyAmount.currencyFormatWithoutTrailingZero(
                proposal?.amount?.round(), 0)
            : WealthyAmount.currencyFormatWithoutTrailingZero(
                proposal?.amount, 2);

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16)
          .copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientInfo(
            firstChild: Text(
              proposal?.customer?.name ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(
                      color: ColorConstants.black, fontWeight: FontWeight.w500),
            ),
            secondChild: proposal?.createdAt != null
                ? Text(
                    'Sent on ${DateFormat('dd MMM yyyy').format(proposal!.createdAt!)}',
                    textAlign: TextAlign.right,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  )
                : Text(''),
          ),
          if (proposal?.ppStatusStr != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  _buildStatusIcon(),
                  const SizedBox(width: 6),
                  Text(
                    proposal!.ppStatusStr!.toUpperCase(),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleMedium!
                        .copyWith(
                          color: _getStatusColor(),
                        ),
                  )
                ],
              ),
            ),
          _buildProposalStatus(context),
          if ((proposal?.isDematProposal ?? false) ||
              (proposal?.isSwitchTrackerProposal ?? false))
            SizedBox()
          else
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: _buildClientInfo(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUI.buildColumnTextInfo(
                      title: 'Amount',
                      subtitle: '$amountText',
                      titleStyle: context.titleLarge!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                      subtitleStyle: context.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sipDate.isNotNullOrEmpty)
                      Text(
                        'SIP Day: $sipDate',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: LayoutBuilder(builder: (context, size) {
                    final span = TextSpan(
                      text: proposal?.paymentStatusStr,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: (proposal?.paymentStatusStr ?? '')
                                  .isNotNullOrEmpty
                              ? CommonUI.buildColumnTextInfo(
                                  title: 'Payment Status',
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  subtitleMaxLength: 2,
                                  subtitle: '${proposal?.paymentStatusStr}',
                                  titleStyle: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: ColorConstants.tertiaryBlack,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  subtitleStyle: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: ColorConstants.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                )
                              : SizedBox(),
                        ),
                        if (exceeded)
                          CommonUI.buildPaymentToolTip(
                            context: context,
                            message: proposal!.paymentStatusStr,
                          )
                      ],
                    );
                  }),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 16),
            child: Divider(
              thickness: 0.2,
              color: ColorConstants.darkGrey,
            ),
          ),
          if (proposal?.customer?.phoneNumber.isNotNullOrEmpty ?? false)
            _buildClientInfo(
              firstChild: _buildContactInfo(
                context: context,
                text: 'Call Now ',
                imagePath: AllImages().callIcon,
                onTap: () async {
                  MixPanelAnalytics.trackWithAgentId(
                    "call_now",
                    screen: 'proposal_details',
                    screenLocation: 'proposal_details',
                  );
                  if ((proposal?.customer?.phoneNumber.isNotNullOrEmpty ??
                      false)) {
                    await launch("tel://${proposal!.customer!.phoneNumber}");
                  } else {
                    showToast(
                        text:
                            'Client phone number not available for this proposal');
                  }
                },
              ),
              secondChild: _buildContactInfo(
                context: context,
                text: 'WhatsApp',
                imagePath: AllImages().whatsappIconNew,
                onTap: () async {
                  MixPanelAnalytics.trackWithAgentId(
                    "whatsapp",
                    screen: 'proposal_details',
                    screenLocation: 'proposal_details',
                  );

                  if ((proposal?.customer?.phoneNumber.isNotNullOrEmpty ??
                      false)) {
                    final link = WhatsAppUnilink(
                      phoneNumber: proposal!.customer!.phoneNumber,
                      text: "Hey! ${proposal!.customer!.name}.",
                    );

                    await launch('$link');
                  } else {
                    showToast(
                        text:
                            'Client phone number not available for this proposal');
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProposalStatus(BuildContext context) {
    if (proposal!.statusStr.isNullOrEmpty) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: ColorConstants.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          width: 0.5,
          color: ColorConstants.lightGrey,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (proposal?.isFailed == true)
            Icon(
              Icons.close,
              color: ColorConstants.redAccentColor,
            )
          else
            Image.asset(
              proposal?.isCompleted == true
                  ? AllImages().proposalCompletedIcon
                  : AllImages().proposalPendingIcon,
              height: 20,
              width: 20,
            ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                proposal!.statusStr!,
                maxLines: 2,
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: ColorConstants.black,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo({
    required Widget firstChild,
    required Widget secondChild,
  }) {
    return Responsive.ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ],
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: firstChild),
            Expanded(child: secondChild)
          ]),
      replacement: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: firstChild,
            width: SizeConfig().screenWidth! * 0.45,
          ),
          SizedBox(
            child: secondChild,
            width: SizeConfig().screenWidth! * 0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required String text,
    required String imagePath,
    required BuildContext context,
    Function? onTap,
  }) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: 24,
            width: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              text,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.black,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (proposal?.isFailed == true) {
      return Transform.rotate(
        angle: pi,
        child: Icon(
          Icons.close,
          color: ColorConstants.redAccentColor,
        ),
      );
    }

    if (proposal?.isCompleted == true) {
      return Icon(
        Icons.check_circle_outline,
        color: ColorConstants.greenAccentColor,
      );
    }

    return Icon(
      Icons.access_time,
      color: ColorConstants.darkGrey,
    );
  }

  Color _getStatusColor() {
    if (proposal?.isFailed == true) {
      return ColorConstants.redAccentColor;
    }

    if (proposal?.isCompleted == true) {
      return ColorConstants.greenAccentColor;
    }

    return ColorConstants.darkGrey;
  }
}
