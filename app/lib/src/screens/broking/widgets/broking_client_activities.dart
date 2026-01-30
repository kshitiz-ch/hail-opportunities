import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/broking/broking_activity_controller.dart';
import 'package:app/src/screens/broking/widgets/client_activity_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrokingClientActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingActivityController>(
      id: GetxId.activity,
      builder: (controller) {
        if (controller.brokingActivityResponse.state == NetworkState.loaded ||
            controller.isActivityPaginating) {
          if (controller.brokingActivityList.isNullOrEmpty) {
            return _buildEmptyState();
          }
          return _buildLoadedState(context, controller);
        }
        if (controller.brokingActivityResponse.state == NetworkState.loading) {
          return _buildLoadingState();
        }
        if (controller.brokingActivityResponse.state == NetworkState.error) {
          return _buildErrorState(controller);
        }

        return SizedBox();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BrokingActivityController controller) {
    final errorMessage = controller.brokingActivityResponse.message;

    return Center(
      child: RetryWidget(
        errorMessage,
        onPressed: () {
          controller.getBrokingActivityData();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyScreen(
        message: 'No Data Found',
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, BrokingActivityController controller) {
    return ListView.builder(
      itemCount: controller.brokingActivityList.length,
      controller: controller.activityScrollController,
      padding: EdgeInsets.only(bottom: 50),
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 10),
              child: ClientActivityCard(clientIndex: index),
            ),
            if ((index + 1) == controller.brokingActivityList.length &&
                controller.isActivityPaginating)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}
