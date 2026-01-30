import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_book_tabs.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_list.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_summary_view.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SipBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      init: SipBookController(),
      dispose: (_) {
        Get.delete<TransactionController>();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'SIP Book',
            trailingWidgets: [
              PartnerOfficeDropdown(
                tag: 'Sip-Book',
                title: 'SIP Book',
                onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                  MixPanelAnalytics.trackWithAgentId(
                    "employee_filter",
                    screen: 'sip_book',
                    screenLocation: 'sip_book',
                  );
                  controller.updatePartnerEmployeeSelected(partnerOfficeModel);
                  if (controller.selectedSipBookTab ==
                      SipBookTabType.Transactions) {
                    final sipTransactioncontroller =
                        Get.find<TransactionController>();
                    sipTransactioncontroller
                        .updatePartnerEmployeeSelected(partnerOfficeModel);
                  }
                },
                canSelectAllEmployees: true,
                canSelectPartnerOffice: true,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SipBookTabs(),
              Expanded(
                child: _buildTabBarViewSection(context, controller),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBarViewSection(
      BuildContext context, SipBookController controller) {
    switch (controller.tabController?.index) {
      case 0:
        return SipSummaryView();
      case 1:
        return SipList();
      default:
        return SipSummaryView();
    }
  }
}
