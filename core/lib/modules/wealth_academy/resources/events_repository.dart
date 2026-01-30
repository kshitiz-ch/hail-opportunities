import 'package:api_sdk/api_collection/wealth_academy_api.dart';

class EventsRepository {
  Future<dynamic> getEventSchedules(
    String apiKey,
  ) async {
    final response = await WealthAcademyAPI.getEventSchedules(apiKey);

    return response;
  }

  Future<dynamic> getEventScheduleDetails(
      String apiKey, String eventScheduleId) async {
    final response =
        await WealthAcademyAPI.getEventScheduleDetails(apiKey, eventScheduleId);

    return response;
  }

  Future<dynamic> subscribeEvent(
    String eventId,
    String apiKey,
  ) async {
    final response = await WealthAcademyAPI.subscribeEvent(eventId, apiKey);

    return response;
  }

  Future<dynamic> getSalesPlanCreatives(String salesPlanId) async {
    final response = await WealthAcademyAPI.getSalesPlanCreatives(salesPlanId);

    return response;
  }
}
