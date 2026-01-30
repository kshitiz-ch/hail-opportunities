import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:core/modules/wealth_academy/resources/events_repository.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class EventDetailController extends GetxController {
  NetworkState eventScheduleDetailState = NetworkState.loaded;

  EventScheduleModel? eventSchedule;

  EventDetailController(this.eventSchedule) {
    if (eventSchedule?.name == null &&
        eventSchedule!.externalId.isNotNullOrEmpty) {
      getEventScheduleDetails(eventSchedule!.externalId!);
    }
  }

  Future<void> getEventScheduleDetails(String eventScheduleId) async {
    eventScheduleDetailState = NetworkState.loading;

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
      update();
    }
  }
}
