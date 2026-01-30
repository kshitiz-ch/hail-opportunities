import 'package:core/config/string_constants.dart';
import 'package:core/modules/clients/models/base_sip_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class GoalModel {
  String? id;
  int? goalId;
  String? displayName;

  double? currentInvestedValue;
  double? currentValue;
  double? currentIrr;
  double? currentAbsoluteReturns;
  double? currentEquityPercentage;
  double? currentDebtPercentage;
  GoalSubtype? goalSubtype;

  bool get isAnyFund => this.goalSubtype?.goalType == GoalType.ANY_FUNDS;
  bool get isCustomFund => this.goalSubtype?.goalType == GoalType.CUSTOM;
  bool get isWealthyFund => !isCustomFund && !isAnyFund;

  GoalModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    goalId = WealthyCast.toInt(json["goalId"]);
    displayName = WealthyCast.toStr(json["displayName"]);
    currentInvestedValue = WealthyCast.toDouble(json["currentInvestedValue"]);
    currentValue = WealthyCast.toDouble(json["currentValue"]);
    currentIrr = WealthyCast.toDouble(json["currentIrr"]);
    currentAbsoluteReturns =
        WealthyCast.toDouble(json["currentAbsoluteReturns"]);
    currentEquityPercentage =
        WealthyCast.toDouble(json["currentEquityPercentage"]);
    currentDebtPercentage = WealthyCast.toDouble(json["currentDebtPercentage"]);
    if (json["goalSubtype"] != null) {
      goalSubtype = GoalSubtype.fromJson(json["goalSubtype"]);
    }
  }
}
