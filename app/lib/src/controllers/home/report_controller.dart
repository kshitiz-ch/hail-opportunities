import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:core/modules/clients/models/report_template_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

String portName = "download-client-report";

String reportNotFoundMessage =
    'Report not found. Possible reasons: insufficient investment or unavailable data. Please check and try again';

@pragma('vm:entry-point')
class ReportController extends GetxController {
  ApiResponse reportTemplatesResponse = ApiResponse();

  ApiResponse createReport = ApiResponse();
  ApiResponse refreshReport = ApiResponse();

  List<ReportTemplateModel> reportTemplateList = [];
  ReportTemplateModel? selectedReportTemplate;
  ReportTemplateGroupModel? selectedReportTemplateGroup;

  Map<String, ReportTemplateGroupModel> reportTemplateGroups = {};

  bool disableSelectClient = false;

  bool get isSoaFolioReport => selectedReportTemplate?.name == 'SOA-REPORT';
  String? folioNumber;
  final soaControllerTag = 'client_folio_report';

  // Form States
  Client? selectedClient;
  DateTime? reportDate;
  String? selectedFileFormat;

  ReportCategory? selectedReportCategory;

  // Date States
  TextEditingController investmentDate1Controller = TextEditingController();
  TextEditingController investmentDate2Controller = TextEditingController();
  DateTime? investmentDate1;
  DateTime? investmentDate2;
  String? financialYear;

  // Download States
  final ReceivePort receivePort = ReceivePort();
  RxBool isFileDownloading = false.obs;
  RxBool isFileLinkRefreshing = false.obs;

  // String downloadFileTaskId = '';
  String downloadedReportName = '';
  String downloadUrl = '';
  File? docFile;
  ReportModel? downloadReport;

  ReportController({this.selectedClient});

  ReportDateType get dateType =>
      getInputType(selectedReportTemplate?.name ?? '');

  final commonController = Get.find<CommonController>();

  bool get isFormValid {
    if (dateType == ReportDateType.IntervalDate) {
      return selectedClient != null &&
          selectedReportTemplate != null &&
          investmentDate1 != null &&
          investmentDate2 != null;
    } else if (dateType == ReportDateType.SingleDate) {
      return selectedClient != null &&
          selectedReportTemplate != null &&
          investmentDate1 != null;
    } else if (dateType == ReportDateType.SingleYear) {
      return selectedClient != null &&
          selectedReportTemplate != null &&
          financialYear != null;
    } else if (dateType == ReportDateType.None) {
      return selectedClient != null && selectedReportTemplate != null;
    } else {
      return selectedClient != null && selectedReportTemplate != null;
    }
  }

  void onInit() {
    if (selectedClient != null) {
      disableSelectClient = true;
    }

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
    getReportTemplates();
    // initialiseDownloadService();
    super.onInit();
  }

  @override
  void dispose() {
    receivePort.close();
    _unbindBackgroundIsolate();

    if (Get.isRegistered<SOADownloadController>(tag: soaControllerTag)) {
      Get.delete<SOADownloadController>(tag: soaControllerTag);
    }

    super.dispose();
  }

  Future<dynamic> getReportTemplates() async {
    reportTemplatesResponse.state = NetworkState.loading;
    reportTemplateGroups.clear();
    update([GetxId.contentList]);
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await ClientListRepository().getClientReportTemplates(apiKey, '');

      if (response.hasException) {
        reportTemplatesResponse.message =
            response.exception!.graphqlErrors[0].message;
        reportTemplatesResponse.state = NetworkState.error;
      } else {
        // reportTemplateList =
        (response.data!['entreat']['reportTemplates'] as List).forEach(
          (templateJson) {
            ReportTemplateModel reportTemplate =
                ReportTemplateModel.fromJson(templateJson);

            String? groupName = templateJson["groupName"] ?? '';

            // Hide Tracker Investment AI Report if feature flag is disabled
            final isInvalidReport =
                groupName == 'Tracker Investment AI Report' &&
                    !commonController.portfolioReviewSectionFlag.value;

            if (groupName.isNotNullOrEmpty && !isInvalidReport) {
              if (!reportTemplateGroups.containsKey(groupName)) {
                reportTemplateGroups[groupName!] = ReportTemplateGroupModel(
                  groupName: groupName,
                  reportTemplates: [reportTemplate],
                );
              } else {
                reportTemplateGroups[groupName]!
                    .reportTemplates
                    .add(reportTemplate);
              }
            }
          },
        );

        reportTemplatesResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      reportTemplatesResponse.message = 'Something went wrong';
      reportTemplatesResponse.state = NetworkState.error;
    } finally {
      update([GetxId.contentList]);
    }
  }

