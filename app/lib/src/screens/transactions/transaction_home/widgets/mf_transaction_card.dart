import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/status_chip.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class MfTransactionCard extends StatelessWidget {
  final MfTransactionModel transaction;
  late final TextStyle? largeTextStyle;
  late final TextStyle? smallTextStyle;
  final bool showClientDetails;
  final bool showSifTag;

  MfTransactionCard({
    super.key,
    required this.transaction,
    this.showClientDetails = true,
    this.showSifTag = false,
  });

  @override
  Widget build(BuildContext context) {
    largeTextStyle = context.headlineSmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: ColorConstants.black,
    );
    smallTextStyle = context.titleLarge?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );
    return InkWell(
      onTap: () {
        AutoRouter.of(context)
            .push(MfTransactionDetailRoute(mfTransaction: transaction));
        EventTracker.trackTransactionCardClicked(
          context: context,
          model: transaction,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorConstants.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: Logo and Title
            _buildLogoTitle(context),
            const SizedBox(height: 10),
            // Middle section: Client and Amount details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: showClientDetails
                      ? _buildClientDetails()
                      : _buildAmountStatusDetails(),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: showClientDetails
                      ? _buildAmountStatusDetails()
                      : _buildStatusDetail(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom section: Order details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: 'Order Type',
                    subtitle: mfTransactionTypeText(
                        transaction.transactionType ?? '-'),
                    titleStyle: smallTextStyle,
                    subtitleStyle: smallTextStyle?.copyWith(
                      color: ColorConstants.black,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: 'Source',
                    subtitle: transaction.source ?? '-',
                    titleStyle: smallTextStyle,
                    subtitleStyle: smallTextStyle?.copyWith(
                      color: ColorConstants.black,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CommonUI.buildColumnTextInfo(
                  title: 'Last Updated',
                  subtitle: transaction.formatLastUpdatedAt,
                  titleStyle: smallTextStyle,
                  subtitleStyle: smallTextStyle?.copyWith(
                    color: ColorConstants.black,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoTitle(BuildContext context) {
    final title = transaction.schemeName ?? transaction.goalName;
    final subtitle = transaction.goalName;

    return Row(
      children: [
        CachedNetworkImage(
          height: 40,
          width: 40,
          fit: BoxFit.contain,
          imageUrl:
              getAmcLogo(transaction.isSif == true ? title : transaction.amc),
          errorWidget: (context, url, error) {
            return CachedNetworkImage(
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              imageUrl: getAmcLogoNew(transaction.amc),
            );
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? '-',
                      style: largeTextStyle?.copyWith(
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (showSifTag) _buildSifTag(context),
                ],
              ),
              if (subtitle != null && subtitle != title)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    subtitle,
                    style: largeTextStyle?.copyWith(
                      color: ColorConstants.tertiaryBlack,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSifTag(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 6),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'SIF',
        style: context.titleSmall?.copyWith(
          color: Color(0xFF7C4DFF),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildClientDetails() {
    return CommonUI.buildColumnTextInfo(
      title: 'Client',
      subtitle: transaction.clientName ?? '-',
      titleStyle: smallTextStyle,
      subtitleStyle: largeTextStyle,
      gap: 4,
      optionalWidget: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'CRN ${transaction.crn ?? '-'}',
          style: smallTextStyle?.copyWith(color: ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }

  Widget _buildStatusDetail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: smallTextStyle),
        SizedBox(height: 4),
        StatusChip(
          label: TransactionCommon.getStatusLabel(transaction),
          statusColor: TransactionCommon.getStatusColor(transaction),
        ),
      ],
    );
  }

  Widget _buildAmountStatusDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: smallTextStyle),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(
            TextSpan(
              text: WealthyAmount.currencyFormat(
                transaction.amount,
                2,
                showSuffix: true,
              ),
              style: largeTextStyle?.copyWith(fontWeight: FontWeight.w500),
              children: [
                if (transaction.units.isNotNullOrZero)
                  TextSpan(
                    text:
                        ' ${transaction.units?.toStringAsFixed(2) ?? '-'} Units',
                    style: smallTextStyle,
                  ),
              ],
            ),
          ),
        ),
        if (showClientDetails)
          StatusChip(
            label: TransactionCommon.getStatusLabel(transaction),
            statusColor: TransactionCommon.getStatusColor(transaction),
          ),
      ],
    );
  }
}
