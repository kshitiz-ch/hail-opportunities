import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionBankDetail extends StatelessWidget {
  final MfTransactionModel mfTransaction;

  const TransactionBankDetail({super.key, required this.mfTransaction});

  @override
  Widget build(BuildContext context) {
    final data = [
      [
        'Account Number',
        mfTransaction.accountNumber ?? '-',
      ],
      [
        'IFSC',
        mfTransaction.ifscCode ?? '-',
      ],
      [
        // 'Account Type',
        'Bank Name',
        mfTransaction.bankName ?? '-'
        // 'Saving',
      ],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
              .copyWith(top: 24),
          child: Text(
            'Bank Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
            ),
          ),
          child: Row(
            children: List<Widget>.generate(
              data.length,
              (index) {
                int subtitleMaxLength = 1;
                Alignment alignment = Alignment.topLeft;
                if (index == 1) {
                  alignment = Alignment.topCenter;
                }
                if (index == 2) {
                  alignment = Alignment.topRight;
                  subtitleMaxLength = 2;
                }
                return _buildBankDetail(
                  context: context,
                  title: data[index].first,
                  subtitle: data[index].last,
                  alignment: alignment,
                  subtitleMaxLength: subtitleMaxLength,
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBankDetail({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Alignment alignment,
    required int subtitleMaxLength,
  }) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    return Expanded(
      child: Align(
        alignment: alignment,
        child: CommonUI.buildColumnTextInfo(
          title: title,
          subtitle: subtitle,
          subtitleMaxLength: subtitleMaxLength,
          titleStyle: style,
          subtitleStyle: style?.copyWith(
            color: ColorConstants.black,
          ),
        ),
      ),
    );
  }
}
