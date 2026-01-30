import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_sort_filter_bottomsheet.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class TransactionFilterSortSection extends StatelessWidget {
  final TransactionController controller;

  const TransactionFilterSortSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async {
            await CommonUI.showBottomSheet(
              context,
              isScrollControlled: false,
              child: TransactionSortFilterBottomsheet(
                options: controller.timeOptions,
                selectedOption: controller.selectedTimeOption,
                onOptionSelected: (String option) async {
                  await TransactionCommon.onTimeOptionSelect(
                    option,
                    context,
                    controller,
                  );
                  EventTracker.trackTransactionsViewed(
                    controller: controller,
                    context: context,
                  );
                },
                title: 'View Transactions by',
              ),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  getTimelabel(),
                  style: context.headlineSmall?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_sharp,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ],
          ),
        ),
        if (controller.screenContext != TransactionScreenContext.sipBook)
          InkWell(
            onTap: () {
              CommonUI.showBottomSheet(
                context,
                isScrollControlled: false,
                child: TransactionSortFilterBottomsheet(
                  options: controller.sortOptions,
                  selectedOption: controller.selectedSortOption,
                  onOptionSelected: (String option) {
                    TransactionCommon.onSortOptionSelect(
                      option,
                      context,
                      controller,
                    );
                    EventTracker.trackTransactionsViewed(
                      controller: controller,
                      context: context,
                    );
                  },
                  title: 'Sort by',
                ),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  AllImages().swapIcon,
                  height: 16,
                  width: 16,
                  color: ColorConstants.primaryAppColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'By ${controller.selectedSortOption}',
                    style: context.headlineSmall?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String getTimelabel() {
    if (controller.selectedTimeOption == 'Custom Range') {
      return '${getFormattedDate(controller.fromDate)} - ${getFormattedDate(controller.toDate)}';
    }
    return controller.selectedTimeOption;
  }
}
