import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_tracker_allocation.dart';
import 'package:core/modules/clients/models/client_tracker_fund_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:path_provider/path_provider.dart';

enum AllocationCategory {
  Equity,
  Debt,
  Hybrid,
  Commodity,
}

class ClientTrackerController extends GetxController {
  final Client client;

  String? apiKey;

  FamilyReportModel? familyReport;
  late ClientListRepository clientListRepository;

  NetworkState? clientAllocationDetailState;
  String? clientAllocationDetailErrorMessage;
  ClientTrackerAllocation? clientTrackerAllocation;

  NetworkState? clientHoldingState;
  String? clientHoldingErrorMessage;
  List<ClientTrackerFundModel> clientTrackerHoldings = [];

  bool isCheckedForNewSchemeCodeMapping = false;
  bool isSwitchUpdateViewed = false;
  bool showSwitchUpdateCard = true;

  Map<AllocationCategory, dynamic> allocationMapping = {
    AllocationCategory.Equity: {
      'weight': 0,
      'color': Color(0xffFFCAAC),
    },
    AllocationCategory.Debt: {
      'weight': 0,
      'color': Color(0xffC2A9F6),
    },
    AllocationCategory.Hybrid: {
      'weight': 0,
      'color': Color(0xffFFCAAC).withOpacity(0.5),
    },
    AllocationCategory.Commodity: {
      'weight': 0,
      'color': Color(0xffC2A9F6).withOpacity(0.5),
    },
  };

  Map<String, dynamic> schemeCodeMapping = {};
  List<ClientTrackerFundModel> trackerFundsWithMissingData = [];

  ClientTrackerController(this.client, this.familyReport);

  @override
  void onInit() async {
    super.onInit();
    clientListRepository = ClientListRepository();
    await showSwitchUpdateBottomSheet();
    await getSchemeCodeMapping();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    apiKey = await getApiKey();
    getClientAllocationDetails();
    getClientHoldingDetails();
  }

