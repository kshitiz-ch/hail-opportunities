import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_filter_sort_section.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_list.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_tabs.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      init: TransactionController(
          screenContext: TransactionScreenContext.general),
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              if (controller.searchController.text.isNotEmpty) {
                final _keyboardVisible =
                    MediaQuery.of(context).viewInsets.bottom != 0;
                if (_keyboardVisible) {
                  FocusManager.instance.primaryFocus?.unfocus();
                } else {
                  controller.searchController.clear();
                  controller.onSearchChanged();
                }
                return;
              }
              return AutoRouter.of(context).popForced();
            });
          },
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: CustomAppBar(
              titleText: 'Transactions',
              trailingWidgets: [
                PartnerOfficeDropdown(
                  tag: 'transactions',
                  title: controller.selectedTab,
                  onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                    controller
                        .updatePartnerEmployeeSelected(partnerOfficeModel);
                    EventTracker.trackTransactionsViewed(
                      controller: controller,
                      context: context,
                    );
                  },
                  canSelectAllEmployees: true,
                  canSelectPartnerOffice: true,
                ),
              ],
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TransactionFilterSortSection(controller: controller),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TransactionTabs(),
                ),
                Expanded(child: TransactionList()),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
