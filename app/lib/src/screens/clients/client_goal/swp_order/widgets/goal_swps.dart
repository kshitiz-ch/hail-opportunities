import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalSwps extends StatelessWidget {
  GoalSwps() {
    final controller = Get.find<GoalController>();
    controller.getClientSWPList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      id: GetxId.goalSwp,
      builder: (controller) {
        if (controller.swpListResponse.state == NetworkState.loading) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.swpListResponse.state == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.swpListResponse.message,
                onPressed: () {
                  controller.getClientSWPList();
                },
              ),
            ),
          );
        }

        if (controller.swpListResponse.state == NetworkState.loaded) {
          final swpList = controller.swpList;

          if (swpList.isNullOrEmpty) {
            return Center(
              child: EmptyScreen(
                message: 'No SWP found',
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
            shrinkWrap: true,
            itemCount: swpList.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 10);
            },
            itemBuilder: (BuildContext context, int index) {
              final baseSwp = swpList[index];

              return SwpCard(
                baseSwp: baseSwp,
              );
            },
          );
        }

        return SizedBox();
      },
    );
  }
}
