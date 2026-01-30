import 'dart:async';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/advisor/models/partner_tracker_metric_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';

class TrackerListController extends GetxController {
  late ClientListRepository clientListRepository;
  late StoreRepository storeRepository;

  ClientListModel? clientListModel;
  late ClientListModel clientSearchList;
  AdvisorVideoModel? trackerVideo;

  String searchQuery = '';

  List<TrackerModel> trackerRequests = [];
  List<Client> clientsSelected = [];

  List<TrackerUserModel> trackedClients = [];
  TrackerAggMetricsModel? trackerAggMetrics;

  ApiResponse getClientResponse = ApiResponse();
  ApiResponse getTrackerRequestResponse = ApiResponse();
  ApiResponse searchClientResponse = ApiResponse();
  ApiResponse trackerMetricResponse = ApiResponse();
  NetworkState? trackerVideoState;

  bool isTrackerListing;
  bool isClientListing;
  bool isTrackerVideoViewed = false;

  Timer? _debounce;

  String? apiKey;
  int? agentId;
  TextEditingController? searchController;

  ApiResponse clientPanResponse = ApiResponse();
  List<FamilyReportModel> familyReports = [];

  TrackerListController(
      {this.isTrackerListing = false, this.isClientListing = false}) {
    clientListRepository = ClientListRepository();
    storeRepository = StoreRepository();
    searchController = TextEditingController();
  }

