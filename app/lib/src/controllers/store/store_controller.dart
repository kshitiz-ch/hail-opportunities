import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:core/main.dart';
import 'package:core/modules/store/models/popular_products_model.dart'
    hide ProductType;
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> defaultProductSectionOrder = [
  StoreProductSections.MF_PORTFOLIOS,
  StoreProductSections.WEALTHY_PRODUCTS,
  StoreProductSections.INSURANCE,
  StoreProductSections.MF_FUNDS
];

enum StoreLoaderType { PORTFOLIO, FUND, PREIPO }

class StoreController extends GetxController {
  // Fields
  PopularProductsModel popularProductsResult = PopularProductsModel();
  List<String> productSectionOrder = defaultProductSectionOrder;

  NetworkState? popularProductsState;
  NetworkState? storeProductState;

  String? apiKey = '';

  Client? selectedClient;

  String? popularProductsErrorMessage = '';
  String? storeProductErrorMessage = '';

  dynamic storeProductResult;

  StoreController({this.selectedClient});

  @override
  void onInit() {
    popularProductsState = NetworkState.loading;
    storeProductState = NetworkState.loading;

    super.onInit();
  }

  @override
  void onReady() async {
    final SharedPreferences sharedPreferences = await prefs;
    apiKey = sharedPreferences.getString('apiKey');

    getPopularProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get Popular products
  Future<dynamic> getPopularProducts({bool isRetry = false}) async {
    if (isRetry) {
      popularProductsState = NetworkState.loading;
      update(['popular-products']);
    }

    try {
      Map<String, dynamic> response = await (StoreRepository()
          .getPopularProducts(apiKey!, StoreProductPage.POPULAR_PRODUCTS));

      if (response['status'] == '200') {
        productSectionOrder = [];
        Map<String, dynamic> data = response['response'];

        data.forEach((key, value) {
          productSectionOrder.add(key);
        });

        LogUtil.printLog('products ${data['wealthy_products']}');

        // TODO: Temporary
        List wealthyProductsJson = data['wealthy_products'] as List;
        wealthyProductsJson.insert(0, {
          "product_variant": "demat",
          "product_type": "demat",
          "category": "Invest",
          "title": "Broking Demat Account",
        });

        Map<String, dynamic> products = {
          StoreProductSections.INSURANCE: {'products': data['insurance']},
          StoreProductSections.MF_PORTFOLIOS: {
            'products': data['mf_portfolios']
          },
          StoreProductSections.MF_FUNDS: {'products': data['mf_funds']},
          StoreProductSections.WEALTHY_PRODUCTS: {
            'products': wealthyProductsJson
          }
        };

        popularProductsResult = PopularProductsModel.fromJson(products);
        popularProductsState = NetworkState.loaded;
      } else {
        popularProductsErrorMessage = response['response'];
        popularProductsState = NetworkState.error;
        productSectionOrder = defaultProductSectionOrder;
      }
    } catch (error) {
      productSectionOrder = defaultProductSectionOrder;
      popularProductsErrorMessage = 'Something went wrong';
      popularProductsState = NetworkState.error;
    } finally {
      update(['popular-products']);
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
}
