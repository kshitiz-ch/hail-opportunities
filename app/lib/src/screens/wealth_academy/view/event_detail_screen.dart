import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/wealth_academy/event_detail_controller.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/screens/wealth_academy/widgets/subscribe_event_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class EventDetailScreen extends StatelessWidget {
  EventDetailScreen(
      {Key? key, this.eventSchedule, @pathParam this.eventScheduleId})
      : super(key: key);

  EventScheduleModel? eventSchedule;
  final String? eventScheduleId;

  final String defaultPoster =
      'https://res.cloudinary.com/dti7rcsxl/image/upload/v1661487469/Group_8208_gxcoco.png';

  @override
  Widget build(BuildContext context) {
    if (eventSchedule == null) {
      eventSchedule =
          EventScheduleModel.fromJson({"external_id": eventScheduleId});
    }

    if (!Get.isRegistered<EventsController>()) {
      Get.put(EventsController());
    }

    return GetBuilder<EventDetailController>(
      init: EventDetailController(eventSchedule),
      dispose: (_) => Get.delete<EventDetailController>(),
      builder: (controller) {
        if (controller.eventScheduleDetailState == NetworkState.loading ||
            controller.eventScheduleDetailState == NetworkState.error) {
          return Scaffold(
            appBar: CustomAppBar(
              showBackButton: true,
            ),
            backgroundColor: ColorConstants.white,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              height: MediaQuery.of(context).size.height,
              child: controller.eventScheduleDetailState == NetworkState.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(
                      child: Text(
                        'This event is not available',
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(),
          );
        }

        String eventScheduledAtText = '';
        String? urlToNavigate;
        bool isEventSubscribed =
            controller.eventSchedule!.joiningShortUrl.isNotNullOrEmpty ||
                controller.eventSchedule!.joiningUrl.isNotNullOrEmpty ||
                controller.eventSchedule!.isEventSubscribed;

        if (controller.eventSchedule!.joiningUrl.isNotNullOrEmpty) {
          urlToNavigate = controller.eventSchedule!.joiningUrl;
        } else if (controller.eventSchedule!.joiningShortUrl.isNotNullOrEmpty) {
          urlToNavigate = controller.eventSchedule!.joiningShortUrl;
        }

        try {
          if (controller.eventSchedule!.eventScheduledAt != null) {
            eventScheduledAtText =
                '${DateFormat('hh:mm a, dd MMM yyyy').format(controller.eventSchedule!.eventScheduledAt!.toLocal())}';
          } else if (controller.eventSchedule!.upcomingEvents![0].scheduledAt !=
              null) {
            eventScheduledAtText =
                'First slot on ${DateFormat('dd MMM, hh:mm a').format(controller.eventSchedule!.upcomingEvents![0].scheduledAt!.toLocal())}';
          }
        } catch (error) {
          LogUtil.printLog(error);
        }

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Wealthy Training',
            leadingLeftPadding: 20,
            showBackButton: true,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 24).copyWith(top: 20),
            child: ListView(
              children: [
                _buildEventPoster(context, controller.eventSchedule!),
                if (isEventSubscribed)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorConstants.primaryCardColor,
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Scheduled for ',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(fontSize: 12),
                          ),
                          Text(
                            eventScheduledAtText,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                    color: ColorConstants.primaryAppColor,
                                    fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      eventScheduledAtText,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineLarge!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontSize: 14),
                    ),
                  ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  controller.eventSchedule!.name!,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                if (controller.eventSchedule!.description.isNotNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      controller.eventSchedule!.description!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 12,
                              color: ColorConstants.tertiaryBlack,
                              height: 1.4),
                    ),
                  )
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            heroTag: kDefaultHeroTag,
            text: isEventSubscribed ? 'Go to Event' : 'Register',
            onPressed: () async {
              if (isEventSubscribed) {
                _openEventJoiningUrl(context, urlToNavigate!);
              } else {
                _openSubscribeEventBottomsheet(context, controller);
              }
            },
          ),
        );
      },
    );
  }

  _openEventJoiningUrl(BuildContext context, String urlToNavigate) {
    if (urlToNavigate.isNullOrEmpty) {
      return;
    }

    if (urlToNavigate.startsWith("https://event.wealthy")) {
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
      launch(urlToNavigate);
    }
  }

  _openSubscribeEventBottomsheet(
      BuildContext context, EventDetailController controller) async {
    await CommonUI.showBottomSheet(
      context,
      child: SubscribeEventBottomsheet(
        eventSchedule: controller.eventSchedule,
        onEventSubscribe: (EventSubscriberModel? eventSubscriberModel) {
          if (eventSubscriberModel != null) {
            controller.eventSchedule!.joiningUrl =
                eventSubscriberModel.joiningUrl;
            controller.eventSchedule!.joiningShortUrl =
                eventSubscriberModel.joiningShortUrl;
            controller.eventSchedule!.eventScheduledAt =
                eventSubscriberModel.event?.scheduledAt;

            _updateEventList(controller.eventSchedule);

            controller.update();
          }
        },
      ),
    );

    if (Get.isRegistered<EventsController>()) {
      Get.find<EventsController>().resetEventSubscribeStates();
    }
  }

  _updateEventList(EventScheduleModel? updatedEventScheduleModel) {
    EventsController? eventsController;
    if (Get.isRegistered<EventsController>()) {
      eventsController = Get.find<EventsController>();
    }

    if (eventsController != null &&
        eventsController.eventSchedules.isNotEmpty) {
      int index = 0;
      int? indexOfUpdatedEventSchedule;
      for (EventScheduleModel? eventSchedule
          in eventsController.eventSchedules) {
        if (eventSchedule!.externalId ==
            updatedEventScheduleModel!.externalId) {
          indexOfUpdatedEventSchedule = index;
          break;
        }

        index++;
      }

      if (indexOfUpdatedEventSchedule != null) {
        eventsController.eventSchedules[indexOfUpdatedEventSchedule] =
            updatedEventScheduleModel;
      }

      eventsController.update();
    }
  }

  Widget _buildEventPoster(
      BuildContext context, EventScheduleModel eventSchedule) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: CachedNetworkImage(
        imageUrl: eventSchedule.posterImageUrl.isNotNullOrEmpty
            ? eventSchedule.posterImageUrl!
            : defaultPoster,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }
}