  @override
  Future<void> onInit() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();
    if (isTrackerListing) {
      getTrackerMetrics();
      getTrackerRequests();
    } else if (isClientListing) {
      getClients();
    }
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
  }

  void getClients() async {
    try {
      getClientResponse.state = NetworkState.loading;
      update([GetxId.getClients]);
      agentId ??= await getAgentId();
      apiKey ??= await getApiKey();
      final response = await clientListRepository.queryClientData(
          agentId.toString(), false, false, apiKey!);
      clientListModel = ClientListModel.fromJson(response.data['hydra']);
      clientListModel!.clients!.removeWhere(
        (element) =>
            (element.email.isNullOrEmpty && element.mfEmail.isNullOrEmpty) ||
            (isMockEmail(element.email) || isMockEmail(element.mfEmail)),
      );
      getClientResponse.state = NetworkState.loaded;
    } catch (error) {
      getClientResponse.message = handleApiError(error) ?? genericErrorMessage;
      getClientResponse.state = NetworkState.error;
    } finally {
      update([GetxId.getClients]);
    }
  }

  void searchClient(query) async {
    try {
      searchClientResponse.state = NetworkState.loading;
      update([GetxId.searchClient]);
      final response = await clientListRepository.queryClientData(
          agentId.toString(), false, false, apiKey!,
          query: query, limit: 20, offset: 0);
      clientSearchList = ClientListModel.fromJson(response.data['hydra']);
      clientSearchList.clients!.removeWhere(
        (element) =>
            (element.email.isNullOrEmpty && element.mfEmail.isNullOrEmpty) ||
            (isMockEmail(element.email) || isMockEmail(element.mfEmail)),
      );

      searchClientResponse.state = NetworkState.loaded;
    } catch (error) {
      searchClientResponse.message =
          handleApiError(error) ?? genericErrorMessage;
      searchClientResponse.state = NetworkState.error;
    } finally {
      update([GetxId.searchClient]);
    }
  }

  void getTrackerMetrics() async {
    trackerMetricResponse.state = NetworkState.loading;
    update();
    try {
      String agentExternalId = await getAgentExternalId() ?? '';

      QueryResult response = await AdvisorRepository()
          .getPartnerTrackerMetrics(apiKey!, agentExternalId);
      if (!response.hasException) {
        if (response.data!["delta"]["partnersTrakerMetrics"] != null) {
          List usersJson =
              response.data!["delta"]["partnersTrakerMetrics"]["users"];
          usersJson.forEach((element) {
            trackedClients.add(TrackerUserModel.fromJson(element));
          });

          Map<String, dynamic> aggregatedMetricsJson = response.data!["delta"]
              ["partnersTrakerMetrics"]["aggregatedMetrics"];

          trackerAggMetrics =
              TrackerAggMetricsModel.fromJson(aggregatedMetricsJson);
          trackerMetricResponse.state = NetworkState.loaded;
        } else {
          trackerMetricResponse.state = NetworkState.loaded;
        }
      } else {
        trackerMetricResponse.message =
            response.exception!.graphqlErrors[0].message;
        trackerMetricResponse.state = NetworkState.error;
      }
    } catch (error) {
      trackerMetricResponse.message = genericErrorMessage;
      trackerMetricResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getClientPanDetails(String taxyId) async {
    clientPanResponse.state = NetworkState.loading;
    familyReports.clear();
    update(['tracker']);

    try {
      QueryResult response =
          await ClientListRepository().getClientTrackerValue(apiKey!, taxyId);

      if (response.hasException) {
        clientPanResponse.message =
            response.exception!.graphqlErrors[0].message;
        clientPanResponse.state = NetworkState.error;
      } else {
        List familyReportsJson = WealthyCast.toList(
            response.data?['phaser']?['familyOverview']?['familyReport']);
        familyReportsJson.forEach((familyReportJson) {
          familyReports.add(FamilyReportModel.fromJson(familyReportJson));
        });
        clientPanResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      clientPanResponse.message = 'Something went wrong';
      clientPanResponse.state = NetworkState.error;
    } finally {
      update(['tracker']);
    }
  }

  void getTrackerRequests() async {
    try {
      getTrackerRequestResponse.state = NetworkState.loading;
      update();
      var response = await storeRepository.getTrackerRequest(apiKey!);
      if (response['status'] == '200') {
        var result = response['response'];
        if (result is List) {
          trackerRequests.clear();
          result.forEach(
            (request) {
              trackerRequests.add(
                TrackerModel.fromJson(request),
              );
            },
          );
        }
        getTrackerRequestResponse.state = NetworkState.loaded;
      } else {
        getTrackerRequestResponse.message =
            getErrorMessageFromResponse(response);
        getTrackerRequestResponse.state = NetworkState.error;
      }
    } catch (error) {
      getTrackerRequestResponse.message =
          handleApiError(error) ?? genericErrorMessage;
      getTrackerRequestResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void onClientSelect(Client selectedClient) {
    int index = 0;
    bool isClientFound = false;
    for (Client client in clientsSelected) {
      if (client.taxyID == selectedClient.taxyID) {
        isClientFound = true;
        clientsSelected.removeAt(index);
        break;
      }
      index += 1;
    }
    if (!isClientFound) {
      if (clientsSelected.length < 10) {
        clientsSelected.add(selectedClient);
      } else {
        showToast(
            text:
                'You can only send tracker request to upto 10 clients at a time');
      }
    }
    update();
  }

  bool isClientSelected(selectedClient) {
    bool isClientFound = false;
    for (Client client in clientsSelected) {
      if (client.taxyID == selectedClient.taxyID) {
        isClientFound = true;
        break;
      }
    }
    return isClientFound;
  }

  onClientSearch(String query) {
    if (query.isEmpty) {
      clientSearchList.clients = [];
      searchQuery = query;

      update([GetxId.searchClient]);
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchQuery = query;

          if (query.isNotEmpty) {
            searchClient(query);
          } else {
            clientSearchList.clients = [];
          }

          update([GetxId.searchClient]);
        },
      );
    }
  }

  resetSearch() {
    clientListModel = null;
    searchController!.clear();
  }

  resetSelectedClients() {
    clientsSelected.clear();
  }

  Future<void> getTrackerVideo() async {
    try {
      var videoResponse = await AdvisorOverviewRepository()
          .getProductVideos(ProductVideosType.TRACKER);
      if (videoResponse['status'] == '200') {
        var video = videoResponse['response'];
        trackerVideo = AdvisorVideoModel.fromJson(video);

        isTrackerVideoViewed =
            await checkProductVideoViewed(ProductVideosType.TRACKER);

        trackerVideoState = NetworkState.loaded;
      } else {
        trackerVideoState = NetworkState.error;
      }
    } catch (error) {
      trackerVideoState = NetworkState.error;
    } finally {
      update(['tracker-video']);
    }
  }
}
