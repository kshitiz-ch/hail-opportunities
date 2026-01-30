import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:core/modules/wealth_academy/resources/events_repository.dart';
import 'package:get/get.dart';

class EventsController extends GetxController {
  NetworkState eventSchedulesState = NetworkState.loading;
  NetworkState eventScheduleDetailState = NetworkState.cancel;
  NetworkState eventSubscribeState = NetworkState.loaded;

  List<EventScheduleModel?> eventSchedules = [];
  EventScheduleModel? eventSchedule;

  List<String> filtersList = ['All', 'Registered', 'Not Registered'];
  String selectedFilter = 'All';

  EventModel? eventSelected;

  String? eventSubscribeErrorMessage;

  // EventsController({this.eventSchedule});

  EventSubscriberModel? eventSubscriberResponse;

  @override
  void onInit() {
    super.onInit();
  }

  setEventSelected(EventModel event) {
    eventSelected = event;
    update(['event-subscribe']);
  }

  Future<void> getEventSchedules() async {
    eventSchedulesState = NetworkState.loading;
    if (eventSchedules.isNotEmpty) {
      eventSchedules = [];
    }

    try {
      String apiKey = (await getApiKey())!;
      final data = await EventsRepository().getEventSchedules(apiKey);
      if (data['status'] == '200') {
        data['response']['events'].forEach((datum) {
          EventScheduleModel eventScheduleModel =
              EventScheduleModel.fromJson(datum);

          if (eventScheduleModel.upcomingEvents!.length > 0 &&
              eventScheduleModel.isDisabled == false) {
            eventSchedules.add(eventScheduleModel);
          }
        });

        // Sort eventSchedules by the soonest upcoming event's scheduledAt
        eventSchedules.sort((a, b) {
          DateTime? aDate = a?.upcomingEvents?.first.scheduledAt;
          DateTime? bDate = b?.upcomingEvents?.first.scheduledAt;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        eventSchedulesState = NetworkState.loaded;
      } else {
        eventSchedulesState = NetworkState.error;
      }
    } catch (error) {
      eventSchedulesState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getEventScheduleDetails(String eventScheduleId) async {
    eventScheduleDetailState = NetworkState.loading;
    update(['event-details']);

    try {
      String apiKey = (await getApiKey())!;
      final data = await EventsRepository()
          .getEventScheduleDetails(apiKey, eventScheduleId);
      if (data['status'] == '200') {
        List? eventsResponse = data['response']['events'];
        if (eventsResponse != null && eventsResponse.length == 1) {
          eventSchedule = EventScheduleModel.fromJson(eventsResponse[0]);
          eventScheduleDetailState = NetworkState.loaded;
        } else {
          eventScheduleDetailState = NetworkState.error;
        }
      } else {
        eventScheduleDetailState = NetworkState.error;
      }
    } catch (error) {
      eventScheduleDetailState = NetworkState.error;
    } finally {
      update(['event-details']);
    }
  }

  Future<void> subscribeEvent(String eventId) async {
    eventSubscribeState = NetworkState.loading;
    update(['event-subscribe']);

    try {
      String apiKey = (await getApiKey())!;
      final data = await EventsRepository().subscribeEvent(eventId, apiKey);
      if (data['status'] == '200') {
        eventSubscriberResponse =
            EventSubscriberModel.fromJson(data['response']);

        eventSubscribeState = NetworkState.loaded;
      } else {
        eventSubscribeErrorMessage =
            getErrorMessageFromResponse(data["response"]);
        eventSubscribeState = NetworkState.error;
      }
    } catch (error) {
      eventSubscribeState = NetworkState.error;
      eventSubscribeErrorMessage = 'Something went wrong. Please try again';
    } finally {
      update(['event-subscribe']);
    }
  }

  resetEventSubscribeStates() {
    eventSubscribeState = NetworkState.loaded;
    eventSubscribeErrorMessage = null;
    eventSelected = null;
    update(['event-subscribe']);
  }
}
