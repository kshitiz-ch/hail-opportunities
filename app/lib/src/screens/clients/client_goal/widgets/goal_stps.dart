import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'stp_card.dart';

class GoalStps extends StatelessWidget {
  const GoalStps({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      id: GetxId.goalStp,
      initState: (_) {
        GoalController goalController = Get.find<GoalController>();

        if (goalController.stpListResponse.state != NetworkState.loaded) {
          goalController.getClientStpList();
        }
      },
      builder: (controller) {
        if (controller.stpListResponse.state == NetworkState.loading) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.stpListResponse.state == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.stpListResponse.message,
                onPressed: () {
                  controller.getClientStpList();
                },
              ),
            ),
          );
        }

        if (controller.stpListResponse.state == NetworkState.loaded &&
            controller.baseStps.isNotEmpty) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
            shrinkWrap: true,
            itemCount: controller.baseStps.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            itemBuilder: (BuildContext context, int index) {
              BaseSwitch stp = controller.baseStps[index];

              return StpCard(stp: stp);
            },
          );
        }

        return Center(
          child: EmptyScreen(
            message: 'No STP found',
          ),
        );
      },
    );
  }
}
