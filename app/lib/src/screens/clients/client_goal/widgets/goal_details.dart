import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/goal_swps.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/constants/enums.dart';
import 'goal_allocation.dart';
import 'goal_sips.dart';
import 'goal_stps.dart';
import 'goal_summary.dart';

class GoalDetails extends StatefulWidget {
  const GoalDetails({Key? key}) : super(key: key);

  @override
  State<GoalDetails> createState() => _GoalDetailsState();
}

class _GoalDetailsState extends State<GoalDetails>
    with TickerProviderStateMixin {
  TabController? tabController;
  final tabList = [
    GoalDetailTabs.Overview.name,
    GoalDetailTabs.Transactions.name,
    GoalDetailTabs.SIP.name,
    GoalDetailTabs.STP.name,
    GoalDetailTabs.SWP.name
  ];
  int currentTabIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: tabList.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      builder: (controller) {
        return Column(
          children: [
            Container(
              color: ColorConstants.white,
              height: 54,
              child: TabBar(
                dividerHeight: 0,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                indicatorWeight: 1,
                indicatorPadding: EdgeInsets.zero,
                indicatorColor: ColorConstants.primaryAppColor,
                controller: tabController,
                unselectedLabelColor: ColorConstants.tertiaryBlack,
                unselectedLabelStyle: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
                labelStyle: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600),
                tabs: List.generate(
                  tabList.length,
                  (index) {
                    String text = tabList[index];
                    if (text == GoalDetailTabs.Transactions.name &&
                        controller.mfSchemeOrderCount > 0) {
                      text = '$text (${controller.mfSchemeOrderCount})';
                    }

                    if (text == GoalDetailTabs.SIP.name &&
                        controller.sipCount > 0) {
                      text = '$text (${controller.sipCount})';
                    }

                    if (text == GoalDetailTabs.STP.name &&
                        controller.switchCount > 0) {
                      text = '$text (${controller.switchCount})';
                    }

                    if (text == GoalDetailTabs.SWP.name &&
                        controller.swpCount > 0) {
                      text = '$text (${controller.swpCount})';
                    }

                    return Tab(
                      text: text,
                      iconMargin: EdgeInsets.zero,
                    );
                  },
                ).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _buildGoalOverview(),
                  _buildGoalTransactions(controller),
                  GoalSips(
                    client: controller.client,
                    goalId: controller.goal?.id ?? '',
                    anyFundWschemecode:
                        controller.mfInvestmentType == MfInvestmentType.Funds
                            ? controller.wschemecodeSelected
                            : '',
                  ),
                  GoalStps(),
                  GoalSwps(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalOverview() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
      child: Column(
        children: [
          GoalSummary(),
          GoalAllocation(),
        ],
      ),
    );
  }

  Widget _buildGoalTransactions(GoalController controller) {
    return GetBuilder<TransactionController>(
      init: TransactionController(
        screenContext: TransactionScreenContext.goalDetailView,
        selectedClient: controller.client,
        goalId: controller.goal?.goalId,
        wschemecode: controller.mfInvestmentType == MfInvestmentType.Funds
            ? controller.wschemecodeSelected
            : null,
      ),
      autoRemove: false,
      builder: (controller) {
        return TransactionList(showClientDetails: false);
      },
    );
  }
}
