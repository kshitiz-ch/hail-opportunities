import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/custom_date_picker_bottomsheet.dart';
import 'package:app/src/utils/date_range_utils.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionCommon {
  static Widget buildStatusSection({
    required BuildContext context,
    int? transactionOrderStatus,
    String? transactionSchemeStatus,
    String? transactionOrderStatusDisplay,
    String? transactionSchemeStatusDisplay,
    required String? failureReason,
    required DateTime? lastUpdatedAt,
  }) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.tertiaryBlack,
          overflow: TextOverflow.ellipsis,
        );

    String getStatusDisplay(String? statusDisplay) {
      if (statusDisplay == null) return '-';
      try {
        RegExp regex = RegExp(r"(?=[A-Z])");

        return statusDisplay.split(regex).join(" ");
      } catch (error) {
        return '-';
      }
    }

    Widget _buildStatus() {
      String statusIcon = '';
      if (transactionOrderStatus == TransactionOrderStatus.Failure ||
          transactionSchemeStatus == TransactionSchemeStatus.Failure) {
        statusIcon = AllImages().unverifiedIcon;
      } else if (transactionOrderStatus ==
              TransactionOrderStatus.NavAllocated ||
          transactionSchemeStatus == TransactionSchemeStatus.Success) {
        statusIcon = AllImages().verifiedIcon;
      } else {
        statusIcon = AllImages().proposalPendingIcon;
      }
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorConstants.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(statusIcon, height: 16, width: 16),
            SizedBox(width: 6),
            MarqueeWidget(
              child: Text(
                (transactionOrderStatus != null ||
                        transactionOrderStatusDisplay != null)
                    ? getStatusDisplay(transactionOrderStatusDisplay)
                    : getStatusDisplay(transactionSchemeStatusDisplay),
                style: style?.copyWith(
                  color: ColorConstants.black,
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget _buildStatusDescription() {
      if ((transactionOrderStatus == TransactionOrderStatus.Failure ||
              transactionSchemeStatus == TransactionSchemeStatus.Failure) &&
          failureReason.isNotNullOrEmpty) {
        return Align(
          alignment: Alignment.topLeft,
          child: Text.rich(
            TextSpan(
              text: failureReason,
              style: style,
            ),
          ),
        );
      }
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20)
          .copyWith(bottom: 24, top: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatus(),
                _buildStatusDescription(),
              ],
            ),
          ),
          SizedBox(width: 20),
          if (lastUpdatedAt != null)
            Expanded(
              child: Text(
                getFormattedDate(lastUpdatedAt),
                style: style?.copyWith(
                  color: ColorConstants.black,
                ),
              ),
            )
        ],
      ),
    );
  }

  static String getStatusLabel(MfTransactionModel transaction) {
    if (transaction.isNavAllocated) {
      return 'NAV Allocated';
    } else if (transaction.isSuccess) {
      return 'Success';
    } else if (transaction.isFailure) {
      return 'Failure';
    } else if (transaction.isProgress) {
      return 'In Progress';
    } else {
      return 'Not Available';
    }
  }

  static String getAggregatedStatusLabel(String status, bool isMfTabActive) {
    String label = 'All';
    switch (status) {
      case 'All':
        label = 'All';
        break;
      case 'S':
      case TransactionOrderStatus.RevenueRelease:
        label = isMfTabActive ? 'Success' : 'Revenue Released';
        break;
      case 'P':
      case TransactionOrderStatus.Create:
        label = isMfTabActive ? 'In-Progress' : 'Created';
        break;
      case 'F':
      case TransactionOrderStatus.Fail:
        label = 'Failed';
        break;
      case 'A':
      case TransactionOrderStatus.Active:
        label = 'Active';
        break;
      case 'verified':
        label = 'Verified';
        break;
      default:
        break;
    }
    return label;
  }

  static Color getStatusColor(MfTransactionModel transaction) {
    if (transaction.isNavAllocated) {
      return ColorConstants.greenAccentColor;
    } else if (transaction.isSuccess) {
      return ColorConstants.greenAccentColor;
    } else if (transaction.isFailure) {
      return ColorConstants.redAccentColor;
    } else if (transaction.isProgress) {
      return ColorConstants.yellowAccentColor;
    } else {
      return ColorConstants.yellowAccentColor;
    }
  }

  static void onSortOptionSelect(
    String option,
    BuildContext context,
    TransactionController controller,
  ) {
    controller.selectedSortOption = option;
    controller.sortTransactions(controller.mfTransactionList);
    controller.sortTransactions(controller.insuranceTransactionList);
    controller.sortTransactions(controller.pmsTransactionList);
    AutoRouter.of(context).popUntilRouteWithName(
      controller.screenContext.isSipBookView
          ? SipBookRoute.name
          : TransactionsRoute.name,
    );
    controller.update();
  }

  /// Handles the selection of time filter options for transactions
  ///
  /// This method processes three types of time selections:
  /// 1. Custom Range - Opens a date picker for user-defined range
  /// 2. All Time - Clears date filters
  /// 3. Predefined ranges (e.g., Last 7 days, Last month) - Calculated automatically
  ///
  /// [option] The selected time filter option
  /// [context] The build context for navigation and UI updates
  static Future<void> onTimeOptionSelect(
    String option,
    BuildContext context,
    TransactionController controller,
  ) async {
    // Update the selected time option in the controller
    controller.selectedTimeOption = option;

    switch (option) {
      case 'Custom Range':
        // Show date picker bottom sheet for custom date range selection
        await CommonUI.showBottomSheet(
          context,
          child: CustomDatePickerBottomsheet(
            initialStartDate: controller.fromDate,
            initialEndDate: controller.toDate,
            onContinue: ({
              required DateTime endDate,
              required DateTime startDate,
            }) {
              controller.fromDate = startDate;
              controller.toDate = endDate;
            },
          ),
          isScrollControlled: false,
        );
        break;

      case 'All Time':
        // Clear date filters for showing all transactions
        controller.fromDate = null;
        controller.toDate = null;
        break;

      default:
        // Handle predefined date ranges (e.g., Last 7 days, Last month)
        final dates = DateRangeUtils.calculateDateRange(option);
        controller.fromDate = dates.$1;
        controller.toDate = dates.$2;
        break;
    }

    // Notify UI about the changes
    controller.update();

    // Refresh transaction data based on active tab
    if (controller.isMfTabActive || controller.isPmsTabActive) {
      controller.getTransactions();
    } else {
      // API call not required as date range filter is in frontend
      controller.getInsuranceTransactionAggregatesList();
    }

    // Navigate back to the main transactions screen
    AutoRouter.of(context).popUntilRouteWithName(
      controller.screenContext.isSipBookView
          ? SipBookRoute.name
          : TransactionsRoute.name,
    );
  }
}
