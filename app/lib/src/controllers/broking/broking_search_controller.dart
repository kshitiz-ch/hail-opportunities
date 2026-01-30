import 'dart:async';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class BrokingSearchController extends GetxController {
  TextEditingController clientSearchController = TextEditingController();
  Timer? _debounce;
  FocusNode searchBarFocusNode = FocusNode();
  ApiResponse clientSearch = ApiResponse();
  bool isInSearchMode = false;
  ClientListModel clientsResult = ClientListModel(clients: []);
  String? searchClientText;

  String? selectedClientId;

  @override
  void onInit() {
    clearSearchBar();
    super.onInit();
  }

  @override
  void dispose() {
    clientSearchController.dispose();
    super.dispose();
  }

  void clearSearchBar() {
    isInSearchMode = false;
    clientsResult = ClientListModel(clients: []);
    clientSearch = ApiResponse();
    searchClientText = null;
    selectedClientId = null;
    clientSearchController = TextEditingController();
    update();
  }

  /// Used for client search in both broking onboarding & activity screen
  Future<dynamic> search() async {
    isInSearchMode = true;
    clientSearch.state = NetworkState.loading;
    update();

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (searchClientText.isNullOrEmpty) {
          clearSearchBar();
          return null;
        }
        isInSearchMode = true;
        final apiKey = await getApiKey();
        final agentId = await getAgentId();
        try {
          QueryResult response = await ClientListRepository().queryClientData(
            agentId.toString(),
            false,
            false,
            apiKey!,
            query: searchClientText,
            limit: 20,
            offset: 0,
            requestAgentId: '',
          );

          if (response.hasException) {
            clientSearch.message = response.exception!.graphqlErrors[0].message;
            clientSearch.state = NetworkState.error;
          } else {
            clientsResult = ClientListModel.fromJson(response.data!['hydra']);
            clientSearch.state = NetworkState.loaded;
          }
        } catch (error) {
          clientSearch.message = genericErrorMessage;
          clientSearch.state = NetworkState.error;
        } finally {
          update();
        }
      },
    );
  }

  void updateSelectedClient(Client client) {
    isInSearchMode = false;
    this.selectedClientId = client.taxyID;
    clientSearchController.value = clientSearchController.value.copyWith(
      text: client.name,
      selection: TextSelection.collapsed(offset: client.name!.length),
    );
    searchBarFocusNode.unfocus();
    update();
  }
}
