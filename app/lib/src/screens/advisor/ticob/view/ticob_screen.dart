import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_opportunity_view.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_search_bar.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_tabs.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_transaction_view.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class TicobScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      init: TicobController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'Change of Broker',
            trailingWidgets: [
              SizedBox(
                width: 120,
                child: PartnerOfficeDropdown(
                  tag: 'ticob',
                  title: controller.tabs[controller.tabController?.index ?? 0],
                  onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                    MixPanelAnalytics.trackWithAgentId(
                      "employee_selection",
                      screen: 'ticob_screen',
                      screenLocation: 'ticob_screen',
                    );
                    controller
                        .updatePartnerEmployeeSelected(partnerOfficeModel);
                  },
                  canSelectAllEmployees: true,
                  canSelectPartnerOffice: true,
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TicobTabs(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: TicobSearchBar(),
              ),
              Expanded(
                child: _buildTabBarViewSection(context, controller),
              )
            ],
          ),
          bottomNavigationBar: !controller.isTransactionTabSelected
              ? ActionButton(
                  text: 'Generate COB Form',
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  onPressed: () {
                    AutoRouter.of(context).push(GenerateCobOptionRoute());
                  },
                )
              : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTabBarViewSection(
      BuildContext context, TicobController controller) {
    switch (controller.tabController?.index ?? 0) {
      case 0:
        return TicobOpportunityView();
      case 1:
        return TicobTransactionView();
      default:
        return TicobOpportunityView();
    }
  }
}
