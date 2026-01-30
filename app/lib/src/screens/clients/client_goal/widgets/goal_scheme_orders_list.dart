import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GoalSchemeOrdersList extends StatelessWidget {
  const GoalSchemeOrdersList({Key? key, required this.wschemecode})
      : super(key: key);

  final String wschemecode;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      id: GetxId.goalSchemeOrders,
      initState: (_) {
        GoalController goalController = Get.find<GoalController>();

        if (goalController.wschemecodeSelected != wschemecode) {
          goalController.wschemecodeSelected = wschemecode;
          goalController.getGoalSchemeOrders();
        } else if (goalController.schemeOrdersResponse.state !=
            NetworkState.loaded) {
          goalController.wschemecodeSelected = wschemecode;
          goalController.getGoalSchemeOrders();
        }
      },
      builder: (controller) {
        if (!controller.isSchemeOrdersPaginating &&
            controller.schemeOrdersResponse.state == NetworkState.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.schemeOrdersResponse.state == NetworkState.error) {
          return Center(
            child: SizedBox(
              height: 96,
              child: RetryWidget(
                controller.schemeOrdersResponse.message,
                onPressed: () => controller.getGoalSchemeOrders(),
              ),
            ),
          );
        }

        if (controller.schemeOrdersResponse.state == NetworkState.loaded &&
            controller.schemeOrders.isEmpty) {
          return EmptyScreen(
            message: 'No Transactions Found for this Scheme',
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 20),
                controller: controller.schemeOrdersScrollController,
                itemCount: controller.schemeOrders.length,
                itemBuilder: (context, index) {
                  SchemeOrderModel schemeOrder = controller.schemeOrders[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 7),
                        child: Row(
                          children: [
                            Text(
                              WealthyAmount.currencyFormat(
                                  schemeOrder.displayAmount, 0),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '•',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: ColorConstants.tertiaryBlack),
                              ),
                            ),
                            Text(
                              getSchemeOrderStatusDescription(
                                  schemeOrder.schemeStatus),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: getSchemeOrderStatusColor(
                                      schemeOrder.schemeStatus,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CommonClientUI.columnInfoText(
                            context,
                            title: 'Order Date',
                            subtitle: schemeOrder.navAllocatedAt != null
                                ? DateFormat("dd MMM yyyy")
                                    .format(schemeOrder.navAllocatedAt!)
                                : 'NA',
                          ),
                          CommonClientUI.columnInfoText(
                            context,
                            title: 'Units (Nav)',
                            subtitle:
                                '${schemeOrder.units != null ? schemeOrder.units!.toStringAsFixed(2) : 0} @ ${schemeOrder.nav != null ? schemeOrder.nav!.toStringAsFixed(2) : 0}',
                          ),
                          CommonClientUI.columnInfoText(
                            context,
                            title: 'Transaction',
                            subtitle: '${schemeOrder.categoryDescription}',
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [

                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(color: ColorConstants.lightGrey),
                  );
                },
              ),
            ),
            if (controller.isSchemeOrdersPaginating) CommonUI.infinityLoader()
          ],
        );
      },
    );
  }
}
