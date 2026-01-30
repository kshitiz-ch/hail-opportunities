import 'dart:async';
import 'dart:convert';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MfSearchController extends GetxController {
  NetworkState? searchState;

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  FocusNode focusNode = FocusNode();
  bool isSearchInFocus = false;

  List<SchemeMetaModel> fundsResult = [];

  Timer? _debounce;

  bool get showSearchView => isSearchInFocus || searchText.isNotEmpty;

  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      isSearchInFocus = focusNode.hasFocus;
      update();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void onFundSearch(String query) {
    if (query.isEmpty) {
      searchText = query;
      getFunds();

      update();
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchText = query;

          getFunds();

          update();
        },
      );
    }
  }

  Future<void> getFunds({bool isRetry = false}) async {
    fundsResult = [];
    searchState = NetworkState.loading;

    try {
      String? apiKey = await getApiKey() ?? '';

      final payload = {
        "q": searchText,
        "per_page": "10",
        "pt": "mffunds",
        "platform": "partner-app",
        "filters": jsonEncode([
          {"key": "fund_type", "operation": "eq", "value": "[E,D,H,C,O]"}
        ])
      };
      final response =
          await CommonRepository().universalSearch(apiKey, payload);

      if (response['status'] == "200") {
        List data = response['response']['mf_funds']['data'];

        data.forEach((e) {
          fundsResult.add(
            SchemeMetaModel.fromJson(e),
          );
        });
        searchState = NetworkState.loaded;
      } else {
        searchState = NetworkState.error;
      }
    } catch (error) {
      searchState = NetworkState.error;
    } finally {
      update();
    }
  }

  void clearSearchBar() {
    searchText = "";
    searchController.clear();
    update();
  }

  void hideSearchView() {
    searchText = "";
    searchController.clear();
    focusNode.unfocus();
    update();
  }
}
