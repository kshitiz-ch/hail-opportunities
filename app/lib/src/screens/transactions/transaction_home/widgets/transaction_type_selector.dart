import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionController controller;

  const TransactionTypeSelector({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> transactionTypes = ['All'];

    final category = controller.selectedTabConfig.category;

    if (category == TransactionCategory.mutualFund) {
      // Add MF (Mutual Fund) transaction types
      var mfTypes = MFOrderTypeDisplay.values.map((type) {
        return type.name.length == 3
            ? type.name.toUpperCase() // Keep acronyms in uppercase
            : type.name
                .toCapitalized(); // Capitalize first letter for other types
      }).toList();

      // Filter transaction types if the current tab (e.g., SIF) has specific allowed types
      if (controller.selectedTabConfig.allowedTransactionTypes != null) {
        mfTypes = mfTypes
            .where((type) => controller
                .selectedTabConfig.allowedTransactionTypes!
                .contains(type))
            .toList();
      }

      transactionTypes.addAll(mfTypes);
    } else if (category == TransactionCategory.insurance) {
      // Add insurance transaction types
      transactionTypes.addAll([
        'Savings',
        'Health',
        'Term',
        'Other',
      ]);
    } else if (category == TransactionCategory.pms) {
      // Add PMS transaction types
      transactionTypes.addAll(['Deposit', 'Withdrawal']);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: transactionTypes.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ChoiceChip(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
                side: BorderSide(
                  color: controller.selectedTransactionType == type
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.borderColor,
                ),
              ),
              backgroundColor: Colors.white,
              label: Text(
                controller.selectedTabConfig.category ==
                        TransactionCategory.mutualFund
                    ? mfTransactionTypeText(type)
                    : type,
                style: context.headlineSmall?.copyWith(
                  color: controller.selectedTransactionType == type
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.black,
                ),
              ),
              selectedColor: Colors.white,
              selected: controller.selectedTransactionType == type,
              onSelected: (selected) {
                if (selected) {
                  controller.selectedTransactionType = type;
                  controller.scrollToTop = true;
                  controller.update();

                  EventTracker.trackTransactionsViewed(
                    controller: controller,
                    context: context,
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
