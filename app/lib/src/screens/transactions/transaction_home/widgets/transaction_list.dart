import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/controllers/store/insurance/insurance_policy_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/insurance_card.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/mf_transaction_card.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/pms_card.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_aggregate_section.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_search_bar.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_type_selector.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/transaction/models/insurance_transaction_model.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:core/modules/transaction/models/pms_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const insurancePolicyDownloadTag = 'insurance-policy';

class TransactionList extends StatelessWidget {
  final bool showClientDetails;
  TransactionList({
    Key? key,
    this.showClientDetails = true,
  }) : super(key: key) {
    // Initialise insurance policy controller
    Get.put<InsurancePolicyController>(InsurancePolicyController());
    // Initialise insurance policy download controller
    Get.put<DownloadController>(
      DownloadController(
        shouldOpenDownloadBottomSheet: true,
        authorizationRequired: true,
      ),
      tag: insurancePolicyDownloadTag,
    );
  }
  @override
  Widget build(BuildContext context) {
    // This widget builds the main list of transactions.
    // It handles loading, error states, and delegates to helper methods
    // for rendering the actual content based on the transaction data.
    return GetBuilder<TransactionController>(
      initState: (_) {
        final controller = Get.find<TransactionController>();
        EventTracker.trackTransactionsViewed(
          controller: controller,
          context: context,
        );
      },
      builder: (controller) {
        if (controller.transactionResponse.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.transactionResponse.isError) {
          return Center(
            child: RetryWidget(
              'Error: ${controller.transactionResponse.message}',
              onPressed: () {
                controller.getTransactions();
              },
            ),
          );
        }

        // Determine list to show based on selected tab's category
        final category = controller.selectedTabConfig.category;
        final initialTransactionList =
            category == TransactionCategory.mutualFund
                ? controller.mfTransactionList
                : category == TransactionCategory.pms
                    ? controller.pmsTransactionList
                    : controller.insuranceTransactionList;

        if (initialTransactionList.isEmpty) {
          return _buildEmptyScreen(
              'No transactions found for the selected date range');
        }

        return _buildTransactionContent(
          context,
          controller,
          initialTransactionList,
        );
      },
    );
  }

  // Builds the core content of the transaction list once loading/error states are handled.
  // It determines which transactions to display (MF or Insurance) and then
  // conditionally renders UI elements like type selectors, aggregate summaries, and the list itself.
  Widget _buildTransactionContent(
    BuildContext context,
    TransactionController controller,
    List<dynamic> initialTransactionList,
  ) {
    final screenContext = controller.screenContext;

    // Determines the selected aggregate data based on the current transaction type.
    // This is used to display summary information (e.g., total count) for the selected type.
    final selectedAggregate = screenContext.showAggregateSection
        ? controller.transactionAggregates.firstWhereOrNull((aggregate) =>
            aggregate.transactionType.toLowerCase() ==
            controller.selectedTransactionType.toLowerCase())
        : null;

    // Checks if there are any transactions to display for the currently selected type or overall.
    // If the context is general or sipBook, it checks the count from `selectedAggregate`.
    // Otherwise, it checks if the `initialTransactionList` is empty.
    final isTotalZeroTransaction = screenContext.showAggregateSection
        ? (selectedAggregate?.totalCount ?? 0).isNullOrZero
        : initialTransactionList.isNullOrEmpty;

    // Determines the final list of transactions to be rendered.
    // If the context is general or sipBook (which have filtering capabilities)
    // and there are transactions (`!isTotalZeroTransaction`), it uses the `controller.filteredTransactionList`.
    // Otherwise (e.g., for portfolioView), it defaults to the `initialTransactionList`.
    final filteredTransactionList = screenContext.showAggregateSection
        ? isTotalZeroTransaction
            ? []
            : controller.filteredTransactionList
        : initialTransactionList;

    // Scroll to top if the list changes
    controller.scrollTransactionListToTop();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (screenContext.isTransactionView)
          TransactionTypeSelector(controller: controller),
        if (isTotalZeroTransaction)
          Expanded(
            child: _buildEmptyScreen(
              'No ${mfTransactionTypeText(controller.selectedTransactionType)} transactions found for the selected date range',
            ),
          )
        else ...[
          if (screenContext.showAggregateSection)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TransactionAggregateSection(
                controller: controller,
                selectedAggregate: selectedAggregate,
              ),
            ),
          if (screenContext.isTransactionView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TransactionSearchBar(),
            ),
          SizedBox(height: 10),
          Expanded(
            child: _buildTransactionListView(
              filteredTransactionList,
              controller,
            ),
          ),
        ],
      ],
    );
  }

  // Builds the actual list of transactions using ListView.separated.
  // It displays either an MfTransactionCard or an InsuranceCard based on the active tab.
  // If the `filteredTransactionList` is empty, it shows an empty screen.
  Widget _buildTransactionListView(
    List<dynamic> filteredTransactionList,
    TransactionController controller,
  ) {
    if (filteredTransactionList.isNullOrEmpty) {
      final searchText = controller.searchController.text;
      final transactionType = controller.selectedTransactionType;
      final transactionStatusLabel = TransactionCommon.getAggregatedStatusLabel(
        controller.selectedTransactionStatus,
        controller.selectedTabConfig.category == TransactionCategory.mutualFund,
      );
      final msg = searchText.isNotEmpty
          ? 'No transactions match your search for the selected date range'
          : 'No $transactionStatusLabel transactions found for the selected date range';

      return _buildEmptyScreen(msg);
    }
    return ListView.separated(
      controller: controller.transactionListScrollController,
      padding: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
      itemCount: filteredTransactionList.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final transaction = filteredTransactionList[index];
        final category = controller.selectedTabConfig.category;
        return category == TransactionCategory.mutualFund
            ? MfTransactionCard(
                showClientDetails: showClientDetails,
                transaction: transaction as MfTransactionModel,
                showSifTag: controller.screenContext.isSipBookView &&
                    transaction.isSif == true,
              )
            : category == TransactionCategory.pms
                ? PmsCard(
                    transaction: transaction as PmsTransactionModel,
                    showClientDetails: showClientDetails,
                  )
                : InsuranceCard(
                    transaction: transaction as InsuranceTransactionModel,
                    showClientDetails: showClientDetails,
                  );
      },
    );
  }

  Widget _buildEmptyScreen(String message) {
    // This widget is used in multiple places, so it's good to have it as a helper.
    // If 'No transactions found' is always the message, consider making EmptyScreen const
    // if its constructor allows and the message is passed as a const String.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: EmptyScreen(message: message),
      ),
    );
  }
}
