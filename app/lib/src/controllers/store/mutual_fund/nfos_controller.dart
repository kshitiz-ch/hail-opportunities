import 'dart:math';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/models/mf/nfo_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:graphql/client.dart';

class NfosController extends GetxController {
  ApiResponse nfoListResponse = ApiResponse();
  ApiResponse nfoMinSipAmountResponse = ApiResponse();

  ScreenerModel? screener;
  final List<NfoModel> nfos = [];
  ScrollController scrollController = ScrollController();

  MetaDataModel metaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
  bool isPaginating = false;

  double nfoMinSipAmount = 0;

  NfosController({this.screener});

  void onInit() {
    getNfos();
    scrollController.addListener(() {
      handlePagination();
    });
    super.onInit();
  }

  Future<void> getNfos() async {
    if (!isPaginating) {
      nfos.clear();
    }

    nfoListResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      int offset = ((metaData.page! + 1) * metaData.limit!) - metaData.limit!;
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String uri =
          '${screener?.uri}?limit=20&offset=${offset}&is_payment_allowed=true&close_date_gt=$currentDate';

      var response = await StoreRepository().getWealthySelectFunds(apiKey, uri);

      if (response["status"] == "200") {
        metaData.totalCount =
            response?['response']?['meta']?['total_count'] ?? 0;
        List data = response?['response']?['results'] as List;

        data.forEach((e) {
          nfos.add(NfoModel.fromJson(e));
        });
        nfoListResponse.state = NetworkState.loaded;
      } else {
        nfoListResponse.state = NetworkState.error;
      }
    } catch (error) {
      nfoListResponse.state = NetworkState.error;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getNfoMinSipAmount(String wschemecode) async {
    nfoMinSipAmount = 0;
    nfoMinSipAmountResponse.state = NetworkState.loading;
    update([GetxId.detail]);

    try {
      String apiKey = await getApiKey() ?? '';

      QueryResult response =
          await StoreRepository().getSchemeData(apiKey, null, wschemecode);

      if (!response.hasException) {
        StoreFundAllocation fundsResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        nfoMinSipAmount = fundsResult.schemeMetas!.first.minSipDepositAmt ?? 0;
        nfoMinSipAmountResponse.state = NetworkState.loaded;
      } else {
        nfoMinSipAmountResponse.state = NetworkState.error;
      }
    } catch (error) {
      nfoMinSipAmountResponse.state = NetworkState.error;
    } finally {
      update([GetxId.detail]);
    }
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      bool isPagesRemaining = ((metaData.totalCount ?? 0) /
              (metaData.limit! * (metaData.page! + 1))) >
          1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          nfoListResponse.state != NetworkState.loading) {
        metaData.page = metaData.page! + 1;
        isPaginating = true;
        // update();
        getNfos();
      }
    }
  }
}