  void updateSelectedReportTemplateGroup(
      ReportTemplateGroupModel templateGroup) {
    selectedReportTemplateGroup = templateGroup;

    update();
  }

  void updateSelectedReportTemplate(template) {
    selectedReportTemplate = template;
    // if (template.name.toLowerCase().contains("family")) {
    //   selectedReportCategory = ReportCategory.Family;
    // } else {
    //   selectedReportCategory = ReportCategory.Individual;
    // }
    // Temp

    update([GetxId.form]);
    update();
  }

  void updateSelectedFileFormat(fileFormat) {
    selectedFileFormat = fileFormat;

    update([GetxId.form]);
    update();
  }

  void updateSelectedClient(Client client) {
    selectedClient = client;
    folioNumber = null;
    update([GetxId.form]);
  }

  void updateInvestmentDate1(DateTime date) {
    investmentDate1 = date;
    update([GetxId.form]);
  }

  void updateInvestmentDate2(DateTime date) {
    investmentDate2 = date;
    update([GetxId.form]);
  }

  void updateFinancialYear(year) {
    financialYear = year;
    update([GetxId.form]);
  }

  void resetForm() {
    selectedReportTemplateGroup = null;
    selectedReportTemplate = null;
    folioNumber = null;

    if (!disableSelectClient) {
      selectedClient = null;
    }

    // Reset Date Related fields
    investmentDate1Controller.clear();
    investmentDate2Controller.clear();
    investmentDate1 = null;
    investmentDate2 = null;
    financialYear = null;

    downloadedReportName = '';
    downloadUrl = '';
    docFile = null;
    downloadReport = null;
    selectedFileFormat = null;
    isFileDownloading.value = false;

    update();
  }

  Future<dynamic> createClientReport() async {
    createReport.state = NetworkState.loading;
    downloadReport = null;
    update([GetxId.form]);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientListRepository().createClientReport(
        apiKey: apiKey,
        clientID: selectedClient?.taxyID ?? '',
        payload: getCreateReportPayload(
          templateName: selectedReportTemplate?.name ?? '',
          inputType: dateType,
        ),
      );

      if (response.hasException) {
        createReport.message = response.exception!.graphqlErrors[0].message;
        createReport.state = NetworkState.error;
      } else {
        var reportJson = response.data!["createReport"]["report"];
        if (reportJson == null) {
          createReport.state = NetworkState.error;
          createReport.message = reportNotFoundMessage;
        } else {
          downloadReport =
              ReportModel.fromJson(response.data!["createReport"]["report"]);

          final newReportModel =
              await refreshReportLink(reportId: downloadReport?.id ?? '');
          downloadReport?.urlToken = newReportModel?.urlToken;
          downloadReport?.shortLink = newReportModel?.shortLink;

          createReport.state = NetworkState.loaded;

          // if (downloadReport?.expiresAt?.isBefore(DateTime.now()) == true) {
          // }

          // if (selectedFileFormat == 'web' &&
          //     (downloadReport?.shortLink?.isNotNullOrEmpty ?? false)) {
          //   launch(downloadReport!.shortLink!);
          // } else {
          //   await downloadAsset();
          // }
        }
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      createReport.message = reportNotFoundMessage;
      createReport.state = NetworkState.error;
    } finally {
      update([GetxId.form]);
    }
  }

