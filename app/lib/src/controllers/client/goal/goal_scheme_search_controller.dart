import 'dart:async';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalSchemeSearchController extends GetxController {
  String? amcCode;

  List<SchemeMetaModel> fundsResult = [];
  NetworkState fundsState = NetworkState.cancel;

  String searchText = '';
  TextEditingController searchFundController = TextEditingController();

  SwitchFundType switchFundType;

  Timer? _debounce;
  FocusNode searchBarFocusNode = FocusNode();

  GoalSchemeSearchController({this.amcCode, required this.switchFundType});

  void onInit() {
    if (switchFundType == SwitchFundType.SwitchIn) {
      getFunds();
    }
    super.onInit();
  }

  onFundSearch(String query) {
    if (query.isEmpty) {
      searchText = query;
      getFunds();

      // update(['search', 'funds']);
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

          // update(['search']);
        },
      );
    }
  }

  Future<void> getFunds() async {
    fundsResult = [];
    fundsState = NetworkState.loading;
    update(['search']);

    try {
      String? apiKey = await getApiKey();

      Map filters = {};

      if (amcCode?.isNotNullOrEmpty ?? false) {
        filters["amc"] = amcCode;
      }

      final response = await StoreRepository().searchMutualFunds(
        apiKey: apiKey,
        query: searchText,
        filters: filters,
        limit: 10,
        offset: 0,
      );

      if (response['status'] == "200") {
        List result = response['response']['data'];

        result.forEach((e) {
          SchemeMetaModel schemeModel = SchemeMetaModel.fromJson(e);
          if (switchFundType == SwitchFundType.SwitchIn &&
              schemeModel.isSwitchInAllowed) {
            fundsResult.add(schemeModel);
          }
        });

        fundsState = NetworkState.loaded;
      } else {
        fundsState = NetworkState.error;
      }
    } catch (error) {
      fundsState = NetworkState.error;
    } finally {
      update(['search']);
    }
  }
}
