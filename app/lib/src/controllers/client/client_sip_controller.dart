import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/base_sip_model.dart';
import 'package:core/modules/clients/models/sip_detail_model.dart';
import 'package:core/modules/clients/models/ticket_response_model.dart';
import 'package:core/modules/clients/models/transaction_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientSipController extends GetxController {
  String? apiKey = '';
  int? agentId;

  ApiResponse sipListResponse = ApiResponse();
  ApiResponse sipDetailResponse = ApiResponse();
  ApiResponse pauseResumeSipResponse = ApiResponse();
  ApiResponse sipVersion = ApiResponse();
  ApiResponse sipOrder = ApiResponse();

  late ClientListRepository clientListRepository;
  Client client;
  BaseSipModel? baseSipModel;
  SipDetailModel? baseSipDetailModel;
  BaseSip? selectedSip;
  List<ClientOrderModel>? selectedSipOrders = [];
  TicketResponseModel? pauseResumeResponse;

  List<BaseSip>? activeBaseSipList;

  TabController? tabController;

  // Edit SIP fields
  RxList<int> allowedSipDays = RxList<int>();
  late bool isSelectedSipActive;

  bool showActiveSip = true;
  int pageNo = 0;
  int limit = 20;
  bool isPaginating = false;
  bool isPagesRemaining = true;

  ScrollController? scrollController;

  ClientSipController({required this.client});

  @override
  void onInit() {
    clientListRepository = ClientListRepository();
    scrollController = ScrollController();
    scrollController?.addListener(() {
      handlePagination();
    });
    allowedSipDays = Get.find<CommonController>().allowedSipDays;
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();
    getClientSIPList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getSipOrderDetails(String goalId) async {
    // for testing in dev
    // goalId = 'PGNsYXNzICdhY2NvdW50cy5tb2RlbHMuR29hbCc+OjEwMzU0';
    // client.taxyID = '3d6598a3-2af2-4b20-93b8-4d8dbad6e7db';
    selectedSipOrders = [];
    sipOrder.state = NetworkState.loading;
    sipOrder.state = NetworkState.loading;
    // update();

    try {
      QueryResult response = await clientListRepository.getSIPOrders(
        apiKey!,
        client.taxyID!,
        goalId,
      );

      if (response.hasException) {
        sipOrder.message = response.exception!.graphqlErrors[0].message;
        sipOrder.state = NetworkState.error;
      } else {
        selectedSipOrders = (response.data!['taxy']['orders'] as List)
            .map<ClientOrderModel>(
              (json) => ClientOrderModel.fromJson(json),
            )
            .toList();
        sipOrder.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipOrder.message = genericErrorMessage;
      sipOrder.state = NetworkState.error;
    } finally {
      // update();
    }
  }

  /// get sip list from the API
  Future<dynamic> getClientSIPList() async {
    sipListResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = {
        'userId': client.taxyID!,
      };
      QueryResult response = await clientListRepository.getSIPList(
        apiKey!,
        client.taxyID!,
        payload,
      );

      if (response.hasException) {
        sipListResponse.message = response.exception!.graphqlErrors[0].message;
        sipListResponse.state = NetworkState.error;
      } else {
        baseSipModel = BaseSipModel();
        baseSipModel!.baseSips = (response.data!['taxy']['sipMetas'] as List)
            .map((json) => BaseSip.fromJson(json))
            .toList();

        activeBaseSipList = baseSipModel?.baseSips
            ?.where((element) =>
                element.isSipActive == true && element.pauseDate == null)
            .toList();
        sipListResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipListResponse.message = genericErrorMessage;
      sipListResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getClientSIPDetails(
    String baseSipId,
  ) async {
    sipDetailResponse.state = NetworkState.loading;
    if (!isPaginating) {
      baseSipDetailModel = null;
      pageNo = 0;
    }
    update();
    if (selectedSip?.goal?.id != null) {
      await getSipOrderDetails(selectedSip!.goal!.id!);
    }
    try {
      // userId : client taxy ID
      // baseSipId: received from the sip list query
      // filterDateForPast: one year from today, ex; 2022-04-19T08:44:11.570Z
      // filterDateForUpcoming: today date, ex; 2023-04-19T08:44:11.570Z
      // toDate: yesterdays date, ex; 2023-04-18T08:44:11.569Z
      // limit: 20 (upcoming sips)
      int offset = ((pageNo + 1) * limit) - limit;
      Map<String, dynamic> payload = {
        'userId': client.taxyID!,
        'baseSipId': baseSipId,
        'filterDateForUpcoming': DateTime.now().toIso8601String(),
        'filterDateForPast': DateTime.now()
            .subtract(Duration(days: 365 * 2 * (pageNo + 1)))
            .toIso8601String(),
        'toDate': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'limit': 20,
        'offset': offset,
      };
      QueryResult response = await clientListRepository.getSIPDetails(
        apiKey!,
        client.taxyID!,
        payload,
      );

      if (response.hasException) {
        sipDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
        sipDetailResponse.state = NetworkState.error;
      } else {
        final responseData = SipDetailModel.fromJson(response.data!['taxy']);

        if (!isPaginating || baseSipDetailModel == null) {
          baseSipDetailModel = responseData;
        } else {
          // update past sips
          if (baseSipDetailModel!.pastSips.isNullOrEmpty) {
            baseSipDetailModel!.pastSips = responseData.pastSips;
          } else {
            baseSipDetailModel!.pastSips!
                .addAll(responseData.pastSips!.toList());
          }

          // update upcoming sips
          // if (baseSipDetailModel!.upcomingSips.isNullOrEmpty) {
          //   baseSipDetailModel!.upcomingSips = responseData.upcomingSips;
          // } else {
          //   baseSipDetailModel!.upcomingSips!
          //       .addAll(responseData.upcomingSips!.toList());
          // }
        }

        final isResponseNullOrEmpty = responseData.pastSips.isNullOrEmpty;
        final isReponseSizeLessThanLimit =
            responseData.pastSips!.length < limit;
        // if the response has no data or has data less than limit it means no more data is present
        // so pagination not required
        isPagesRemaining =
            !(isResponseNullOrEmpty || isReponseSizeLessThanLimit);

        sipDetailResponse.state = NetworkState.loaded;
        LogUtil.printLog('past sip ==> ${responseData.pastSips!.length}');
        LogUtil.printLog('isPagesRemaining ==> ${isPagesRemaining}');
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipDetailResponse.message = genericErrorMessage;
      sipDetailResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void toggleActiveSIPButton() {
    showActiveSip = !showActiveSip;
    update();
  }

  void handlePagination() {
    if (scrollController!.hasClients) {
      bool isScrolledToBottom = scrollController!.position.maxScrollExtent <=
          scrollController!.position.pixels;
      // bool isPagesRemaining =
      //     (proposalMetaData.totalCount! / (limit * (page + 1))) > 1;

      if (isScrolledToBottom && isPagesRemaining && !isPaginating) {
        pageNo += 1;
        isPaginating = true;
        update();
        if (selectedSip?.baseSipId != null)
          getClientSIPDetails(selectedSip?.id ?? '').then(
            (value) {
              isPaginating = false;
              update();
            },
          );
      }
    }
  }

  void tabChangeScrollToTop() {
    if (scrollController!.hasClients) {
      scrollController!.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }
}
