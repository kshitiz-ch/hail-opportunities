import 'dart:async';

import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/main.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/models/store_search_results_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreSearchController extends GetxController {
  NetworkState? searchState;
  NetworkState? storeFundState;
  NetworkState? storeProductState;

  TextEditingController? searchController;
  Timer? _debounce;
  String? apiKey = '';
  String searchText = '';
  FocusNode? searchBarFocusNode;

  String? storeProductErrorMessage = '';
  String storeFundErrorMessage = '';

  dynamic storeProductResult;
  Map<String, List<StoreSearchResultModel>> searchResult = {};
  StoreFundAllocation? storeFundResult;

  @override
  void onInit() async {
    searchController = TextEditingController();
    searchState = NetworkState.cancel;
    searchBarFocusNode = FocusNode();
    final SharedPreferences sharedPreferences = await prefs;
    apiKey = sharedPreferences.getString('apiKey');
    super.onInit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    searchBarFocusNode?.dispose();
    super.dispose();
  }

  /// Search Products
  Future<dynamic> searchProducts(String query) async {
    searchState = NetworkState.loading;
    update(['search']);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (query.isEmpty) {
          clearSearchBar();
          return null;
        }
        getSearchProducts(query);
      },
    );
  }

  Future<void> getSearchProducts(String query) async {
    try {
      final response =
          await StoreRepository().searchStoreProducts(apiKey!, query);

      if (response['status'] == '200') {
        final results = StoreSearchResultsModel.fromJson(response['response']);

        // Empty search result before using new search result
        searchResult.clear();

        results.storeSearchResults!.forEach((result) {
          if (searchResult.containsKey(getProductTypeSearchCategoryKey(
            result.productType!.toLowerCase(),
          ))) {
            searchResult[getProductTypeSearchCategoryKey(
              result.productType!.toLowerCase(),
            )]!
                .add(result);
          } else {
            searchResult[getProductTypeSearchCategoryKey(
              result.productType!.toLowerCase(),
            )] = [result];
          }
        });

        searchState = NetworkState.loaded;
      } else {
        searchState = NetworkState.error;
      }
    } catch (err) {
      LogUtil.printLog(err);

      searchState = NetworkState.error;
    } finally {
      update(['search']);
    }
  }

  /// Fetch the Fund details using its wSchemeCode
  Future<void> getStoreFund(String wSchemeCode) async {
    storeFundState = NetworkState.loading;
    update([GetxId.storeProductDetail]);

    try {
      final QueryResult response =
          await StoreAPI.getSchemeData(apiKey!, null, wSchemeCode);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        storeFundErrorMessage = "Something went wrong";
        storeFundState = NetworkState.error;
      } else {
        storeFundResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);

        storeFundState = NetworkState.loaded;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      storeFundErrorMessage = "Something went wrong";
      storeFundState = NetworkState.error;
    } finally {
      update([GetxId.storeProductDetail]);
    }
  }

  /// Get specific Store product details
  Future<void> getStoreProduct(
    String category,
    String productType,
    String productTypeVariant,
  ) async {
    storeProductState = NetworkState.loading;
    update([GetxId.storeProductDetail]);

    try {
      Map<String, dynamic> response = await (StoreRepository().getStoreProduct(
        apiKey!,
        category,
        productType,
        productTypeVariant,
      ));

      if (response['status'] == '200') {
        storeProductResult = response['response']['products'].first;

        storeProductState = NetworkState.loaded;
        update([GetxId.storeProductDetail]);
      } else {
        storeProductErrorMessage = response['response'];
        storeProductState = NetworkState.error;
      }
    } catch (error) {
      storeProductErrorMessage = 'Something went wrong';
      storeProductState = NetworkState.error;
    } finally {
      update([GetxId.storeProductDetail]);
    }
  }

  void resetStoreProductState() {
    storeProductErrorMessage = '';
    storeFundErrorMessage = '';

    storeProductState = NetworkState.cancel;
    storeFundState = NetworkState.cancel;

    storeProductResult = null;
    storeFundState = NetworkState.cancel;

    update();
  }

  void clearSearchBar() {
    searchText = "";
    searchController!.clear();
    searchResult.clear();
    searchState = NetworkState.cancel;
    update(['search']);
  }
}
