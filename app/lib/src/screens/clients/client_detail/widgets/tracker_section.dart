import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/send_tracker_request_card.dart';
import 'package:app/src/screens/clients/client_detail/widgets/tracker_value_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class TrackerSection extends StatelessWidget {
  // Fields
  final Client? client;

  // Constructor
  const TrackerSection({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientAdditionalDetailController>(
      id: 'tracker',
      builder: (controller) {
        final trackerValue = controller.trackerValue;
        final isTrackerNotSynced =
            controller.trackerResponse.message.toLowerCase() ==
                'user_id not synced'.toLowerCase();
        if (controller.trackerResponse.state == NetworkState.loading) {
          return SendTrackerRequestCard().toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        }

        if (controller.trackerResponse.state == NetworkState.error) {
          if (isTrackerNotSynced) {
            return SendTrackerRequestCard(client: client);
          }
          return SizedBox(
            height: 87,
            child: RetryWidget(
              controller.trackerResponse.message,
              onPressed: () => controller.getTrackerInfo(isRetry: true),
            ),
          );
        }

        if (trackerValue != null && trackerValue > 0) {
          return TrackerValueCard(
            client: client,
            trackerValue: trackerValue,
            lastSyncedAt: controller.trackerLastSyncedAt,
          );
        }

        return SendTrackerRequestCard(client: client);
      },
    );
  }
}
