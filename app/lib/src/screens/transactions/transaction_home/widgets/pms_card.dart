import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/status_chip.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/transaction/models/pms_transaction_model.dart';
import 'package:flutter/material.dart';

class PmsCard extends StatelessWidget {
  final PmsTransactionModel transaction;
  late final TextStyle? largeTextStyle;
  late final TextStyle? smallTextStyle;
  final bool showClientDetails;

  PmsCard({
    super.key,
    required this.transaction,
    this.showClientDetails = true,
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
    return Container(
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
          CommonUI.buildColumnTextInfo(
            title: transaction.pmsName ?? '-',
            subtitle: '${transaction.manufacturer ?? '-'}',
            titleStyle: largeTextStyle?.copyWith(
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
            subtitleStyle: largeTextStyle?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
            gap: 4,
          ),
          const SizedBox(height: 10),
          // Middle section: Client and Amount details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: showClientDetails
                    ? _buildClientDetails()
                    : _buildAmountDetails(),
              ),
              SizedBox(width: 10),
              Expanded(
                child: showClientDetails
                    ? _buildAmountDetails()
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
                  subtitle: transaction.transactionType,
                  titleStyle: smallTextStyle,
                  subtitleStyle:
                      smallTextStyle?.copyWith(color: ColorConstants.black),
                ),
              ),
              SizedBox(width: 10),
              showClientDetails
                  ? Expanded(child: _buildStatusDetail())
                  : SizedBox.shrink(),
              showClientDetails ? SizedBox(width: 10) : SizedBox.shrink(),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'Date',
                  subtitle: getFormattedDate(transaction.trnxDate),
                  titleStyle: smallTextStyle,
                  subtitleStyle: smallTextStyle?.copyWith(
                    color: ColorConstants.black,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetails() {
    return CommonUI.buildColumnTextInfo(
      title: 'Client',
      subtitle: transaction.userName ?? '-',
      titleStyle: smallTextStyle,
      subtitleStyle: largeTextStyle,
      gap: 4,
      optionalWidget: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Email: ${transaction.userEmail ?? '-'}',
          style: smallTextStyle?.copyWith(color: ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }

  Widget _buildStatusDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: smallTextStyle),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: StatusChip(
            label: (transaction.status ?? '-').toTitleCase(),
            statusColor: ColorConstants.primaryAppColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDetails() {
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
            ),
          ),
        ),
      ],
    );
  }
}
