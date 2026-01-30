import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class MfTransactionFundSection extends StatelessWidget {
  final MfTransactionModel mfTransaction;

  const MfTransactionFundSection({super.key, required this.mfTransaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
              .copyWith(top: 24),
          child: Text(
            'Fund',
            style: context.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.tertiaryBlack,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFundCard(context),
        )
      ],
    );
  }

  Widget _buildFundCard(BuildContext context) {
    final label = TransactionCommon.getStatusLabel(mfTransaction);
    final statusColor = TransactionCommon.getStatusColor(mfTransaction);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              mfTransaction.schemeName ?? mfTransaction.goalName ?? '-',
              style: context.headlineMedium?.copyWith(
                color: ColorConstants.black,
              ),
            ),
          ),
          CommonUI.buildProfileDataSeperator(
            color: ColorConstants.borderColor,
            height: 1,
            width: double.infinity,
          ),
          _buildFundDetail(context),
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          //   child: StatusChip(
          //     label: label,
          //     textColor: statusColor,
          //     backgroundColor: statusColor.withOpacity(0.1),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildFundDetail(BuildContext context) {
    final navDisplay = mfTransaction.nav ?? '-';

    final unitNav =
        '${(mfTransaction.units ?? 0).toStringAsFixed(2)} @ $navDisplay';
    final amount = WealthyAmount.currencyFormat(mfTransaction.amount, 0);
    final type = mfTransactionTypeText(mfTransaction.transactionType ?? '-');
    // if ((order.transactionTypeDisplay ?? '').toLowerCase() == "switch") {
    //   type = schemeModel.category == 1 ? "Switch Out" : "Switch In";
    // } else {
    //   type = schemeModel.transactionTypeDisplay ?? '-';
    // }

    final data = [
      [unitNav, 'Units @ Nav'],
      [type, 'Type'],
      [amount, 'Amount'],
    ];
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
            );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data
            .map<Widget>(
              (dataItem) => CommonUI.buildColumnTextInfo(
                title: dataItem.first,
                subtitle: dataItem.last,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                gap: 5,
              ),
            )
            .toList(),
      ),
    );
  }
}
