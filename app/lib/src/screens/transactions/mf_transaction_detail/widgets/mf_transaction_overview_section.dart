import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class MfTransactionOverviewSection extends StatelessWidget {
  final MfTransactionModel mfTransaction;

  const MfTransactionOverviewSection({super.key, required this.mfTransaction});

  @override
  Widget build(BuildContext context) {
    final partnerName = '-';
    // mfOrderTransactionModel.agentName ?? '-';

    final data = [
      {
        'Order ID': mfTransaction.orderPrn ?? '-',
        'Order Type':
            mfTransactionTypeText(mfTransaction.transactionType ?? '-'),
      },
      {
        // getTransactionOrderTypeText(mfOrderTransactionModel.orderType),
        // 'Partner Details': partnerName,
        'Portfolio/Fund(s)': mfTransaction.goalName ?? '-',
        'Source': mfTransaction.source ?? '-',
      },
      {
        'Status': TransactionCommon.getStatusLabel(mfTransaction),
        'Amount': WealthyAmount.currencyFormat(mfTransaction.amount, 0),
      },
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(
          data.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            child: _buildRowData(
              data[index],
              context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowData(Map<String, String> data, BuildContext context) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
          overflow: TextOverflow.ellipsis,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              overflow: TextOverflow.ellipsis,
            );
    Color statusColor = ColorConstants.greenAccentColor;

    return Row(
      children: List<Widget>.generate(
        data.entries.length,
        (index) {
          if (data.entries.elementAt(index).key == 'Status') {
            if (mfTransaction.schemeStatus == TransactionSchemeStatus.Failure) {
              statusColor = ColorConstants.errorColor;
            } else if (mfTransaction.schemeStatus ==
                TransactionSchemeStatus.Success) {
              statusColor = ColorConstants.greenAccentColor;
            } else {
              statusColor = ColorConstants.yellowAccentColor;
            }
          }
          final isPortfolioField =
              data.entries.elementAt(index).key.contains('Portfolio');
          final isOrderIdField =
              data.entries.elementAt(index).key.contains('Order ID');
          return Expanded(
            flex: index == 0 ? 2 : 1,
            child: Container(
              margin: EdgeInsets.only(right: 5),
              child: CommonUI.buildColumnTextInfo(
                title: data.entries.elementAt(index).key,
                subtitle: data.entries.elementAt(index).value,
                titleStyle: titleStyle,
                useMarqueeWidget: isOrderIdField,
                subtitleMaxLength: isPortfolioField ? 2 : 1,
                subtitleStyle: subtitleStyle?.copyWith(
                  color: data.entries.elementAt(index).key == 'Status'
                      ? statusColor
                      : ColorConstants.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
