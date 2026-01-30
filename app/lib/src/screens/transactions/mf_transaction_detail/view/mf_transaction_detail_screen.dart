import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/screens/transactions/mf_transaction_detail/widgets/mf_transaction_fund_section.dart';
import 'package:app/src/screens/transactions/mf_transaction_detail/widgets/mf_transaction_overview_section.dart';
import 'package:app/src/screens/transactions/mf_transaction_detail/widgets/mf_transaction_timeline_section.dart';
import 'package:app/src/screens/transactions/mf_transaction_detail/widgets/transaction_bank_detail.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MfTransactionDetailScreen extends StatelessWidget {
  final MfTransactionModel mfTransaction;

  const MfTransactionDetailScreen({super.key, required this.mfTransaction});

  @override
  Widget build(BuildContext context) {
    final clientName = mfTransaction.clientName;
    final crn = 'CRN : ${mfTransaction.crn}';

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: clientName,
        subtitleText: crn,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MfTransactionOverviewSection(mfTransaction: mfTransaction),
            MfTransactionTimelineSection(mfTransaction: mfTransaction),
            TransactionBankDetail(mfTransaction: mfTransaction),
            MfTransactionFundSection(mfTransaction: mfTransaction),
          ],
        ),
      ),
    );
  }
}
