import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:core/modules/clients/models/synced_pan_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class PortfolioReviewController extends GetxController
    with GetTickerProviderStateMixin {
  final NewClientModel client;

  late TextEditingController asOnDateController;
  String? selectedPAN;
  DateTime? asOnDate;

  ApiResponse syncedPansResponse = ApiResponse();
  ApiResponse portfolioReportResponse = ApiResponse();
  ApiResponse reportAvailabilityReponse = ApiResponse();

  ReportModel? portfolioReportModel;

  List<SyncedPanModel> syncedPans = [];

  AnimationController? lottieController;
  LottieComposition? composition;

  PortfolioReviewController({required this.client});

  /// Returns available PAN cards based on tracker sync status and family reports
  List<String> get panCards {
    if (syncedPans.isNotNullOrEmpty) {
      return syncedPans
          .map((syncedPan) => syncedPan.pan ?? '')
          .where((pan) => pan.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  bool get isTrackerSynced => syncedPans.isNotNullOrEmpty;

  /// Returns the selectedPanModel based on selectedPAN
  SyncedPanModel? get selectedPanModel {
    if (selectedPAN == null) return null;

    return syncedPans.firstWhereOrNull(
      (syncedPan) => syncedPan.pan?.toLowerCase() == selectedPAN?.toLowerCase(),
    );
  }

  DateTime? trackerLastSyncDate;

  @override
  void onInit() {
    super.onInit();
    lottieController = AnimationController(vsync: this);

    asOnDateController =
        TextEditingController(text: getFormattedDate(DateTime.now()));
    asOnDate = DateTime.now();

    selectedPAN = client.panNumber;

    getSyncedPans();

    lottieController?.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    asOnDateController.dispose();
    lottieController?.dispose();

    super.dispose();
  }

  String get getDownloadURL {
    final baseUrl = F.urlTaxy;
    final url =
        '$baseUrl/entreat-reports/v0/view-report/?token=${portfolioReportModel?.urlToken}&report_type=pdf';
    return url;
  }

  void _handleStateChange() {
    if ((portfolioReportResponse.isError || portfolioReportResponse.isLoaded) &&
        lottieController!.isAnimating) {
      lottieController!.reset();
    } else if (portfolioReportResponse.isLoading &&
        !lottieController!.isAnimating &&
        lottieController!.isCompleted) {
      lottieController!.repeat();
    }
  }

  void updateSelectedPAN(String? pan) {
    selectedPAN = pan;
    update();
  }

  void updateAsOnDate(DateTime date) {
    asOnDateController.text = getFormattedDate(date);
    asOnDate = date;
    update();
  }

  Future<void> getSyncedPans() async {
    final apiKey = await getApiKey() ?? '';

    syncedPansResponse.state = NetworkState.loading;
    syncedPans.clear();
    update();

    try {
      final response = await ClientProfileRepository().getSyncedPans(
        apiKey,
        client.userId!,
      );

      final status = WealthyCast.toInt(response["status"]);

      final isSuccess = status != null && (status ~/ 100) == 2;

      if (!isSuccess) {
        syncedPansResponse.message = 'Error getting synced pans';
        syncedPansResponse.state = NetworkState.error;
      } else {
        syncedPans = WealthyCast.toList(response['response']['data'])
            .map((syncedPanJson) => SyncedPanModel.fromJson(syncedPanJson))
            .toList();
        selectedPAN = syncedPans.firstOrNull?.pan;

        // Find the latest sync date from all synced PANs
        DateTime? latestSyncDate;
        for (final syncedPan in syncedPans) {
          if (syncedPan.lastSyncedAt != null) {
            final syncDate = WealthyCast.toDate(syncedPan.lastSyncedAt);
            if (syncDate != null &&
                (latestSyncDate == null || syncDate.isAfter(latestSyncDate))) {
              latestSyncDate = syncDate;
            }
          }
        }

        trackerLastSyncDate = latestSyncDate;

        syncedPansResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      syncedPansResponse.message = 'Something went wrong';
      syncedPansResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> generatePortfolioReview() async {
    portfolioReportResponse.state = NetworkState.loading;
    portfolioReportModel = null;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        'userId': client.userId,
        'templateName': 'INVESTMENT-AI-REPORT',
        'name': 'INVESTMENT-AI-REPORT',
        'regenerate': true,
        'context': jsonEncode(
          <String, dynamic>{
            'as_on_date': DateFormat('yyyy-MM-dd').format(asOnDate!),
            'pan_number': selectedPAN!,
            'ewi': 1
          },
        ),
      };
      QueryResult response = await ClientListRepository().createClientReport(
        apiKey: apiKey,
        clientID: client.userId ?? '',
        payload: payload,
      );

      if (response.hasException) {
        portfolioReportResponse.message =
            response.exception!.graphqlErrors[0].message;
        portfolioReportResponse.state = NetworkState.error;
      } else {
        final reportJson = response.data!["createReport"]["report"];
        if (reportJson == null) {
          portfolioReportResponse.state = NetworkState.error;
          portfolioReportResponse.message =
              'Something went wrong. Please try again';
        } else {
          portfolioReportModel = ReportModel.fromJson(reportJson);

          bool isReportGenerated = await _waitForReportCompletion();

          if (isReportGenerated) {
            showToast(text: 'Report is ready to download');
            portfolioReportResponse.state = NetworkState.loaded;
          } else {
            portfolioReportResponse.state = NetworkState.error;
            portfolioReportResponse.message = 'Report generation failed';
          }

          print('getDownloadURL==>$getDownloadURL');
        }
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      portfolioReportResponse.message =
          'Something went wrong. Please try again';
      portfolioReportResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<bool> _waitForReportCompletion() async {
    while (portfolioReportModel != null &&
        !portfolioReportModel!.isGenerated &&
        !portfolioReportModel!.isFailure) {
      await Future.delayed(
          Duration(seconds: 3)); // Wait 3 seconds between checks

      await checkAvailability();

      if (portfolioReportModel!.isGenerated) {
        return true; // Successfully generated
      } else if (portfolioReportModel!.isFailure) {
        return false; // Failed to generate
      }
    }
    return portfolioReportModel?.isGenerated ?? false;
  }

  Future<bool> checkAvailability() async {
    bool isAvailable = portfolioReportModel?.isGenerated == true;
    if (isAvailable) return true;

    try {
      reportAvailabilityReponse.state = NetworkState.loading;
      update();

      final availabilityData = await checkReportAvailability(
        onRefresh: () {
          return refreshReportLink(portfolioReportModel?.id ?? '');
        },
        maxRetry: 3,
        retryDelay: Duration(seconds: 2),
        customToastMessage:
            'Report generation is taking longer than expected. Wait sometime',
      );

      bool isAvailable = availabilityData['isAvailable'];
      ReportModel? newReportModel = availabilityData['newReportModel'];

      if (isAvailable) {
        portfolioReportModel = newReportModel;
      }

      reportAvailabilityReponse.state = NetworkState.loaded;
    } catch (e) {
      reportAvailabilityReponse.state = NetworkState.error;
      showToast(text: genericErrorMessage);
    } finally {
      update();
      return isAvailable;
    }
  }

  Future<ReportModel?> refreshReportLink(String reportId) async {
    ReportModel? newReportModel;

    try {
      String apiKey = await getApiKey() ?? '';
      await Future.delayed(Duration(seconds: 2));
      QueryResult response = await ClientListRepository().refreshReportLink(
        apiKey: apiKey,
        clientID: client.userId ?? '',
        payload: {'report': reportId},
      );

      if (response.hasException) {
      } else {
        newReportModel = ReportModel.fromJson(
            response.data!['generateReportLink']['report']);
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
    } finally {
      if (newReportModel != null) {
        portfolioReportModel = newReportModel;
      }
      update();
      return newReportModel;
    }
  }
}
