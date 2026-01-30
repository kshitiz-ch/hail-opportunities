import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/tracker/widgets/selected_clients_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendTrackerBottomBar extends StatefulWidget {
  final FocusNode? searchInputFocusNode;

  const SendTrackerBottomBar({Key? key, this.searchInputFocusNode})
      : super(key: key);

  @override
  State<SendTrackerBottomBar> createState() => _SendTrackerBottomBarState();
}

class _SendTrackerBottomBarState extends State<SendTrackerBottomBar> {
  final trackerController = Get.find<TrackerListController>();

  bool isKeyboardOpen(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackerListController>(
      builder: (controller) {
        return (controller.clientsSelected.length > 0 &&
                !isKeyboardOpen(context))
            ? Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 0.5,
                      color: ColorConstants.black.withOpacity(0.25),
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _buildClientCount(
                                controller.clientsSelected.length),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Text(
                                ' Selected',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.tertiaryBlack,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Maximum: 10 Clients',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        )
                      ],
                    ),
                    ActionButton(
                      responsiveButtonMaxWidthRatio: 0.4,
                      height: 56,
                      margin: EdgeInsets.zero,
                      text: 'Send Request',
                      showProgressIndicator: false,
                      borderRadius: 51,
                      onPressed: () async {
                        MixPanelAnalytics.trackWithAgentId(
                          "send_request",
                          screen: 'tracker_requests',
                          screenLocation: 'client_selection',
                        );

                        widget.searchInputFocusNode!.unfocus();
                        CommonUI.showBottomSheet(
                          context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          borderRadius: 20,
                          barrierColor: ColorConstants.black.withOpacity(0.8),
                          backgroundColor: ColorConstants.white,
                          child: SelectedClientsBottomSheetState(),
                        );
                      },
                    ),
                  ],
                ),
              )
            : SizedBox();
      },
    );
  }

  Widget _buildClientCount(int count) {
    return Text(
      "$count Client${count > 1 ? "s" : ""}",
      style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorConstants.primaryAppColor,
          ),
    );
  }
}
