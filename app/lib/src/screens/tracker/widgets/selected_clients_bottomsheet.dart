import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/tracker/widgets/client_card.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedClientsBottomSheetState extends StatelessWidget {
  final trackerController = Get.find<TrackerListController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackerListController>(
      builder: (controller) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Text(
                  'Selected Clients',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                ),
              ),
              if (controller.clientsSelected.length > 0)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  color: ColorConstants.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.zero,
                    itemCount: controller.clientsSelected.length,
                    itemBuilder: (BuildContext context, int index) {
                      final client = controller.clientsSelected[index];
                      return ClientCard(
                        client: client,
                        index: index,
                        isValueSelected:
                            trackerController.isClientSelected(client),
                        onClickHandler: () =>
                            trackerController.onClientSelect(client),
                      );
                    },
                  ),
                )
              else
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'no clients selected'.toTitleCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontSize: 16,
                          color: ColorConstants.darkGrey,
                        ),
                  ),
                ),
              SizedBox(height: 50),
              if (controller.clientsSelected.isNotNullOrEmpty)
                _buildActionButtons(context)
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            responsiveButtonMaxWidthRatio: 0.4,
            bgColor: ColorConstants.secondaryAppColor,
            textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                  color: ColorConstants.primaryAppColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
            text: 'Cancel',
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
            margin: EdgeInsets.zero,
          ),
          SizedBox(
            width: 12,
          ),
          GetBuilder<CommonController>(
              id: 'tracker',
              builder: (commonController) {
                return ActionButton(
                  responsiveButtonMaxWidthRatio: 0.4,
                  text: 'Send Request',
                  showProgressIndicator:
                      commonController.sendTrackerRequestResponse.isLoading,
                  margin: EdgeInsets.zero,
                  onPressed: () async {
                    MixPanelAnalytics.trackWithAgentId(
                      "send_request",
                      screen: 'tracker_requests',
                      screenLocation: 'selected_clients',
                    );

                    if (trackerController.clientsSelected.length > 0) {
                      try {
                        await commonController.sendTrackerRequest(
                            trackerController.clientsSelected);
                        if (commonController
                            .sendTrackerRequestResponse.isLoaded) {
                          AutoRouter.of(context).push(
                            TrackerRequestSuccessRoute(
                              clients: trackerController.clientsSelected,
                              trackerLinkMap: commonController.trackerLinkMap,
                            ),
                          );
                        } else {
                          showToast(
                            text: commonController
                                .sendTrackerRequestResponse.message,
                            context: context,
                          );
                        }
                      } catch (error) {
                        showToast(
                          text: commonController
                              .sendTrackerRequestResponse.message,
                          context: context,
                        );
                      }
                    }
                  },
                );
              })
        ],
      ),
    );
  }
}
