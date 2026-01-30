import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';
import 'package:path_provider/path_provider.dart';

class UniversalSearchController extends GetxController {
  ApiResponse searchResponse = ApiResponse();

  TextEditingController? searchController;
  Timer? _debounce;
  String searchText = '';
  late FocusNode searchBarFocusNode;

  UniversalSearchResultModel? searchResult;

  List<UniversalSearchDataModel> searchResultList = [];

  File? recentSearchCacheFile;
  List<String> recentSearches = [];
  List<String> tempRecentSearches = [];

  NetworkState recentClientsState = NetworkState.cancel;
  List<Client> clients = [];

  UniversalSearchController();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/recent_search.json');
  }

  @override
  void onInit() async {
    searchController = TextEditingController();
    searchBarFocusNode = FocusNode();

    getRecentClients();

    super.onInit();
  }

  @override
  void onReady() async {
    try {
      recentSearchCacheFile = await _localFile;
      String jsonData = await recentSearchCacheFile!.readAsString();
      List<dynamic> data = json.decode(jsonData);
      data.forEach((key) {
        recentSearches.add(key);
      });
      update();
      print(data);
    } catch (error) {
      print(error);
    }
    super.onReady();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    searchBarFocusNode.dispose();
    super.dispose();
  }

  /// Universal Search
  Future<dynamic> universalSearch(String query) async {
    searchResponse.state = NetworkState.loading;
    update();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (query.isEmpty) {
          clearSearchBar();
          return null;
        }
        fetchUniversalSearchAPI(query);
      },
    );
  }

  Future<void> fetchUniversalSearchAPI(String query) async {
    searchResultList.clear();
    tempRecentSearches.add(query);
    try {
      String apiKey = await getApiKey() ?? '';

      final payload = {
        "q": query,
        "per_page": "2",
        "limit": "2",
        "pt": "universal_search",
        "platform": "partner-app",
      };

      final response =
          await CommonRepository().universalSearch(apiKey, payload);

      if (response['status'] == '200') {
        Map<String, dynamic> json = response["response"];
        // List<UniversalSearchResultModel> universalSearchUnSortedList = [];
        List<UniversalSearchDataModel> universalSearchUnSortedList = [];
        json.entries.forEach((entry) {
          UniversalSearchDataModel? searchModel =
              UniversalSearchResultModel.initialiseSearchDataModel(
            entry.key,
            entry.value,
          );
          if ((searchModel?.data ?? []).isNotNullOrEmpty) {
            universalSearchUnSortedList.add(searchModel!);
          }
        });

        universalSearchUnSortedList
            .sort((UniversalSearchDataModel a, UniversalSearchDataModel b) {
          return a.meta!.order!.compareTo(b.meta!.order!);
        });

        searchResultList =
            List<UniversalSearchDataModel>.from(universalSearchUnSortedList);

        searchResponse.state = NetworkState.loaded;
      } else {
        searchResponse.state = NetworkState.error;
      }
    } catch (error) {
      print(error);

      searchResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getRecentClients({
    bool isRecents = false,
  }) async {
    clients.clear();
    recentClientsState = NetworkState.loading;
    update([GetxId.clients]);
    try {
      List<Client>? recentClientsCache = await getRecentClientCache();

      if (recentClientsCache.isNotNullOrEmpty) {
        clients.addAll(recentClientsCache!);
        recentClientsState = NetworkState.loaded;
        return;
      }

      String agentExternalId = await getAgentExternalId() ?? '';
      int agentId = await getAgentId() ?? 0;
      String apiKey = await getApiKey() ?? '';

      QueryResult response = await ClientListRepository().queryClientData(
          agentId.toString(), false, false, apiKey,
          limit: 4, offset: 0, requestAgentId: agentExternalId);

      if (!response.hasException) {
        final result = ClientListModel.fromJson(response.data!['hydra']);
        clients.addAll(result.clients!);

        recentClientsState = NetworkState.loaded;
      }
    } catch (error) {
      print('error==>${error.toString()}');
    } finally {
      update([GetxId.clients]);
    }
  }

  Future<List<Client>?> getRecentClientCache() async {
    List<Client> recentClients = [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File file = File('$path/recent_clients.json');
      String jsonData = await file.readAsString();
      if (jsonData.isNullOrEmpty) {
        return null;
      } else {
        Map<String, dynamic> data = json.decode(jsonData);
        data['clients'].forEach((clientJson) {
          recentClients.add(Client.fromJson(clientJson));
        });
        return recentClients;
      }
    } catch (error) {
      return null;
    }
  }

  void clearSearchBar() {
    searchText = "";
    searchController!.clear();
    searchResponse.state = NetworkState.cancel;

    if (tempRecentSearches.isNotEmpty) {
      moveTempSearchToRecentSearch();
    }

    update();
  }

  void moveTempSearchToRecentSearch() {
    try {
      String? recentSearch = tempRecentSearches.reduce((a, b) {
        return a.length > b.length ? a : b;
      });
      if (recentSearch.isNotNullOrEmpty) {
        updateRecentSearch(recentSearch);
      }
      tempRecentSearches.clear();
    } catch (error) {
      print(error);
    }
  }

  void updateRecentSearch(String recentSearch) {
    if (!recentSearches.contains(recentSearch)) {
      recentSearches.insert(0, recentSearch);
    }
  }
}
