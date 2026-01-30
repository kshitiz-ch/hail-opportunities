import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';

String getStepUpSipAmount({
  required int sipAmount,
  required int incrementPercentage,
}) {
  final updatedSipAmount = sipAmount + (incrementPercentage / 100) * sipAmount;
  return WealthyAmount.currencyFormat(updatedSipAmount, 0);
}

int getStepUpMonths(String? incrementPeriod) {
  incrementPeriod = (incrementPeriod ?? '').toLowerCase();
  if (incrementPeriod == '6m') {
    return 6;
  } else if (incrementPeriod == '12m' || incrementPeriod == '1y') {
    return 12;
  }

  return 0;
}

String getSipDateStr(String? sipDays) {
  String dateStr = '';
  if (sipDays?.isNotNullOrEmpty ?? false) {
    List<int>? days =
        sipDays?.split(',').map((e) => WealthyCast.toInt(e.trim())!).toList();

    if (days.isNotNullOrEmpty) {
      if (days!.length > 3) {
        dateStr = days.sublist(0, 3).map((e) => e.numberPattern).join(', ');
      } else {
        dateStr = days.map((e) => e.numberPattern).join(', ');
      }
      final remainingDays = days.length - 3;
      if (remainingDays > 0) {
        dateStr += ', +$remainingDays days';
      }
    }
  } else {
    dateStr = sipDays == null
        ? notAvailableText
        : getOrdinalNumber(WealthyCast.toInt(sipDays) ?? 0);
  }
  return dateStr;
}

Widget buildSipDaysInfoIcon(String? sipDays, BuildContext context) {
  if (sipDays.isNotNullOrEmpty) {
    List<int> days =
        sipDays?.split(',').map((e) => WealthyCast.toInt(e.trim())!).toList() ??
            [];
    if (days.length > 3) {
      return Tooltip(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: ColorConstants.black,
            borderRadius: BorderRadius.circular(6)),
        triggerMode: TooltipTriggerMode.tap,
        textStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
        message:
            'Sip Days : ${days.map((day) => day.numberPattern).join(', ')}',
        child: Icon(
          Icons.info_outline,
          color: ColorConstants.primaryAppColor,
          size: 16,
        ),
      );
    }
  }
  return SizedBox();
}

Map<String, dynamic> getSipDetailsPayload(SipData? sipData) {
  try {
    return {
      "sip_days": sipData?.selectedSipDays,
      "start_date": sipData?.startDate!.toIso8601String().split('T')[0],
      "end_date": sipData?.endDate!.toIso8601String().split('T')[0],
      "stepper_details": sipData!.isStepUpSipEnabled
          ? Map<String, dynamic>.from(
              {
                "stepper_enabled": true,
                'increment_period': sipData.formattedStepUpPeriod,
                'increment_percentage': sipData.stepUpPercentage
              },
            )
          : Map<String, dynamic>.from({"stepper_enabled": false})
    };
  } catch (error) {
    return {};
  }
}

UserGoalSubtypeSchemeModel toGoalSubtypeSchemeModel(Map<String, dynamic> data) {
  Map<String, dynamic> goalSubTypeSchemeJson = {
    "currentInvestedValue": data["investedValue"],
    "currentValue": data["currentValue"],
    "currentIrr": data["currentIrr"],
    "currentAsOn": data["asOn"],
    "wpc": data["wpc"],
    "amc": data["amc"],
  };

  Map<String, dynamic> folioJson = {
    "units": data["units"],
    "asOn": data["asOn"],
    "folioNumber": data["folioNumber"],
    "currentValue": data["currentValue"],
    "investedValue": data["investedValue"],
    "withdrawalUnitsAvailable": data["withdrawalUnitsAvailable"],
    "withdrawalAmountAvailable": data["withdrawalAmountAvailable"],
    "exitLoadFreeAmount": data["exitLoadFreeAmount"],
  };

  goalSubTypeSchemeJson["folioOverviews"] = [folioJson];
  goalSubTypeSchemeJson["folioOverview"] = folioJson;

  Map<String, dynamic>? schemeDataJson = data["schemeDetails"];
  if (schemeDataJson != null) {
    goalSubTypeSchemeJson["schemeData"] = {
      "displayName": schemeDataJson["displayName"],
      "fundType": schemeDataJson["fundType"],
      "category": schemeDataJson["category"],
      "nav": schemeDataJson["nav"],
      "navDate": schemeDataJson["navDate"] ?? data["navDate"],
      "wpc": schemeDataJson["wpc"],
      "amc": schemeDataJson["amc"],
      "wschemecode": data["wschemecode"],
      "isPaymentAllowed": schemeDataJson["isPaymentAllowed"]
    };

    goalSubTypeSchemeJson["schemeData"]["folioOverviews"] = [folioJson];
    goalSubTypeSchemeJson["schemeData"]["folioOverview"] = folioJson;

    Map<String, dynamic>? minAmountJson = schemeDataJson["amountThresholds"];
    if (minAmountJson != null) {
      goalSubTypeSchemeJson["schemeData"]["minDepositAmt"] =
          minAmountJson["minDepositAmt"];
      goalSubTypeSchemeJson["schemeData"]["minSipDepositAmt"] =
          minAmountJson["minSipDepositAmt"];
      goalSubTypeSchemeJson["schemeData"]["minAddDepositAmt"] =
          minAmountJson["minAddDepositAmt"];
      goalSubTypeSchemeJson["schemeData"]["minWithdrawalAmt"] =
          minAmountJson["minWithdrawalAmt"];
    }
  } else {
    goalSubTypeSchemeJson["schemeData"] = {"wschemecode": data["wschemecode"]};
  }

  return UserGoalSubtypeSchemeModel.fromJson(goalSubTypeSchemeJson);
}
