import 'package:app/src/controllers/wealth_academy/events_controller.dart';

import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'event_card.dart';

class EventsSection extends StatelessWidget {
  const EventsSection({
    Key? key,
    required this.eventSchedules,
  }) : super(key: key);

  final double eventCardHeight = 220.0;
  final double eventCardPaddingBottom = 10;

  final List<EventScheduleModel?> eventSchedules;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      builder: (controller) {
        return Container(
          height: eventCardHeight + eventCardPaddingBottom,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 20, bottom: eventCardPaddingBottom),
            itemCount: eventSchedules.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              EventScheduleModel? currentEventSchedule =
                  controller.eventSchedules[index];
              return _buildEventCard(context, currentEventSchedule, controller);
            },
          ),
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context,
      EventScheduleModel? eventSchedule, EventsController controller) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
      // padding: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, 1.0),
            spreadRadius: 0.0,
            blurRadius: 7.0,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      width: screenWidth * 0.8,
      constraints: BoxConstraints(minWidth: 200, maxWidth: 260),
      child: EventCard(eventSchedule: eventSchedule, controller: controller),
    );
  }
}
