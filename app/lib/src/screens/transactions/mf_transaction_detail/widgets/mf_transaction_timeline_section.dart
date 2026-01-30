import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class MfTransactionTimelineSection extends StatelessWidget {
  final MfTransactionModel mfTransaction;

  const MfTransactionTimelineSection({super.key, required this.mfTransaction});

  @override
  Widget build(BuildContext context) {
    final timelineData =
        List<OrderStageAudit>.from(mfTransaction.orderStageAudit ?? []);
    if (mfTransaction.isFailure) {
      // For failure no stage will come from backened
      timelineData.add(
        OrderStageAudit(
          customerStageText:
              'Order Failed ${mfTransaction.failureReason.isNotNullOrEmpty ? '- ${mfTransaction.failureReason}' : ''}',
          stageLastUpdatedAt: mfTransaction.lastUpdatedAt,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
      ),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CommonUI.buildProfileDataSeperator(
              color: ColorConstants.borderColor2,
              height: 1,
            ),
          ),
          if (timelineData.isNullOrEmpty)
            EmptyScreen(message: 'No data found')
          else
            ...List<Widget>.generate(
              timelineData.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: _buildTimeline(
                    context: context,
                    date: getFormattedDate(
                      timelineData[index].stageLastUpdatedAt,
                    ),
                    status: timelineData[index].customerStageText ?? '-',
                    stepNo: index + 1,
                    isLastStep: index + 1 == timelineData.length,
                  ),
                );
              },
            ),
          if (timelineData.isNotNullOrEmpty) _buildStatusCard(context)
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final totalTransactions = 1;
    final totalCompletedTransactions =
        mfTransaction.schemeStatus == TransactionSchemeStatus.Success ? 1 : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Transaction Timeline',
              subtitle: totalTransactions.isNotNullOrZero
                  ? '$totalCompletedTransactions/$totalTransactions of your transaction is complete'
                  : '',
              titleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
            ),
          ),
          if (totalTransactions.isNotNullOrZero)
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AllImages().radialGradientIcon),
                ),
              ),
              child: Center(
                child: Text(
                  '$totalCompletedTransactions/$totalTransactions',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w500,
                          ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline({
    required BuildContext context,
    required int stepNo,
    required String status,
    required String? date,
    required bool isLastStep,
  }) {
    Color statusColor = ColorConstants.greenAccentColor;
    if (isLastStep) {
      if (mfTransaction.isFailure) {
        statusColor = ColorConstants.errorColor;
      } else if (mfTransaction.isNavAllocated || mfTransaction.isSuccess) {
        statusColor = ColorConstants.greenAccentColor;
      } else {
        statusColor = ColorConstants.yellowAccentColor;
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor,
                  width: 1,
                ),
                color: statusColor.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '$stepNo',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        color: statusColor,
                      ),
                ),
              ),
            ),
            if (!isLastStep)
              Container(
                width: 20,
                margin: EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: CommonUI.buildProfileDataSeperator(
                    height: 38,
                    width: 1,
                    color: statusColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${status.toTitleCase()}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          color: ColorConstants.black,
                        ),
              ),
              if (date.isNotNullOrEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    date!,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    String text = '';
    if (mfTransaction.isFailure) {
      text =
          "Of the transactions on Wealthy, more than 99.1% are successful. Regrettably, this particular transaction didn’t fall into that category.";
    } else if (mfTransaction.isNavAllocated && isInvestmentTransaction()) {
      text = "Another successful investment on Wealthy. Stay invested :)";
    }
    if (text.isNotNullOrEmpty) {
      return Container(
        margin: const EdgeInsets.only(left: 51, right: 30, top: 10),
        decoration: BoxDecoration(
          color: mfTransaction.isFailure
              ? ColorConstants.errorColor.withOpacity(0.2)
              : ColorConstants.greenAccentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(10),
        child: Text(
          text,
          style: context.titleMedium?.copyWith(
            color: ColorConstants.black,
          ),
        ),
      );
    }
    return SizedBox();
  }

  bool isInvestmentTransaction() {
    return ['Purchase', 'Sip'].any(
      (element) =>
          mfTransaction.transactionType?.toLowerCase() == element.toLowerCase(),
    );
  }
}
