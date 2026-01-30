import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/broking/models/broking_activity_model.dart';
import 'package:core/modules/broking/resources/broking_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class BrokingActivityController extends GetxController {
  BrokingRepository brokingRepository = BrokingRepository();

  // Fields used for BrokingActivityScreen
  ApiResponse brokingActivityResponse = ApiResponse();
  List<BrokingActivityModel> brokingActivityList = [];
  late MetaDataModel brokingActivityDataMeta;
  ScrollController activityScrollController = ScrollController();
  bool isActivityPaginating = false;
  DateTime brokingActivitySelectedDate = DateTime.now();

  PartnerOfficeModel? partnerOfficeModel;

  @override
  void onInit() {
    initBrokingActivity();
    super.onInit();
  }

  @override
  void dispose() {
    if (activityScrollController != null) {
      activityScrollController.dispose();
    }
    super.dispose();
  }

  // used for BrokingActivityScreen
  void initBrokingActivity() {
    brokingActivityResponse = ApiResponse();
    brokingActivityList = [];
    brokingActivityDataMeta = MetaDataModel(limit: 20, page: 0, totalCount: 0);
    activityScrollController = ScrollController();
    isActivityPaginating = false;
    getBrokingActivityData();
    activityScrollController.addListener(handleActivityPagination);
  }

  // used for BrokingActivityScreen
  Future<void> getBrokingActivityData({String? selectedClientId}) async {
    brokingActivityResponse.state = NetworkState.loading;
    if (!isActivityPaginating) {
      brokingActivityList.clear();
    }
    update([GetxId.activity]);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await BrokingRepository().getBrokingActivity(
        apiKey,
        await getBrokingActivityPayload(selectedClientId: selectedClientId),
      );

      if (!response.hasException) {
        final jsonData = WealthyCast.toList(
          response.data!['agentBrokingTransactionSummaryData']
              ['userTransactionSummaryData'],
        );
        brokingActivityList.addAll(
          jsonData
              .map(
                (onboardingJson) => BrokingActivityModel.fromJson(
                    onboardingJson, brokingActivitySelectedDate),
              )
              .toList(),
        );

        brokingActivityDataMeta.totalCount =
            response.data!['agentBrokingTransactionSummaryData']['count'] ?? 0;

        brokingActivityResponse.state = NetworkState.loaded;
      } else {
        brokingActivityResponse.state = NetworkState.error;
        brokingActivityResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      brokingActivityResponse.state = NetworkState.error;
      brokingActivityResponse.message = genericErrorMessage;
    } finally {
      isActivityPaginating = false;
      update([GetxId.activity]);
    }
  }

  Future<Map<String, dynamic>> getBrokingActivityPayload(
      {String? selectedClientId}) async {
    final offset =
        ((brokingActivityDataMeta.page! + 1) * brokingActivityDataMeta.limit!) -
            brokingActivityDataMeta.limit!;

    // Providing a day value of zero for the next month
    // gives you the previous month's last day
    final lastDayDateTime = (brokingActivitySelectedDate.month < 12)
        ? DateTime(brokingActivitySelectedDate.year,
            brokingActivitySelectedDate.month + 1, 0)
        : DateTime(brokingActivitySelectedDate.year + 1, 1, 0);

    List<String> agentExternalIdList = await getAgentExternalIdList();

    Map<String, dynamic> payload = {
      'input': {
        'agentExternalIdList': agentExternalIdList,
        'limit': brokingActivityDataMeta.limit,
        'offset': offset,
      },
      'filters': {
        'userIds': selectedClientId.isNullOrEmpty ? [] : [selectedClientId],
        'startDate':
            '01/${brokingActivitySelectedDate.month}/${brokingActivitySelectedDate.year}',
        'endDate':
            '${lastDayDateTime.day}/${lastDayDateTime.month}/${lastDayDateTime.year}',
      },
    };
    return payload;
  }

  // used for BrokingActivityScreen
  void handleActivityPagination() {
    if (activityScrollController.hasClients) {
      bool isScrolledToBottom =
          activityScrollController.position.maxScrollExtent <=
              activityScrollController.position.pixels;

      bool isPagesRemaining = (brokingActivityDataMeta.totalCount! /
              (brokingActivityDataMeta.limit! *
                  (brokingActivityDataMeta.page! + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          brokingActivityResponse.state != NetworkState.loading) {
        brokingActivityDataMeta.page = brokingActivityDataMeta.page! + 1;
        isActivityPaginating = true;
        getBrokingActivityData();
      }
    }
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

  void updateBrokingDateSelected(DateTime date) {
    brokingActivitySelectedDate = date;
    update();
    getBrokingActivityData();
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    getBrokingActivityData();
  }
}
