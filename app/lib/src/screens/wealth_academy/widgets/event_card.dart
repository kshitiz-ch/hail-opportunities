import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/screens/wealth_academy/widgets/subscribe_event_bottomsheet.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EventCard extends StatelessWidget {
  EventCard({Key? key, this.eventSchedule, this.controller}) : super(key: key);

  final EventScheduleModel? eventSchedule;
  final EventsController? controller;

  final double eventCardHeight = 220.0;
  final double eventPosterHeight = 135;
  final String defaultPoster =
      'https://res.cloudinary.com/dti7rcsxl/image/upload/v1661487469/Group_8208_gxcoco.png';

  String? actionButtonText;
  String? urlToNavigate;

  void onEventCardClick(context) async {
    if (urlToNavigate.isNullOrEmpty) {
      await CommonUI.showBottomSheet(
        context,
        child: SubscribeEventBottomsheet(
          eventSchedule: eventSchedule,
          onEventSubscribe: (EventSubscriberModel? eventSubscriberModel) {
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

  @override
  Widget build(BuildContext context) {
    if (eventSchedule!.joiningUrl.isNotNullOrEmpty) {
      actionButtonText = 'JOIN';
      urlToNavigate = eventSchedule!.joiningUrl;
    } else if (eventSchedule!.joiningShortUrl.isNotNullOrEmpty) {
      actionButtonText = 'VISIT';
      urlToNavigate = eventSchedule!.joiningShortUrl;
    } else {
      actionButtonText = 'REGISTER';
    }

    return InkWell(
      onTap: () {
        AutoRouter.of(context)
            .push(EventDetailRoute(eventSchedule: eventSchedule));
      },
      child: Column(
        children: [
          _buildEventPoster(context),
          _buildEventCardDetails(context),
        ],
      ),
    );
  }

  Widget _buildEventPoster(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: CachedNetworkImage(
            imageUrl: eventSchedule!.posterImageUrl.isNotNullOrEmpty
                ? eventSchedule!.posterImageUrl!
                : defaultPoster,
            height: eventPosterHeight,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
        if (eventSchedule!.joiningUrl.isNotNullOrEmpty ||
            eventSchedule!.joiningShortUrl.isNotNullOrEmpty)
          Positioned(
            left: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 2, right: 2),
                    color: ColorConstants.redAccentColor,
                    child: Text(
                      'REGISTERED',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEventCardDetails(BuildContext context) {
    late String eventScheduledAtText;

    // First check inside eventSchedule object, scheduledAt will be present if event is registered
    // Else use the scheduledAt value from the event Object
    if (eventSchedule!.eventScheduledAt != null) {
      eventScheduledAtText =
          '${DateFormat('dd MMM, hh:mm a').format(eventSchedule!.eventScheduledAt!)}';
    } else if (eventSchedule!.upcomingEvents![0].scheduledAt != null) {
      eventScheduledAtText =
          'Starting on ${DateFormat('dd MMM').format(eventSchedule!.upcomingEvents![0].scheduledAt!)}';
    }

    return Container(
      height: eventCardHeight - eventPosterHeight,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  child: MarqueeWidget(
                    child: Text(
                      eventSchedule!.name!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(height: 1.2, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventScheduledAtText.isNotNullOrEmpty)
                          Text(
                            eventScheduledAtText,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    height: 1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: ColorConstants.tertiaryGrey),
                          ),
                        if (eventSchedule != null &&
                            eventSchedule!.language.isNotNullOrEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColorConstants.tertiaryBlack
                                    .withOpacity(0.1)),
                            child: Text(
                              eventSchedule!.language!.toTitleCase(),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(color: ColorConstants.lightGrey),
                            ),
                          )
                      ],
                    ),
                    _buildEventActionButton(context)
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventActionButton(BuildContext context) {
    // String actionButtonText;
    // String urlToNavigate;

    // if (eventSchedule.joiningUrl.isNotNullOrEmpty) {
    //   actionButtonText = 'JOIN';
    //   urlToNavigate = eventSchedule.joiningUrl;
    // } else if (eventSchedule.joiningShortUrl.isNotNullOrEmpty) {
    //   actionButtonText = 'VISIT';
    //   urlToNavigate = eventSchedule.joiningShortUrl;
    // } else {
    //   actionButtonText = 'REGISTER';
    // }

    return Container(
      //   child: Text(
      //     actionButtonText,
      //     style: Theme.of(context).textTheme.button.copyWith(
      //           color: ColorConstants.primaryAppColor,
      //           fontWeight: FontWeight.w900,
      //           height: (18 / 12),
      //           fontSize: 12,
      //         ),
      //   ),
      // );
      child: ClickableText(
        padding: EdgeInsets.only(left: 10),
        onClick: () async {
          onEventCardClick(context);
        },
        text: actionButtonText,
      ),
    );
  }
}
