import 'dart:async';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:core/modules/broking/models/broking_detail_model.dart';
import 'package:core/modules/broking/models/broking_onboarding_model.dart';
import 'package:core/modules/broking/resources/broking_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class BrokingController extends GetxController {
  // Fields used for BrokingOnboardingScreen & BrokingScreen
  ApiResponse brokingOnboardingResponse = ApiResponse();
  List<BrokingOnboardingModel> brokingOnboardingList = [];
  late MetaDataModel brokingOnboardingDataMeta;
  ScrollController onboardingScrollController = ScrollController();
  bool isOnboardingPaginating = false;

  ApiResponse brokingUrlResponse = ApiResponse();

  PartnerOfficeModel? partnerOfficeModel;

  Map<String, Map> clientFilterPayload = {};
  String? selectedFilter;
  String? savedFilter;

  ApiResponse brokingDetailResponse = ApiResponse();
  BrokingDetailModel? brokingDetailModel;

  BrokingGraphType selectedGraphDataType = isEmployeeLoggedIn()
      ? BrokingGraphType.trades
      : BrokingGraphType.brokerage;

  void onInit() {
    super.onInit();
    updateClientFilterPayload();
    initBrokingOnboarding();
    getBrokingDetails();
  }

  @override
  void dispose() {
    if (onboardingScrollController != null) {
      onboardingScrollController.dispose();
    }
    super.dispose();
  }

  // used for BrokingOnboardingScreen & BrokingScreen
  void initBrokingOnboarding() {
    brokingOnboardingResponse = ApiResponse();
    brokingOnboardingList = [];
    brokingOnboardingDataMeta =
        MetaDataModel(limit: 20, page: 0, totalCount: 0);
    onboardingScrollController = ScrollController();
    isOnboardingPaginating = false;
    getBrokingOnboardingData();
    onboardingScrollController.addListener(handleOnboardingPagination);
  }

  bool get hasPartnerOffice => Get.find<HomeController>().hasPartnerOffice;

  String get partnerFirstName {
    String name = 'Your';
    String? partnerDisplayName = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().advisorOverviewModel?.agent?.displayName
        : null;

    if (partnerDisplayName != null && partnerDisplayName.isNotEmpty) {
      name = '${partnerDisplayName.split(" ")[0]}\'s';
    }
    return name;
  }

  // used for BrokingOnboardingScreen & BrokingScreen
  Future<void> getBrokingOnboardingData({String? selectedClientId}) async {
    brokingOnboardingResponse.state = NetworkState.loading;
    if (!isOnboardingPaginating) {
      brokingOnboardingList.clear();
    }
    update([GetxId.onboarding]);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response =
          await BrokingRepository().getBrokingOnboardingClients(
        apiKey,
        await getBrokingOnboardingPayload(selectedClientId: selectedClientId),
      );

      if (!response.hasException) {
        brokingOnboardingList.addAll(
          WealthyCast.toList(
            response.data!['userBrokingProfileData']['profileAndKycData'],
          )
              .map(
                (onboardingJson) =>
                    BrokingOnboardingModel.fromJson(onboardingJson),
              )
              .toList(),
        );

        brokingOnboardingDataMeta.totalCount =
            response.data!['userBrokingProfileData']['count'] ?? 0;

        brokingOnboardingResponse.state = NetworkState.loaded;
      } else {
        brokingOnboardingResponse.state = NetworkState.error;
        brokingOnboardingResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      brokingOnboardingResponse.state = NetworkState.error;
      brokingOnboardingResponse.message = genericErrorMessage;
    } finally {
      isOnboardingPaginating = false;
      update([GetxId.onboarding]);
    }
  }

  Future<void> getBrokingDetails() async {
    brokingDetailResponse.state = NetworkState.loading;
    update([GetxId.detail]);

    try {
      final apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();
      String currentDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: 1)));
      QueryResult response = await BrokingRepository().getBrokingDetails(
        apiKey,
        agentExternalIdList,
        currentDate,
      );

      if (!response.hasException) {
        final dailyMetrics =
            WealthyCast.toList(response.data!['delta']['partnersTotalMetric']);
        Map<String, dynamic>? brokingJson = dailyMetrics.isNotNullOrEmpty
            ? dailyMetrics.first['brokingDetails']
            : {};
        if (brokingJson != null && brokingJson.isNotEmpty) {
          brokingDetailModel = BrokingDetailModel.fromJson(brokingJson);
        } else {
          brokingDetailModel = null;
        }

        brokingDetailResponse.state = NetworkState.loaded;
      } else {
        brokingDetailResponse.state = NetworkState.error;
        brokingDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      brokingDetailResponse.state = NetworkState.error;
      brokingDetailResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.detail]);
    }
  }

  Future<Map<String, dynamic>> getBrokingOnboardingPayload(
      {String? selectedClientId}) async {
    final offset = ((brokingOnboardingDataMeta.page! + 1) *
            brokingOnboardingDataMeta.limit!) -
        brokingOnboardingDataMeta.limit!;

    List<String> agentExternalIdList = await getAgentExternalIdList();

    Map<String, dynamic> payload = {
      'input': {
        'agentExternalIdList': agentExternalIdList,
        'limit': brokingOnboardingDataMeta.limit,
        'offset': offset,
      },
      'filters': {
        'userIds': selectedClientId.isNullOrEmpty ? [] : [selectedClientId],
        ...savedFilter.isNotNullOrEmpty
            ? clientFilterPayload[savedFilter]!
            : {},
      },
    };
    return payload;
  }

  // used for BrokingOnboardingScreen & BrokingScreen
  Future<String> generateBrokingKycUrl(String type, String userID) async {
    String url = '';
    brokingUrlResponse.state = NetworkState.loading;
    if (type.contains('FNO')) {
      showToast(text: 'Generating Broking Fno Url....');
    } else {
      showToast(text: 'Generating Broking Kyc Url....');
    }

    try {
      final apiKey = await getApiKey() ?? '';
      final payload = <String, dynamic>{
        'input': {
          'kycFlow': type,
          'userId': userID,
        }
      };

      QueryResult response =
          await BrokingRepository().generateBrokingKycUrl(apiKey, payload);

      if (!response.hasException) {
        url = response.data!['sendKycUrl']['kycUrl'];
        brokingUrlResponse.state = NetworkState.loaded;
      } else {
        brokingUrlResponse.state = NetworkState.error;
        brokingUrlResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      brokingUrlResponse.state = NetworkState.error;
      brokingUrlResponse.message = genericErrorMessage;
    } finally {
      return url;
    }
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    getBrokingDetails();
    getBrokingOnboardingData();
  }

  Future<List<String>> getAgentExternalIdList() async {
    List<String> agentExternalIds = [];
    if (partnerOfficeModel != null) {
      agentExternalIds = partnerOfficeModel!.agentExternalIds;
    }
    if (agentExternalIds.isNullOrEmpty) {
      agentExternalIds = [await getAgentExternalId() ?? ''];
    }
    return agentExternalIds;
  }

  // used for BrokingOnboardingScreen
  void handleOnboardingPagination() {
    if (onboardingScrollController.hasClients) {
      bool isScrolledToBottom =
          onboardingScrollController.position.maxScrollExtent <=
              onboardingScrollController.position.pixels;

      bool isPagesRemaining = (brokingOnboardingDataMeta.totalCount! /
              (brokingOnboardingDataMeta.limit! *
                  (brokingOnboardingDataMeta.page! + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          brokingOnboardingResponse.state != NetworkState.loading) {
        brokingOnboardingDataMeta.page = brokingOnboardingDataMeta.page! + 1;
        isOnboardingPaginating = true;
        getBrokingOnboardingData();
      }
    }
  }

  void updateClientFilterPayload() {
    clientFilterPayload = {
      'Kyc In Progress': {
        'kycStatus': [
          BrokingKycStatusLabel.Initiated,
          BrokingKycStatusLabel.InProgress,
          BrokingKycStatusLabel.FollowUpWithCustomer,
          BrokingKycStatusLabel.EsignPending
        ]
      },
      'Kyc Under Review': {
        'kycStatus': [
          BrokingKycStatusLabel.SubmittedByCustomer,
          BrokingKycStatusLabel.UploadedToKRA,
          BrokingKycStatusLabel.Approved,
          BrokingKycStatusLabel.ApprovedByAdmin,
          BrokingKycStatusLabel.ValidatedByKRA,
        ],
        'isTradingEnabled': false
      },
      'Trading Activated': {'kycStatus': [], 'isTradingEnabled': true},
      'FnO Activated': {'kycStatus': [], 'isFnoEnabled': true},
      'FnO Not Activated': {'kycStatus': [], 'isFnoEnabled': false},
      'Remarks Present': {'kycStatus': [], 'remarks': true},
    };
  }

  void updateClientFilter(String? filter) {
    selectedFilter = filter;
    update([GetxId.filter]);
  }

  void applyClientFilter() {
    savedFilter = selectedFilter;
    update([GetxId.filter]);
  }

  void clearClientFilter() {
    selectedFilter = null;
    savedFilter = null;
    update([GetxId.filter]);
  }
}