  Future<void> getClientAllocationDetails() async {
    try {
      clientAllocationDetailState = NetworkState.loading;
      update();

      apiKey ??= await getApiKey();

      final QueryResult response =
          await clientListRepository.getClientAllocationDetails(
        apiKey!,
        client.taxyID!,
        familyReport?.panNumber ?? '',
      );

      if (response.hasException) {
        clientAllocationDetailErrorMessage =
            response.exception!.graphqlErrors.first.message;
        clientAllocationDetailState = NetworkState.error;
      } else {
        if (response.data != null &&
            response.data!['phaser'] != null &&
            response.data!['phaser']['familyMfOverview'] != null) {
          clientTrackerAllocation = ClientTrackerAllocation.fromJson(
              response.data!['phaser']['familyMfOverview']);
          updateAllocationMapping();
        }
        clientAllocationDetailState = NetworkState.loaded;
      }
    } catch (error) {
      clientAllocationDetailErrorMessage = genericErrorMessage;
      clientAllocationDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateAllocationMapping() {
    List<AllocationData>? assetAllocationData = clientTrackerAllocation
        ?.allocation
        ?.firstWhere((allocationItem) =>
            allocationItem.allocationType?.toLowerCase() == 'asset')
        .allocationData;

    assetAllocationData?.forEach(
      (allocationData) {
        final allocationCategory = allocationData.category?.toLowerCase();
        if (allocationCategory ==
            AllocationCategory.Equity.name.toLowerCase()) {
          allocationMapping[AllocationCategory.Equity]['weight'] =
              allocationData.weight ?? 0;
        } else if (allocationCategory ==
            AllocationCategory.Debt.name.toLowerCase()) {
          allocationMapping[AllocationCategory.Debt]['weight'] =
              allocationData.weight ?? 0;
        } else if (allocationCategory ==
            AllocationCategory.Hybrid.name.toLowerCase()) {
          allocationMapping[AllocationCategory.Hybrid]['weight'] =
              allocationData.weight ?? 0;
        } else if (allocationCategory ==
            AllocationCategory.Commodity.name.toLowerCase()) {
          allocationMapping[AllocationCategory.Commodity]['weight'] =
              allocationData.weight ?? 0;
        }
      },
    );
  }

  Future<void> getClientHoldingDetails() async {
    try {
      clientHoldingState = NetworkState.loading;
      trackerFundsWithMissingData.clear();
      clientTrackerHoldings.clear();

      update();

      apiKey ??= await getApiKey();

      final QueryResult response =
          await clientListRepository.getClientHoldingDetails(
        apiKey!,
        client.taxyID!,
        familyReport?.panNumber ?? '',
      );
      if (response.hasException) {
        clientHoldingErrorMessage =
            response.exception!.graphqlErrors.first.message;
        clientHoldingState = NetworkState.error;
      } else {
        LogUtil.printLog(schemeCodeMapping.toString());
        List clientHoldingsJson =
            response.data!['phaser']['familyMfSchemeOverviews'] as List;

        clientHoldingsJson.forEach((mfSchemeOverView) {
          List? folioOverviewsJson =
              WealthyCast.toList(mfSchemeOverView["folioOverviews"]);

          if (folioOverviewsJson.isNotNullOrEmpty) {
            folioOverviewsJson.forEach((folioJson) {
              FolioModel folioOverview = FolioModel.fromJson(folioJson);
              ClientTrackerFundModel fundModel =
                  ClientTrackerFundModel.fromJson(mfSchemeOverView);
              fundModel.schemeMetaModel?.folioOverview = folioOverview;

              if (fundModel.schemeMetaModel?.displayName == null &&
                  fundModel.schemeCode != null) {
                String? newSchemeCode = schemeCodeMapping[fundModel.schemeCode];
                if (newSchemeCode != null) {
                  fundModel.schemeCode = newSchemeCode;
                  trackerFundsWithMissingData.add(fundModel);
                }
              }

              clientTrackerHoldings.add(fundModel);
            });
          }
        });

        // clientTrackerHoldings = clientHoldingsJson.map(
        //   (mfSchemeOverView) {
        //     List? folioOverviewsJson =
        //         WealthyCast.toList(mfSchemeOverView["folioOverviews"]);
        //     ClientTrackerFundModel fundModel =
        //         ClientTrackerFundModel.fromJson(mfSchemeOverView);

        //     if (fundModel.schemeMetaModel?.displayName == null &&
        //         fundModel.schemeCode != null) {
        //       String? newSchemeCode = schemeCodeMapping[fundModel.schemeCode];
        //       if (newSchemeCode != null) {
        //         fundModel.schemeCode = newSchemeCode;
        //         trackerFundsWithMissingData.add(fundModel);
        //       }
        //     }
        //     return fundModel;
        //   },
        // ).toList();

        if (trackerFundsWithMissingData.isNotEmpty) {
          await getMissingSchemeData();
        }
        clientHoldingState = NetworkState.loaded;
      }
    } catch (error) {
      clientHoldingErrorMessage = genericErrorMessage;
      clientHoldingState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getMissingSchemeData() async {
    try {
      String wSchemeCodes = '';

      trackerFundsWithMissingData.forEach((trackerFund) {
        wSchemeCodes += ',${trackerFund.schemeCode!}';
      });

      final data = await StoreRepository()
          .getSchemeDetails(apiKey: apiKey ?? '', wSchemeCodes: wSchemeCodes);

      if (data['status'] == '200') {
        List schemeDataList = data["response"]["mf_fund_meta"];

        trackerFundsWithMissingData.forEach((trackerFund) {
          SchemeMetaModel? missingSchemeData;

          for (var schemeDataJson in schemeDataList) {
            SchemeMetaModel schemeMetaModel =
                SchemeMetaModel.fromJson(schemeDataJson);

            if (trackerFund.schemeCode == schemeMetaModel.schemeCode) {
              missingSchemeData = schemeMetaModel;
              break;
            }
          }

          if (missingSchemeData != null) {
            FolioModel? folioOverview =
                trackerFund.schemeMetaModel?.folioOverview;
            trackerFund.schemeMetaModel = missingSchemeData;
            trackerFund.schemeMetaModel?.folioOverview = folioOverview;
          }
        });
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<File?> getSchemeCodeMappingFile() async {
    File? schemeCodeFile;
    try {
      final directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      schemeCodeFile = File('$path/scheme-code.json');
    } catch (error) {
      LogUtil.printLog(error.toString());
    }

    return schemeCodeFile;
  }

  Future<void> getSchemeCodeMapping() async {
    File? schemeCodeMappingFile = await getSchemeCodeMappingFile();

    try {
      var data = await clientListRepository.getSchemeCodeMapping();
      if (data['status'] == '200') {
        schemeCodeMapping = data['response'];
      }

      if (schemeCodeMappingFile != null) {
        await saveSchemeCodeMappingCache(
            schemeCodeMappingFile, data["response"]);
      }
    } catch (error) {
      if (schemeCodeMappingFile != null) {
        bool isSchemeCodeMappingExists = (await schemeCodeMappingFile.exists());
        if (isSchemeCodeMappingExists) {
          await getSchemeCodeMappingFromCache(schemeCodeMappingFile);
        }
      }
    } finally {
      update();
    }
  }

  Future<void> getSchemeCodeMappingFromCache(File schemeCodeFile) async {
    try {
      String? jsonData = await schemeCodeFile.readAsString();
      schemeCodeMapping = json.decode(jsonData);
    } catch (error) {
      LogUtil.printLog(error.toString());
    } finally {
      update();
    }
  }

  Future<void> saveSchemeCodeMappingCache(File file, response) async {
    try {
      await file.writeAsString('${json.encode(response)}');
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<void> showSwitchUpdateBottomSheet() async {
    isSwitchUpdateViewed = (await prefs)
            .getBool(SharedPreferencesKeys.isTrackerSwitchUpdateViewed) ??
        false;
  }

  Future<void> disableSwitchUpdateBottomSheet() async {
    (await prefs)
        .setBool(SharedPreferencesKeys.isTrackerSwitchUpdateViewed, true);
    isSwitchUpdateViewed = true;
  }

  Future<void> disableSwitchUpdateCard() async {
    showSwitchUpdateCard = false;
    update();
  }

  bool lastSyncedSince30Days(DateTime? lastSynced) {
    if (lastSynced == null) return true;

    try {
      DateTime now = new DateTime.now();
      Duration difference = now.difference(lastSynced);
      int syncedSinceInDays = difference.inDays;

      if (syncedSinceInDays >= 30) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return true;
    }
  }
}
