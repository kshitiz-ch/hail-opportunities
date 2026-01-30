import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubscribeEventBottomsheet extends StatelessWidget {
  final EventScheduleModel? eventSchedule;
  final void Function(EventSubscriberModel?)? onEventSubscribe;
  SubscribeEventBottomsheet({this.eventSchedule, this.onEventSubscribe});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      id: 'event-subscribe',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(top: 30, left: 30, right: 30),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eventSchedule!.name!,
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
              ),
              if (eventSchedule!.language.isNotNullOrEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryCardColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    eventSchedule!.language!.toTitleCase(),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: ColorConstants.tertiaryGrey),
                  ),
                ),
              SizedBox(
                height: 24,
              ),
              Flexible(
                  child: SingleChildScrollView(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.black.withOpacity(0.15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Schedules',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (eventSchedule!.upcomingEvents.isNullOrEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 50, bottom: 20),
                          child: Center(
                            child: Text(
                              'There are no upcoming events',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: ColorConstants.lightBlack,
                                      fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        for (var index = 0;
                            index < eventSchedule!.upcomingEvents!.length;
                            index++)
                          InkWell(
                            onTap: () {
                              controller.setEventSelected(
                                  eventSchedule!.upcomingEvents![index]);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 15, bottom: 15),
                              decoration: BoxDecoration(
                                border: index !=
                                        eventSchedule!.upcomingEvents!.length -
                                            1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: ColorConstants.lightGrey),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Radio(
                                      activeColor:
                                          ColorConstants.primaryAppColor,
                                      value: eventSchedule!
                                          .upcomingEvents![index].scheduledAt
                                          .toString(),
                                      groupValue: controller
                                          .eventSelected?.scheduledAt
                                          .toString(),
                                      onChanged: (dynamic value) {
                                        controller.setEventSelected(
                                            eventSchedule!
                                                .upcomingEvents![index]);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      (eventSchedule == null ||
                                              eventSchedule!
                                                      .upcomingEvents![index]
                                                      .scheduledAt ==
                                                  null)
                                          ? ''
                                          : getEventDateScheduleFormatted(
                                              eventSchedule!
                                                  .upcomingEvents![index]
                                                  .scheduledAt!
                                                  .toLocal(),
                                            ),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: ColorConstants.black),
                                      // style: Theme.of(context)
                                      //     .primaryTextTheme
                                      //     .displayLarge
                                      //     .copyWith(
                                      //       height: 18 / 12,
                                      //       fontSize: 16,
                                      //       color: Colors.black,
                                      //     ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              )),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(top: 30, bottom: 16),
                child: ActionButton(
                  isDisabled: controller.eventSelected == null,
                  showProgressIndicator:
                      controller.eventSubscribeState == NetworkState.loading,
                  margin: EdgeInsets.zero,
                  text: 'Register',
                  onPressed: () async {
                    await controller
                        .subscribeEvent(controller.eventSelected!.externalId!);

                    if (controller.eventSubscribeState == NetworkState.loaded) {
                      showToast(
                          text: controller.eventSubscribeErrorMessage ??
                              'Registered Successfully');
                      AutoRouter.of(context).popForced();

                      onEventSubscribe!(controller.eventSubscriberResponse);
                    } else {
                      return showToast(
                          text: controller.eventSubscribeErrorMessage ??
                              'Failed to register. Please try after sometime');
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getEventDateScheduleFormatted(DateTime scheduledAt) {
    try {
      return DateFormat('dd MMM E, hh:mm a').format(scheduledAt);
    } catch (error) {
      return scheduledAt.toString();
    }
  }
}
