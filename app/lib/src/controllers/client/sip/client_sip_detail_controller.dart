import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/clients/models/ticket_response_model.dart';
import 'package:core/modules/clients/models/transaction_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/transaction/models/mf_order_transaction_model.dart';
import 'package:core/modules/transaction/resources/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientSipDetailController extends GetxController {
  ClientListRepository clientListRepository = ClientListRepository();

  ScrollController scrollController = ScrollController();

  ApiResponse sipDetailResponse = ApiResponse();
  ApiResponse sipOrderResponse = ApiResponse();

  late Client client;
  List<MfOrderTransactionModel> sipTransactionList = [];
  List<ClientOrderModel>? selectedSipOrders = [];

  late TabController tabController;
  TicketResponseModel? pauseResumeResponse;

  MetaDataModel pastSipMeta = MetaDataModel();
  late SipUserDataModel selectedSip;

  bool isPaginating = false;

  ClientSipDetailController({required this.client, required this.selectedSip});

  @override
  void onInit() {
    getClientSIPDetails();
    scrollController.addListener(() {
      handlePagination();
    });
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<dynamic> getClientSIPDetails() async {
    sipDetailResponse.state = NetworkState.loading;
    if (!isPaginating) {
      sipTransactionList.clear();
      pastSipMeta.page = 0;
    }
    update();
    if (selectedSip.goalExternalId.isNotNullOrEmpty) {
      await getSipOrderDetails(selectedSip.goalExternalId!);
    }
    try {
      Map<String, dynamic> filters = {
        // sip transaction filter
        // 'order_type': '2',
        // 'source': 'W',
        'account__user_id__in': [client.taxyID],
        'goal_id': selectedSip.goalExternalId,
        // 'schemeorders__wschemecode':'',
        'sip_meta_id': selectedSip.sipMetaId,
      };

      int offset =
          ((pastSipMeta.page + 1) * pastSipMeta.limit) - pastSipMeta.limit;
      final payload = <String, dynamic>{
        'agentExternalIdList': [selectedSip.agentExternalId],
        'filters': jsonEncode(filters),
        'limit': pastSipMeta.limit,
        'offset': offset,
      };
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await TransactionRepository().getTransactions(
        apiKey,
        payload,
        'Sip Detail',
      );

      if (response.hasException) {
        sipDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
        sipDetailResponse.state = NetworkState.error;
      } else {
        final currentTransactionList = WealthyCast.toList((response
            .data?['taxy']['userMfOrders']['userTransactionOrderData']));
        currentTransactionList.forEach((e) {
          sipTransactionList.add(MfOrderTransactionModel.fromJson(e));
        });

        pastSipMeta.totalCount =
            WealthyCast.toInt(response.data?['taxy']['userMfOrders']['count']);

        sipDetailResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipDetailResponse.message = genericErrorMessage;
      sipDetailResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getSipOrderDetails(String goalId) async {
    // for testing in dev
    // goalId = 'PGNsYXNzICdhY2NvdW50cy5tb2RlbHMuR29hbCc+OjEwMzU0';
    // client.taxyID = '3d6598a3-2af2-4b20-93b8-4d8dbad6e7db';
    selectedSipOrders = [];
    sipOrderResponse.state = NetworkState.loading;
    // update();

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await clientListRepository.getSIPOrders(
        apiKey,
        client.taxyID!,
        goalId,
      );

      if (response.hasException) {
        sipOrderResponse.message = response.exception!.graphqlErrors[0].message;
        sipOrderResponse.state = NetworkState.error;
      } else {
        selectedSipOrders = (response.data!['taxy']['orders'] as List)
            .map<ClientOrderModel>(
              (json) => ClientOrderModel.fromJson(json),
            )
            .toList();
        sipOrderResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      sipOrderResponse.message = genericErrorMessage;
      sipOrderResponse.state = NetworkState.error;
    } finally {
      // update();
    }
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      final isPagesRemaining = (pastSipMeta.totalCount! /
              (pastSipMeta.limit * (pastSipMeta.page + 1))) >
          1;

      if (isScrolledToBottom && isPagesRemaining && !isPaginating) {
        pastSipMeta.page += 1;
        isPaginating = true;
        update();
        if (selectedSip.id != null)
          getClientSIPDetails().then(
            (value) {
              isPaginating = false;
              update();
            },
          );
      }
    }
  }
}
