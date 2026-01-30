import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/screens/broking/widgets/onboarded_client_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrokingOnboardedClients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingController>(
      id: GetxId.onboarding,
      builder: (controller) {
        if (controller.brokingOnboardingResponse.state == NetworkState.loaded ||
            controller.isOnboardingPaginating) {
          if (controller.brokingOnboardingList.isNullOrEmpty) {
            return _buildEmptyState();
          }
          return _buildLoadedState(context, controller);
        }
        if (controller.brokingOnboardingResponse.state ==
            NetworkState.loading) {
          return _buildLoadingState();
        }
        if (controller.brokingOnboardingResponse.state == NetworkState.error) {
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

  Widget _buildErrorState(BrokingController controller) {
    final errorMessage = controller.brokingOnboardingResponse.message;

    return Center(
      child: RetryWidget(
        errorMessage,
        onPressed: () {
          controller.getBrokingOnboardingData();
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

  Widget _buildLoadedState(BuildContext context, BrokingController controller) {
    return ListView.builder(
      controller: controller.onboardingScrollController,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 10),
              child: OnboardedClientCard(clientIndex: index),
            ),
            if ((index + 1) == controller.brokingOnboardingList.length &&
                controller.isOnboardingPaginating)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
      itemCount: controller.brokingOnboardingList.length,
    );
  }
}
