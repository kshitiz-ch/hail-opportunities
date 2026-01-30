import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';

class CreditProposalCard extends StatelessWidget {
  final ProposalModel? proposal;

  const CreditProposalCard({Key? key, required this.proposal})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (proposal == null) {
      return SizedBox();
    }
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          CreditCardProposalDetailRoute(
            externalID: proposal!.productExtrasJson?['credit_card_id'] ?? '',
            canProceed: proposal!.productExtrasJson?['can_proceed'] ?? true,
          ),
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
            _buildHeader(context),
            SizedBox(height: 20),
            _buildStatus(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: ColorConstants.borderColor),
            ),
            _buildClientInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // final logo = proposal.productExtrasJson['logo']?.toString();
    final creditCardName =
        proposal!.productExtrasJson?['credit_card_name']?.toString();
    String? lenderBankName =
        proposal!.productExtrasJson?['credit_card_lender']?.toString();
    final statusText =
        (proposal?.productExtrasJson?['status'] ?? proposal?.statusStr)
            ?.toString();
    // feedback from credilio team
    if (lenderBankName.isNullOrEmpty) {
      if ((statusText ?? '').toLowerCase() == 'card selected') {
        lenderBankName = 'Offer not selected';
      } else {
        lenderBankName = 'Card Not Selected';
      }
    }

    final createdDate = proposal!.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // TODO: update it from api logo field once logo is available for all store products
          // CircleAvatar(
          //   radius: 18,
          //   backgroundImage: AssetImage(
          //     getCreditCardBankIcon(lenderBankName),
          //   ),
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CommonUI.buildColumnTextInfo(
                title: getFormattedText(lenderBankName),
                subtitle:
                    getFormattedText(creditCardName, showDefaultText: true),
                titleStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                gap: 4,
              ),
            ),
          ),
          CommonUI.buildColumnTextInfo(
            title: 'Created On',
            subtitle: getFormattedDate(createdDate),
            titleStyle: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
            subtitleStyle:
                Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black,
                    ),
            gap: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            proposal?.status == ProposalStatus.COMPLETED
                ? AllImages().proposalCompletedIcon
                : AllImages().proposalPendingIcon,
            height: 20,
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CommonUI.buildColumnTextInfo(
                title: getFormattedText(
                    proposal?.productExtrasJson?['status'] ??
                        proposal?.statusStr),
                subtitle: getFormattedText(
                    proposal?.productExtrasJson?['sub_status'],
                    showDefaultText: true),
                titleStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                gap: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  normaliseName(proposal?.customer?.name ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                // SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        callNumber(number: proposal?.customer?.phoneNumber);
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
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
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
                        copyData(data: proposal?.customer?.phoneNumber);
                      },
                      icon: Icon(
                        Icons.copy,
                        size: 12,
                        color: ColorConstants.primaryAppColor,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CommonUI.buildColumnTextInfo(
                title: 'Bureau Score',
                subtitle: getBureauText(
                    proposal?.productExtrasJson?['bureau_profile']),
                titleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.tertiaryBlack,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.greenAccentColor,
                        ),
                gap: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
