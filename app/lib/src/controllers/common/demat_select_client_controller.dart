import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

enum SelectedClientsUpdateType { Add, Remove }

class DematSelectClientController extends GetxController {
  List<Client>? recentClients = [];
  List<Client>? searchClients = [];

  List<Client> selectedClients = [];
  Client? lastSelectedClient;

  String searchQuery = '';
  String searchErrorMessage = '';

  NetworkState searchState = NetworkState.cancel;

  Timer? _debounce;

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    getRecentClients();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getRecentClients() async {
    try {
      searchState = NetworkState.loading;
      update();

      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;
      String? agentExternalId = await getAgentExternalId();

      final QueryResult response = await (ClientListRepository()
          .queryClientData(agentId.toString(), false, false, apiKey,
              limit: 20, requestAgentId: agentExternalId));

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        searchErrorMessage = "Something went wrong";
        searchState = NetworkState.error;
      } else {
        ClientListModel clientListModel = ClientListModel.fromJson(
          response.data!['hydra'],
        );
        recentClients = clientListModel.clients;
        searchState = NetworkState.loaded;

        // If lastSelected is not null, update recentClients list
        // with lastSelected as the first element
        // if (lastSelectedClient != null) {
        //   addLastSelectedToRecentClients(lastSelectedClient);
        // }
      }
    } catch (error) {
      LogUtil.printLog(error);
      searchErrorMessage = "Something went wrong";

      searchState = NetworkState.error;
    } finally {
      update();
    }
  }

  void onClientSearch(String query) {
    if (query.isEmpty) {
      // searchClients = [];
      // searchQuery = query;

      // resetSelectedClient();

      _debounce!.cancel();
      refetchRecentClients();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          // resetSelectedClient();
          searchQuery = query;

          if (query.isNotEmpty) {
            getSearchClient(query);
          } else {
            searchClients = [];
          }

          update();
        },
      );
    }
  }

  Future<void> getSearchClient(String query) async {
    if (query.isNullOrEmpty && recentClients.isNullOrEmpty) {
      return;
    }
    try {
      searchState = NetworkState.loading;
      update();

      List<Client>? clientsFound = [];

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();
      String? agentExternalId = await getAgentExternalId();

      // If no search query, then use the recent client list
      if (query.isEmpty) {
        clientsFound = recentClients;
      } else {
        final response = await ClientListRepository().queryClientData(
            agentId.toString(), false, false, apiKey!,
            query: query, requestAgentId: '', limit: 20, offset: 0);

        if (!response.hasException) {
          ClientListModel clientSearchList =
              ClientListModel.fromJson(response.data['hydra']);

          clientsFound.addAll(clientSearchList.clients!);
        }
      }

      searchClients = clientsFound;
      update();
    } catch (error) {
      searchErrorMessage = "Something went wrong";
      searchState = NetworkState.error;
    } finally {
      searchState = NetworkState.loaded;
      update();
    }
  }

  updateSelectedClients(Client client, SelectedClientsUpdateType updateType) {
    if (updateType == SelectedClientsUpdateType.Add) {
      selectedClients.clear();
      selectedClients.add(client);
    } else {
      selectedClients.removeWhere(
          (Client existingClient) => existingClient.taxyID == client.taxyID);
    }

    update();
  }

  refetchRecentClients() {
    searchClients = [];
    searchQuery = '';
    searchController.text = '';
    getRecentClients();
  }
}
