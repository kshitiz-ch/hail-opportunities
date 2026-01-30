import 'dart:async';
import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/advisor/models/soa_folio_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class SOADownloadController extends GetxController {
  String? apiKey;

  Client? selectedClient;
  SoaFolioModel? selectedFolio;

  ApiResponse soaFolioResponse = ApiResponse();
  List<SoaFolioModel> soaFolioList = [];
  List<SoaFolioModel> filteredSoaFolioList = [];

  ReportModel? soaReportModel;
  ApiResponse getSoaReportReponse = ApiResponse();

  String? createdReportId;
  ApiResponse soaReportCreateResponse = ApiResponse();

  ApiResponse refreshReportReponse = ApiResponse();
  ApiResponse reportAvailabilityReponse = ApiResponse();

  TextEditingController amcSearchController = TextEditingController();
  Timer? _debounce;
  Timer? _autoRefreshTimer;

  // Auto-refresh properties
  int autoRefreshAttempts = 0;
  int autoRefreshElapsedSeconds = 0;
  bool isAutoRefreshActive = false;
  bool _isDisposed = false;
  static const int maxAutoRefreshAttempts =
      6; // 6 attempts * 10 seconds = 60 seconds
  static const int autoRefreshIntervalSeconds = 10;

  final String reportExtension = 'pdf';

  // Safe update method that checks disposal state
  void _safeUpdate() {
    if (!_isDisposed) {
      update();
    }
  }

  @override
  void onInit() async {
    apiKey = await getApiKey();
    super.onInit();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopAutoRefresh();
    super.dispose();
  }

  String get getDownloadURL {
    final baseUrl = F.urlTaxy;
    final url =
        '$baseUrl/entreat-reports/v0/view-report/?token=${soaReportModel?.urlToken}&report_type=${reportExtension}';
    return url;
  }

  Future<void> getSoaFolioList() async {
    soaFolioResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey();

      final data = await AdvisorRepository().getSoaFolioList(
        apiKey!,
        selectedClient?.taxyID ?? '',
      );

      if (data['status'] == '200') {
        final soaFolioApiList = WealthyCast.toList(data['response'])
            .map((e) => SoaFolioModel.fromJson(e))
            .toList();

        // grouping based on soaDownloadAllowed
        soaFolioApiList.sort((a, b) {
          if (b.soaDownloadAllowed == true) {
            return 1;
          }
          return -1;
        });
        soaFolioList = List.from(soaFolioApiList);

        soaFolioResponse.state = NetworkState.loaded;
      } else {
        soaFolioResponse.message =
            getErrorMessageFromResponse(data['response']);
        soaFolioResponse.state = NetworkState.error;
      }
    } catch (error) {
      soaFolioResponse.message = 'Something went wrong';
      soaFolioResponse.state = NetworkState.error;
    } finally {
      filteredSoaFolioList = List.from(soaFolioList);
      update();
    }
  }

  Future<dynamic> generateSOAReport() async {
    soaReportCreateResponse.state = NetworkState.loading;
    soaReportModel = null;
    resetAutoRefreshState();
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        'userId': selectedClient?.taxyID,
        'templateName': 'SOA-REPORT',
        'name': 'SOA-REPORT',
        'regenerate': true,
        'context': jsonEncode(
          <String, dynamic>{'folio_number': selectedFolio?.folioNumber},
        ),
      };
      QueryResult response = await ClientListRepository().createClientReport(
        apiKey: apiKey,
        clientID: selectedClient?.taxyID ?? '',
        payload: payload,
      );

      if (response.hasException) {
        soaReportCreateResponse.message =
            response.exception!.graphqlErrors[0].message;
        soaReportCreateResponse.state = NetworkState.error;
      } else {
        var reportJson = response.data!["createReport"]["report"];
        if (reportJson == null) {
          soaReportCreateResponse.state = NetworkState.error;
          soaReportCreateResponse.message =
              'Something went wrong. Please try again';
        } else {
          createdReportId =
              WealthyCast.toStr(response.data!["createReport"]["report"]["id"]);
          soaReportCreateResponse.state = NetworkState.loaded;
        }
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      soaReportCreateResponse.message =
          'Something went wrong. Please try again';
      soaReportCreateResponse.state = NetworkState.error;
    } finally {
      // 3 seconds delay to get report generated date as non null
      Future.delayed(Duration(seconds: 3));
      update();
    }
  }

  Future<ReportModel?> refreshReportLink(String reportId) async {
    ReportModel? newReportModel;
    refreshReportReponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      await Future.delayed(Duration(seconds: 2));
      QueryResult response = await ClientListRepository().refreshReportLink(
        apiKey: apiKey,
        clientID: selectedClient?.taxyID ?? '',
        payload: {'report': reportId},
      );

      if (response.hasException) {
        refreshReportReponse.message =
            response.exception!.graphqlErrors[0].message;
        refreshReportReponse.state = NetworkState.error;
      } else {
        newReportModel = ReportModel.fromJson(
            response.data!['generateReportLink']['report']);
        refreshReportReponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      refreshReportReponse.message = 'Something went wrong';
      refreshReportReponse.state = NetworkState.error;
    } finally {
      if (newReportModel != null) {
        soaReportModel = newReportModel;
        // Note: Auto-refresh is only started from getSoaReport method
      }
      update();
      return newReportModel;
    }
  }

  Future<dynamic> getSoaReport() async {
    getSoaReportReponse.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientListRepository().getClientReport(
        apiKey: apiKey!,
        clientID: selectedClient?.taxyID ?? '',
        payload: {
          'userId': selectedClient?.taxyID ?? '',
          'id': createdReportId,
        },
      );

      if (response.hasException) {
        getSoaReportReponse.message =
            response.exception!.graphqlErrors[0].message;
        getSoaReportReponse.state = NetworkState.error;
      } else {
        final report =
            ReportModel.fromJson(response.data!['entreat']['report']);
        final isExpired = report.expiresAt?.isBefore(DateTime.now()) ?? false;
        if (isExpired) {
          final newReport = await refreshReportLink(report.id ?? '');
          soaReportModel = newReport ?? report;
        } else {
          soaReportModel = report;
        }

        getSoaReportReponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      getSoaReportReponse.message = 'Something went wrong';
      getSoaReportReponse.state = NetworkState.error;
    } finally {
      // Start auto-refresh if report is in initiated state (A_0)
      if (soaReportModel?.isInitiated == true && !isAutoRefreshActive) {
        _startAutoRefresh();
      }
      update();
    }
  }

  void onClientSelect(Client? client) {
    selectedClient = client;
    selectedFolio = null;
    soaReportModel = null;
    resetAutoRefreshState();
    update();
  }

  void onFolioSelect(SoaFolioModel? folio) {
    selectedFolio = folio;
    soaReportModel = null;
    resetAutoRefreshState();
    update();
  }

  void clearSearchBar() {
    amcSearchController.clear();
    searchAmc('');
  }

  void searchAmc(String searchText) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    soaFolioResponse.state = NetworkState.loading;
    update();

    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (searchText.isNullOrEmpty) {
          filteredSoaFolioList = List.from(soaFolioList);
        } else {
          filteredSoaFolioList = soaFolioList.where((soaFolio) {
            return (soaFolio.amc?.toLowerCase() ?? '')
                .contains(searchText.toLowerCase());
          }).toList();
        }
        soaFolioResponse.state = NetworkState.loaded;
        update();
      },
    );
  }

  Future<bool> checkAvailability() async {
    bool isAvailable = soaReportModel?.isGenerated == true;
    if (isAvailable) return true;

    try {
      reportAvailabilityReponse.state = NetworkState.loading;
      update();

      final availabilityData = await checkReportAvailability(
        onRefresh: () {
          return refreshReportLink(soaReportModel?.id ?? '');
        },
        maxRetry: 1,
      );

      bool isAvailable = availabilityData['isAvailable'];
      ReportModel? newReportModel = availabilityData['newReportModel'];

      if (isAvailable) {
        soaReportModel = newReportModel;
      } else if (newReportModel?.isInitiated == true) {
        // If still in initiated state, update model but don't start auto-refresh
        // Auto-refresh is only started from getSoaReport method
        soaReportModel = newReportModel;
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

  // Auto-refresh methods
  void _startAutoRefresh() {
    // Guard clause: Don't start if already active or report is not in initiated state
    if (isAutoRefreshActive || soaReportModel?.isInitiated != true) {
      return;
    }

    // Initialize auto-refresh state
    isAutoRefreshActive = true;
    autoRefreshAttempts = 0;
    autoRefreshElapsedSeconds = 0;
    _safeUpdate();

    // Create periodic timer that runs every 10 seconds
    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: autoRefreshIntervalSeconds),
      (timer) async {
        // Safety check: Cancel timer if controller has been disposed
        if (_isDisposed) {
          timer.cancel();
          return;
        }

        // Increment counters for tracking attempts and elapsed time
        autoRefreshAttempts++;
        autoRefreshElapsedSeconds += autoRefreshIntervalSeconds;

        // Stop auto-refresh after maximum attempts (60 seconds total)
        if (autoRefreshAttempts > maxAutoRefreshAttempts) {
          _stopAutoRefresh();
          return;
        }

        // Perform the refresh check using checkAvailability method
        try {
          bool isAvailable = await checkAvailability();

          // Stop auto-refresh if any of these conditions are met:
          // - Report is now available (A_1 status)
          // - Auto-refresh was manually stopped
          // - Report status changed to ready (A_1) or failed (A_3)
          if (isAvailable ||
              !isAutoRefreshActive ||
              soaReportModel?.isGenerated == true ||
              soaReportModel?.isFailure == true) {
            _stopAutoRefresh();
          }
        } catch (e) {
          // Log error but continue auto-refresh cycle
          // This ensures temporary network issues don't stop the auto-refresh
          LogUtil.printLog('Auto-refresh error: ${e.toString()}');
        }

        // Update UI with latest state (safely checks if disposed)
        _safeUpdate();
      },
    );
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    isAutoRefreshActive = false;
    _safeUpdate();
  }

  void resetAutoRefreshState() {
    _stopAutoRefresh();
    autoRefreshAttempts = 0;
    autoRefreshElapsedSeconds = 0;
    // No need to call update here since _stopAutoRefresh already does it safely
  }
}
