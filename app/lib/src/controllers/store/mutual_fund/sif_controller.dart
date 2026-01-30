import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/models/mf/sif_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SifController extends GetxController {
  ApiResponse sifListResponse = ApiResponse();
  ScreenerModel? screener;
  List<SifModel> sifs = [];

  ScrollController scrollController = ScrollController();

  MetaDataModel metaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
  bool isPaginating = false;

  SifModel? selectedSif;
  ApiResponse sifDetailResponse = ApiResponse();

  SifController({this.screener});

  void onInit() {
    getSifs();
    scrollController.addListener(() {
      handlePagination();
    });
    super.onInit();
  }

  Future<void> getSifs() async {
    if (!isPaginating) {
      sifs.clear();
    }

    sifListResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';
      final offset = ((metaData.page + 1) * metaData.limit) - metaData.limit;

      final queryParam = '?limit=20&offset=${offset}&visible_on_store=true';

      final response =
          await StoreRepository().getSifProducts(apiKey, queryParam);

      if (response["status"] == "200") {
        metaData.totalCount = WealthyCast.toInt(
            response?['response']?['meta']?['total_count'] ?? 0);

        final data = WealthyCast.toList(response?['response']?['results']);

        data.forEach((e) {
          sifs.add(SifModel.fromJson(e));
        });

        sifListResponse.state = NetworkState.loaded;
      } else {
        sifListResponse.message =
            getErrorMessageFromResponse(response?['response']);
        sifListResponse.state = NetworkState.error;
      }
    } catch (error) {
      sifListResponse.message = genericErrorMessage;
      sifListResponse.state = NetworkState.error;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getSifDetails(String isin) async {
    sifDetailResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';
      final data = await StoreRepository().getSifDetail(apiKey, isin);

      if (data["status"] == "200") {
        selectedSif = SifModel.fromJson(data["response"]);
        sifDetailResponse.state = NetworkState.loaded;
      } else {
        sifDetailResponse.message =
            getErrorMessageFromResponse(data["response"]);
        sifDetailResponse.state = NetworkState.error;
      }
    } catch (error) {
      sifDetailResponse.message = genericErrorMessage;
      sifDetailResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      bool isPagesRemaining = ((metaData.totalCount ?? 0) /
              (metaData.limit * (metaData.page + 1))) >
          1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          sifListResponse.state != NetworkState.loading) {
        metaData.page = metaData.page + 1;
        isPaginating = true;
        // update();
        getSifs();
      }
    }
  }
}