  Future<void> downloadAsset() async {
    final baseUrl = F.urlTaxy;
    final url =
        '$baseUrl/entreat-reports/v0/view-report/?token=${downloadReport?.urlToken}&report_type=${selectedFileFormat}';
    // handle rage clicking
    if (isFileDownloading.value == true) {
      showToast(
          text: 'A download is already in progress. Please try after sometime');
      return;
    }

    updateFileDownloadingStatus(true);
    downloadUrl = url;
    downloadedReportName = downloadReport?.displayName ?? '';

    PermissionStatus storageStatus = await getStorePermissionStatus();

    if (storageStatus.isGranted) {
      try {
        final downloadDirectory = (await getDownloadPath())!;

        // fixed Create a file using java.io API failed
        // for long file names or having special characters
        String displayName = downloadReport?.displayName ?? '';
        String fileName = displayName.length > 20
            ? displayName.substring(0, 20)
            : displayName;

        // remove invalid characters for file creation
        fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '-');

        final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
        String fileExt = '.${selectedFileFormat}';
        final dateTimeFileName =
            fileName.toString().replaceAll(fileExt, '') + date + fileExt;
        docFile = File('${downloadDirectory}/$dateTimeFileName');

        await FlutterDownloader.enqueue(
          timeout: getDownloaderTimeoutDuration(),
          url: url,
          savedDir: downloadDirectory,
          fileName: dateTimeFileName,
          showNotification: true,
          openFileFromNotification: true,
        );
      } catch (error) {
        updateFileDownloadingStatus(false);
        launch(downloadReport?.shortLink ?? url);
      }
    } else {
      showToast(text: "Please enable storage permission");
      updateFileDownloadingStatus(false);
      Future.delayed(Duration(seconds: 1), () {
        launch(downloadReport?.shortLink ?? url);
      });
    }
  }

  Map<String, dynamic> getCreateReportPayload({
    required String templateName,
    required ReportDateType inputType,
  }) {
    Map<String, dynamic> context = {};
    if (inputType == ReportDateType.SingleDate) {
      context['as_on_date'] = DateFormat('yyyy-MM-dd').format(investmentDate1!);
    }
    if (inputType == ReportDateType.IntervalDate) {
      context['start_date'] = DateFormat('yyyy-MM-dd').format(investmentDate1!);
      context['end_date'] = DateFormat('yyyy-MM-dd').format(investmentDate2!);
    }
    if (inputType == ReportDateType.SingleYear) {
      context['financial_year'] = WealthyCast.toInt(financialYear ?? '');
    }
    if (isSoaFolioReport) {
      context['folio_number'] = folioNumber;
    }

    Map<String, dynamic> data = {
      'userId': selectedClient?.taxyID,
      'templateName': templateName,
      'name': templateName,
      'regenerate': true,
      'context': jsonEncode(context),
    };

    return data;
  }

  // Download Report Logic
  // ==============
  // void initialiseDownloadService() {
  //   receivePort = ReceivePort();
  //   IsolateNameServer.registerPortWithName(
  //     receivePort.sendPort,
  //     portName,
  //   );
  //   FlutterDownloader.registerCallback(downloadCallback);
  //   downloaderListener();
  // }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    receivePort.listen((message) async {
      int? progress;
      try {
        if (message[2] != null && message[2] >= 0) {
          progress = message[2];
        }
      } catch (e) {
        LogUtil.printLog('errror====>');
      }
      LogUtil.printLog('message==>$message');

      DownloadTaskStatus status = DownloadTaskStatus.fromInt(message[1]);

      if (status == DownloadTaskStatus.running) {
        showToast(
          text: 'Downloading ${progress != null ? '$progress%' : ''}...',
          duration: Duration(seconds: 1),
        );
      } else if (status == DownloadTaskStatus.complete) {
        updateFileDownloadingStatus(false);
        // showToast(text: 'Download Completed');
        onDownloadCompleted(message[0]);
      } else if (status == DownloadTaskStatus.failed) {
        updateFileDownloadingStatus(false);
        showToast(text: 'Download Failed');
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    LogUtil.printLog(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  Future<ReportModel?> refreshReportLink({required String reportId}) async {
    ReportModel? newReportModel;
    isFileLinkRefreshing = true.obs;
    refreshReport.state = NetworkState.loading;
    update([GetxId.form]);

    try {
      String apiKey = await getApiKey() ?? '';
      await Future.delayed(Duration(seconds: 2));
      QueryResult response = await ClientListRepository().refreshReportLink(
        apiKey: apiKey,
        clientID: selectedClient?.taxyID ?? '',
        payload: {'report': reportId},
      );

      if (response.hasException) {
        refreshReport.message = response.exception!.graphqlErrors[0].message;
        refreshReport.state = NetworkState.error;
      } else {
        newReportModel = ReportModel.fromJson(
            response.data!['generateReportLink']['report']);
        refreshReport.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      refreshReport.message = 'Something went wrong';
      refreshReport.state = NetworkState.error;
    } finally {
      isFileLinkRefreshing = false.obs;
      update([GetxId.form]);
      return newReportModel;
    }
  }

  void updateFileDownloadingStatus(bool value) {
    if (value != isFileDownloading.value) {
      isFileDownloading.value = value;
      update([GetxId.form]);
    }
  }

  void onDownloadCompleted(String taskId) async {
    await CommonUI.showBottomSheet(
      getGlobalContext(),
      child: DownloadedReportBottomSheet(
        onShare: () async {
          try {
            await shareFiles(docFile?.path ?? '');
          } catch (error) {
            LogUtil.printLog("Failed to share. Please try after some time");
          }
        },
        onView: () async {
          await FlutterDownloader.open(taskId: taskId);
        },
        reportName: downloadedReportName,
      ),
    );
  }
}
