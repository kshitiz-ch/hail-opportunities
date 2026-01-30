import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/widgets/learn_with_wealthy_section.dart';
import 'package:app/src/screens/wealth_academy/widgets/subscribe_event_bottomsheet.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EventsSection extends StatelessWidget {
  List<List<Color>> linearGradientList = [];

  EventsSection() {
    Get.put<EventsController>(EventsController());
    linearGradientList = [
      [hexToColor("#FEC8A3"), hexToColor("#FE9D98")],
      [hexToColor("#80D8C1"), hexToColor("#71CCDF")],
      [hexToColor("#CB9FEA"), hexToColor("#E89AB9")],
    ];
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      initState: (_) {
        EventsController _controller = Get.find<EventsController>();

        if (_controller.eventSchedules.length <= 0 &&
            _controller.eventSchedulesState != NetworkState.loaded) {
          _controller.getEventSchedules();
        }
      },
      builder: (controller) {
        if (controller.eventSchedulesState == NetworkState.loading) {
          return SkeltonLoaderCard(
            height: 500,
            margin: EdgeInsets.only(bottom: 16, left: 20, right: 20, top: 20),
          );
        }
        if (controller.eventSchedulesState == NetworkState.error) {
          return SizedBox(
            height: 500,
            child: Center(
              child: RetryWidget(
                genericErrorMessage,
                onPressed: () {
                  controller.getEventSchedules();
                },
              ),
            ),
          );
        }
        if (controller.eventSchedulesState == NetworkState.loaded) {
          if (controller.eventSchedules.isNullOrEmpty) {
            return SizedBox(
              height: 500,
              child: EmptyScreen(
                message: 'No Data Available',
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              min(maxNoOfEntries, controller.eventSchedules.length),
              (index) => _buildEventCard(controller, context, index),
            )..addIf(
                maxNoOfEntries < controller.eventSchedules.length,
                buildViewAllCTA(
                  context: context,
                  onClick: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "events_view_all",
                      properties: {
                        "screen_location": "events",
                        "screen": "Home",
                      },
                    );
                    AutoRouter.of(context).push(WealthAcademyRoute());
                  },
                ),
              ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildEventCard(
      EventsController controller, BuildContext context, int index) {
    String eventScheduledAtText = '';
    final eventSchedule = controller.eventSchedules[index];

    // First check inside eventSchedule object, scheduledAt will be present if event is registered
    // Else use the scheduledAt value from the event Object
    if (eventSchedule!.eventScheduledAt != null) {
      eventScheduledAtText =
          'Starting on ${DateFormat('dd MMM, hh:mm a').format(eventSchedule.eventScheduledAt!)}';
    } else if (eventSchedule!.upcomingEvents![0].scheduledAt != null) {
      eventScheduledAtText =
          'Starting on ${DateFormat('dd MMM').format(eventSchedule.upcomingEvents![0].scheduledAt!)}';
    }

    return InkWell(
      onTap: () {
        AutoRouter.of(context)
            .push(EventDetailRoute(eventSchedule: eventSchedule));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: linearGradientList[index % linearGradientList.length],
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MarqueeWidget(
                        child: Text(
                          controller.eventSchedules[index]?.name ?? '',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.white,
                              ),
                        ),
                      ),
                    ),
                    // SizedBox(width: 5),
                    // Container(
                    //   height: 18,
                    //   width: 32,
                    //   color: ColorConstants.white,
                    //   padding: EdgeInsets.all(1),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(4),
                    //       gradient: LinearGradient(
                    //         colors: linearGradientList[
                    //             index % linearGradientList.length],
                    //       ),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         'Live',
                    //         style: Theme.of(context)
                    //             .primaryTextTheme
                    //             .titleMedium
                    //             ?.copyWith(
                    //               fontWeight: FontWeight.w400,
                    //               color: ColorConstants.white,
                    //             ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Text(
                    eventScheduledAtText,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.white,
                            ),
                  ),
                ),
                _buildActionButton(controller, context, eventSchedule),
              ],
            ),
            Positioned(
              top: 15,
              right: -50,
              child: Image.asset(
                AllImages().semiEllipseIcon,
                height: 98,
                width: 98,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    EventsController controller,
    BuildContext context,
    EventScheduleModel? eventSchedule,
  ) {
    String? actionButtonText;
    String? urlToNavigate;

    if (eventSchedule!.joiningUrl.isNotNullOrEmpty) {
      actionButtonText = 'JOIN';
      urlToNavigate = eventSchedule.joiningUrl;
    } else if (eventSchedule.joiningShortUrl.isNotNullOrEmpty) {
      actionButtonText = 'VISIT';
      urlToNavigate = eventSchedule.joiningShortUrl;
    } else {
      actionButtonText = 'REGISTER';
    }

    return SizedBox(
      width: 120,
      child: ActionButton(
        borderRadius: 8,
        text: actionButtonText,
        bgColor: ColorConstants.white,
        height: 40,
        margin: EdgeInsets.zero,
        textStyle: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.primaryAppColor,
            ),
        onPressed: () {
          onEventCardClick(
            controller,
            context,
            urlToNavigate ?? '',
            eventSchedule,
          );
        },
      ),
    );
  }

  void onEventCardClick(
    EventsController controller,
    BuildContext context,
    String urlToNavigate,
    EventScheduleModel? eventSchedule,
  ) async {
    if (urlToNavigate.isNullOrEmpty) {
      await CommonUI.showBottomSheet(
        context,
        child: SubscribeEventBottomsheet(
          eventSchedule: eventSchedule,
          onEventSubscribe: (EventSubscriberModel? eventSubscriberModel) {
            MixPanelAnalytics.trackWithAgentId(
              "events_register",
              properties: {
                "screen_location": "events",
                "screen": "Home",
              },
            );
            if (eventSubscriberModel != null) {
              eventSchedule!.joiningUrl = eventSubscriberModel.joiningUrl;
              eventSchedule!.joiningShortUrl =
                  eventSubscriberModel.joiningShortUrl;
              eventSchedule!.eventScheduledAt =
                  eventSubscriberModel.event?.scheduledAt;
              controller!.update();
            }
          },
        ),
      );

      // reset event subscribe related states after closing subscribe bottomsheet
      controller?.resetEventSubscribeStates();
    } else if (urlToNavigate!.startsWith("https://event.wealthy")) {
      AutoRouter.of(context).push(
        WebViewRoute(
          url: urlToNavigate,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('zoom')) {
              launch(request.url);
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      );
    } else {
      launch(urlToNavigate!);
    }
  }
}
