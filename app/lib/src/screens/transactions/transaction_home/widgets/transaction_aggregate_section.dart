import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/transaction/models/transaction_aggregate_model.dart';
import 'package:flutter/material.dart';

class TransactionAggregateSection extends StatelessWidget {
  final TransactionController controller;
  final TransactionAggregate? selectedAggregate;

  TransactionAggregateSection({
    Key? key,
    required this.controller,
    required this.selectedAggregate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedAggregate == null) return SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAggregateCard(
            context: context,
            count: selectedAggregate!.totalCount,
            amount: selectedAggregate!.totalAmount,
            status: 'All',
          ),
          _buildAggregateCard(
            context: context,
            count: selectedAggregate!.successCount,
            amount: selectedAggregate!.successAmount,
            status: _getStatus('success'),
          ),
          _buildAggregateCard(
            context: context,
            count: selectedAggregate!.activeCount,
            amount: selectedAggregate!.activeAmount,
            status: _getStatus('active'),
          ),
          _buildAggregateCard(
            context: context,
            count: selectedAggregate!.failureCount,
            amount: selectedAggregate!.failureAmount,
            status: _getStatus('failure'),
          ),
          _buildAggregateCard(
            context: context,
            count: selectedAggregate!.progressCount,
            amount: selectedAggregate!.progressAmount,
            status: _getStatus('progress'),
          ),
        ],
      ),
    );
  }

  String _getStatus(String type) {
    if (controller.isMfTabActive) {
      switch (type) {
        case 'success':
          return 'S';
        case 'failure':
          return 'F';
        case 'progress':
          return 'P';
        default:
          return '';
      }
    } else if (controller.isPmsTabActive) {
      switch (type) {
        case 'success':
          return 'verified';
        default:
          return '';
      }
    } else {
      switch (type) {
        case 'success':
          return TransactionOrderStatus.RevenueRelease;
        case 'active':
          return TransactionOrderStatus.Active;
        case 'failure':
          return TransactionOrderStatus.Fail;
        case 'progress':
          return TransactionOrderStatus.Create;
        default:
          return '';
      }
    }
  }

  Widget _buildAggregateCard({
    required BuildContext context,
    required String status,
    required int count,
    required double amount,
  }) {
    if (status.isNullOrBlank) return SizedBox();

    final isSelected = controller.selectedTransactionStatus == status;
    final label = TransactionCommon.getAggregatedStatusLabel(
      status,
      controller.isMfTabActive,
    );
    final isFailed = status.toLowerCase().startsWith('f');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          _onTap(status);
          EventTracker.trackTransactionsViewed(
            controller: controller,
            context: context,
          );
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isFailed ? Color(0xffFFFDFD) : Color(0xffF6FAFF),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: ColorConstants.primaryAppColor)
                : isFailed
                    ? Border.all(
                        color: ColorConstants.errorTextColor.withOpacity(0.2))
                    : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  text: '$label ',
                  style: context.headlineSmall
                      ?.copyWith(color: ColorConstants.tertiaryBlack),
                  children: [
                    TextSpan(
                      text: count.toString(),
                      style: context.headlineSmall?.copyWith(
                        color: status == 'F'
                            ? ColorConstants.errorColor
                            : ColorConstants.black,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 6),
              Text(
                WealthyAmount.currencyFormat(amount, 2, showSuffix: true),
                style: context.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(String status) {
    if (status != controller.selectedTransactionStatus) {
      controller.selectedTransactionStatus = status;
      controller.scrollToTop = true;
      controller.update();
    }
  }
}
