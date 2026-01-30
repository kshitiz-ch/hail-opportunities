import 'dart:math';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/screens/broking/view/broking_screen.dart';
import 'package:app/src/screens/broking/widgets/onboarded_client_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LatestClients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingController>(
      id: GetxId.onboarding,
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 10, top: 24),
              child: buildSectionHeader(
                context: context,
                title: 'Latest Clients Added ',
                onViewAll: () {
                  AutoRouter.of(context).push(BrokingOnboardingRoute());
                },
                showViewAll: controller.brokingOnboardingList.isNotNullOrEmpty,
              ),
            ),
            _buildLatestClients(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildLatestClients(
      BuildContext context, BrokingController controller) {
    if (controller.brokingOnboardingResponse.state == NetworkState.loading) {
      return SkeltonLoaderCard(height: 200);
    }
    if (controller.brokingOnboardingResponse.state == NetworkState.error) {
      return SizedBox(
        height: 200,
        child: Center(
          child: RetryWidget(
            controller.brokingOnboardingResponse.message,
            onPressed: () {
              controller.getBrokingOnboardingData();
            },
          ),
        ),
      );
    }

    if (controller.brokingOnboardingResponse.state == NetworkState.loaded) {
      if (controller.brokingOnboardingList.isNullOrEmpty) {
        return EmptyScreen(
          message: 'No Clients Onboarded',
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(
          min(5, controller.brokingOnboardingList.length),
          (index) => Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
            child: OnboardedClientCard(clientIndex: index),
          ),
        ).toList(),
      );
    }
    return SizedBox();
  }
}
