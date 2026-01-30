import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

String getGoalTransactDays(List<int>? days, {int limit = 3}) {
  String dateStr = '';
  if (days?.isNotNullOrEmpty ?? false) {
    if (days!.length > limit) {
      dateStr = days.sublist(0, limit).map((e) => e.numberPattern).join(', ');
    } else {
      dateStr = days.map((e) => e.numberPattern).join(', ');
    }
    final remainingDays = days.length - limit;
    if (remainingDays > 0) {
      dateStr += ', +$remainingDays days';
    }
  } else {
    dateStr = notAvailableText;
  }
  return dateStr;
}

Map<String, dynamic> getGoalTransactStatusData(
    bool? isPaused, DateTime? endDate) {
  Map<String, dynamic> data = {};
  final isInactive = endDate?.isBefore(DateTime.now()) ?? false;

  if (isInactive) {
    data['icon'] = Icons.warning;
    data['iconBackgroundColor'] = ColorConstants.darkGrey;
    data['statusText'] = 'Inactive';
  } else if (isPaused == true) {
    data['icon'] = Icons.pause;
    data['iconBackgroundColor'] = ColorConstants.yellowAccentColor;
    data['statusText'] = 'Paused';
  } else {
    data['icon'] = Icons.done;
    data['iconBackgroundColor'] = ColorConstants.greenAccentColor;
    data['statusText'] = 'Active';
  }

  return data;
}

ReportDateType getInputType(String reportTemplateName) {
  switch (reportTemplateName) {
    // Single Date field
    case 'HOLDING-GROUP-REPORT':
    case 'MF-HOLDINGS':
      return ReportDateType.SingleDate;

    // Interval date field
    case 'MF-TRANSACTION-REPORT':
    case 'MF-CGT-REPORT-V1':
    case 'MF-CGT-REPORT':
    case 'PRE-IPO-REPORT':
      return ReportDateType.IntervalDate;

    // Financial year
    case 'MF-TAX-SAVING':
    case 'TRAK-CGT-REPORT':
      return ReportDateType.SingleYear;

    case 'DEBENTURE-REPORT':
    case 'PMS-REPORT':
    case 'INVESTMENT-REPORT':
      return ReportDateType.None;
    // return '';

    default:
      return ReportDateType.None;
  }
}

String getReportIcon(String reportTemplateName) {
  switch (reportTemplateName) {
    case 'Holdings Report':
      return AllImages().holdingReport;
    case 'Mutual Fund Holdings Report':
    case 'Mutual Fund Transactions Report':
      return AllImages().mfHoldingReport;

    case 'Unlisted Stock Report':
      return AllImages().preIpoReport;

    case 'Capital Gain Loss Report':
    case 'ELSS Investment Proof':
      return AllImages().cglrReport;
    case 'Tracker CGT Report':
      return AllImages().trackerCgtReport;

    case 'Debentures Report':
      return AllImages().debentureReport;
    case 'PMS Report':
      return AllImages().pmsReport;
    case 'Tracker Investment Report':
      return AllImages().trackerReport;

    default:
      return AllImages().clientReportIcon;
  }
}

Color getInvestmentColors(ClientInvestmentProductType productType) {
  switch (productType) {
    case ClientInvestmentProductType.mutualFunds:
      return hexToColor("#A9E29B");

    case ClientInvestmentProductType.preIpo:
      return hexToColor("#02CEC9");

    case ClientInvestmentProductType.debentures:
      return hexToColor("#9CDCFF");

    case ClientInvestmentProductType.pms:
      return hexToColor("#FF82D5");

    case ClientInvestmentProductType.fixedDeposit:
      return hexToColor("#FFBE82");

    case ClientInvestmentProductType.sif:
      return hexToColor("#800020").withOpacity(0.5);

    default:
      return ColorConstants.lightPrimaryAppColor;
  }
}

Future<void> saveClientToRecentClients(Client client) async {
  try {
    if (client.taxyID.isNullOrEmpty) return;

    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/recent_clients.json');
    List<Map<String, dynamic>> recentClients = [];

    bool isClientExists = false;

    if (await file.exists()) {
      String jsonData = await file.readAsString();
      if (jsonData.isNotNullOrEmpty) {
        Map<String, dynamic> data = json.decode(jsonData);
        recentClients = WealthyCast.toList(data["clients"]);
        for (var clientJson in data["clients"]) {
          if (clientJson["id"] == client.id) {
            isClientExists = true;
            break;
          }
        }
      }
    }

    if (!isClientExists) {
      recentClients.insert(0, {
        "name": client.name,
        "crn": client.crn,
        "id": client.id,
      });
    }

    if (recentClients.length > 4) {
      recentClients = recentClients.sublist(0, 4);
    }

    await file.writeAsString('${json.encode({"clients": recentClients})}');
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
}
