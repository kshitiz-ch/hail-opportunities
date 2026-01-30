import 'package:core/modules/common/resources/wealthy_cast.dart';

import 'extras/portfolio_sips_model.dart';
import 'extras/portfolio_switches_model.dart';
import 'extras/portfolio_swps_model.dart';

class PortfolioExtrasModel {
  int? goalType;
  int? goalSubtype;
  int? goalSubtypeId;
  int? switchPeriod;
  int? goalEquityPercentage;
  List<PortfolioSipsModel>? sips;
  List<PortfolioSwitchesModel>? switches;
  List<PortfolioSwpsModel>? swps;
  dynamic status;
  String? bankAccountIfsc;
  String? bankAccountName;
  dynamic pmsAccountNumber;
  dynamic bankAccountNumber;

  PortfolioExtrasModel(
      {this.goalType,
      this.goalSubtype,
      this.goalSubtypeId,
      this.switchPeriod,
      this.goalEquityPercentage,
      this.sips,
      this.switches,
      this.swps,
      this.status,
      this.bankAccountIfsc,
      this.bankAccountName,
      this.pmsAccountNumber,
      this.bankAccountNumber});

  PortfolioExtrasModel.fromJson(Map<String, dynamic> json) {
    goalType = WealthyCast.toInt(json['goalType']);
    goalSubtype = WealthyCast.toInt(json['goalSubtype']);
    goalSubtypeId = WealthyCast.toInt(json['goalSubtypeId']);
    switchPeriod = WealthyCast.toInt(json['switchPeriod']);
    goalEquityPercentage = WealthyCast.toInt(json['goalEquityPercentage']);
    sips = WealthyCast.toList(json['sips'])
        .map((e) => PortfolioSipsModel.fromJson(e))
        .toList();
    switches = WealthyCast.toList(json['switches'])
        .map((e) => PortfolioSwitchesModel.fromJson(e))
        .toList();
    swps = WealthyCast.toList(json['swps'])
        .map((e) => PortfolioSwpsModel.fromJson(e))
        .toList();
    status = json['status'];
    bankAccountIfsc = WealthyCast.toStr(json['bankAccountIfsc']);
    bankAccountName = WealthyCast.toStr(json['bankAccountName']);
    pmsAccountNumber = json['pmsAccountNumber'];
    bankAccountNumber = json['bankAccountNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['goalType'] = this.goalType;
    data['goalSubtype'] = this.goalSubtype;
    data['goalSubtypeId'] = this.goalSubtypeId;
    data['switchPeriod'] = this.switchPeriod;
    data['goalEquityPercentage'] = this.goalEquityPercentage;
    if (this.sips != null) {
      data['sips'] = this.sips!.map((v) => v.toJson()).toList();
    }
    if (this.switches != null) {
      data['switches'] = this.switches!.map((v) => v.toJson()).toList();
    }
    if (this.swps != null) {
      data['swps'] = this.swps!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['bankAccountIfsc'] = this.bankAccountIfsc;
    data['bankAccountName'] = this.bankAccountName;
    data['pmsAccountNumber'] = this.pmsAccountNumber;
    data['bankAccountNumber'] = this.bankAccountNumber;
    return data;
  }
}
