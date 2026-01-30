import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:core/modules/clients/models/report_template_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/src/intl/date_format.dart';

class ClientReportController extends GetxController {
  // Fields
  String? apiKey = '';

  ApiResponse reportTemplate = ApiResponse();
  List<ReportTemplateModel>? reportTemplateList;

  ApiResponse reportList = ApiResponse();
  ApiResponse createReport = ApiResponse();
  ApiResponse refreshReport = ApiResponse();

  List<ReportModel> reportModelList = [];

  RxBool isFileLinkRefreshing = false.obs;

  final Client client;

  TextEditingController? investmentDate1Controller;
  TextEditingController? investmentDate2Controller;
  DateTime? investmentDate1;
  DateTime? investmentDate2;
  String? financialYear;

  bool isFileDownloading = false;
  String downloadUrl = '';
  String downloadedReportName = '';
  late ReceivePort receivePort;
  File? docFile;

  bool fromDownloadScreen = false;

  ClientReportController(this.client, {this.fromDownloadScreen = false});

  @override
  void onInit() async {
    apiKey = await getApiKey();
    super.onInit();
  }

  @override
  void onReady() async {
    if (!fromDownloadScreen) {
      getClientReportTemplates();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getClientReportTemplates() async {
    reportTemplate.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientListRepository()
          .getClientReportTemplates(apiKey!, client.taxyID!);

      if (response.hasException) {
        reportTemplate.message = response.exception!.graphqlErrors[0].message;
        reportTemplate.state = NetworkState.error;
      } else {
        reportTemplateList =
            (response.data!['entreat']['reportTemplates'] as List)
                .map(
                  (templateJson) => ReportTemplateModel.fromJson(templateJson),
                )
                .toList();

        reportTemplate.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      reportTemplate.message = 'Something went wrong';
      reportTemplate.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getClientReportList(String templateName) async {
    reportList.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientListRepository().getClientReportList(
        apiKey: apiKey!,
        clientID: client.taxyID!,
        payload: {
          'userId': client.taxyID!,
          'templateName': templateName,
        },
      );

      if (response.hasException) {
        reportList.message = response.exception!.graphqlErrors[0].message;
        reportList.state = NetworkState.error;
      } else {
        final responseList =
            WealthyCast.toList(response.data!['entreat']['reports']);
        reportModelList =
            responseList.map((json) => ReportModel.fromJson(json)).toList();

        try {
          reportModelList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        } catch (error) {
          LogUtil.printLog(error.toString());
        }

        reportList.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      reportList.message = 'Something went wrong';
      reportList.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> createClientReport({
    required String templateName,
    required ReportDateType inputType,
  }) async {
    createReport.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientListRepository().createClientReport(
        apiKey: apiKey!,
        clientID: client.taxyID!,
        payload: getCreateReportPayload(
          templateName: templateName,
          inputType: inputType,
        ),
      );

      if (response.hasException) {
        createReport.message = response.exception!.graphqlErrors[0].message;
        createReport.state = NetworkState.error;
      } else {
        createReport.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      createReport.message = 'Something went wrong';
      createReport.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<ReportModel?> refreshReportLink({
    required String reportId,
  }) async {
    ReportModel? newReportModel;
    refreshReport.state = NetworkState.loading;
    isFileLinkRefreshing.toggle();
    update(['download_button']);

    try {
      QueryResult response = await ClientListRepository().refreshReportLink(
        apiKey: apiKey!,
        clientID: client.taxyID!,
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
      isFileLinkRefreshing.toggle();
      update(['download_button']);
      return newReportModel;
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

    Map<String, dynamic> data = {
      'userId': client.taxyID,
      'templateName': templateName,
      'name': templateName,
      'regenerate': true,
      'context': jsonEncode(context),
    };

    return data;
  }

  void initInputFields() {
    investmentDate1Controller = TextEditingController();
    investmentDate2Controller = TextEditingController();
    financialYear = null;
    investmentDate1 = null;
    investmentDate2 = null;
  }

  void updateInvestmentDate1(DateTime investmentDate) {
    investmentDate1Controller!.text =
        DateFormat('dd MMM yyyy').format(investmentDate);
    investmentDate1 = investmentDate;
    update();
  }

  void updateInvestmentDate2(DateTime investmentDate) {
    investmentDate2Controller!.text =
        DateFormat('dd MMM yyyy').format(investmentDate);
    investmentDate2 = investmentDate;
    update();
  }

  void updateFinancialYear(String year) {
    financialYear = year;
    update();
  }
}
