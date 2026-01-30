import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendTrackerRequestBottomSheet extends StatelessWidget {
  SendTrackerRequestBottomSheet({Key? key, this.client}) : super(key: key);

  final Client? client;

  @override
  Widget build(BuildContext context) {
    final source = _getSource(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 32.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                size: 30,
                color: Colors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Are you sure you want to send tracker sync request?',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ActionButton(
                  responsiveButtonMaxWidthRatio: 0.4,
                  text: 'Cancel',
                  textStyle:
                      Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                  margin: const EdgeInsets.only(left: 16.0),
                  bgColor: ColorConstants.secondaryAppColor,
                  onPressed: () async {
                    MixPanelAnalytics.trackWithAgentId(
                      "cancel_button",
                      screenLocation: 'tracker_card',
                      properties:
                          source.isNotNullOrEmpty ? {'source': source} : null,
                    );

                    AutoRouter.of(context).popForced();
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: GetBuilder<CommonController>(
                  id: 'tracker',
                  builder: (controller) {
                    return ActionButton(
                      text: 'Yes, Send',
                      margin: const EdgeInsets.only(left: 16.0),
                      showProgressIndicator:
                          controller.sendTrackerRequestResponse.isLoading,
                      onPressed: () async {
                        final clients = [client!];
                        await controller.sendTrackerRequest(clients);

                        MixPanelAnalytics.trackWithAgentId(
                          "send_button",
                          screenLocation: 'tracker_card',
                          properties: source.isNotNullOrEmpty
                              ? {'source': source}
                              : null,
                        );
                        if (controller.sendTrackerRequestResponse.isLoaded) {
                          AutoRouter.of(context).push(
                            TrackerRequestSuccessRoute(
                              trackerLinkMap: controller.trackerLinkMap,
                              clients: clients,
                            ),
                          );
                        }
                      },
                    );
                  },
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getSource(BuildContext context) {
    String? source;
    try {
      final currentRouteName = AutoRouter.of(context).current.name;
      source = convertRouteToPageName(currentRouteName);
    } catch (e) {
    } finally {
      return source;
    }
  }
}
