import 'package:core/modules/common/resources/wealthy_cast.dart';

class TrackerAggMetricsModel {
  int? totalUsers;
  double? totalCobOpportunityValue;
  double? totalFamilyMfCurrentValue;

  TrackerAggMetricsModel(
      {this.totalUsers,
      this.totalCobOpportunityValue,
      this.totalFamilyMfCurrentValue});

  TrackerAggMetricsModel.fromJson(Map<String, dynamic> json) {
    totalUsers = WealthyCast.toInt(json['totalUsers']);
    totalCobOpportunityValue =
        WealthyCast.toDouble(json['totalCobOpportunityValue']);
    totalFamilyMfCurrentValue =
        WealthyCast.toDouble(json['totalFamilyMfCurrentValue']);
  }
}

class TrackerUserModel {
  String? name;
  String? taxyId;
  String? crn;
  double? trakCobOpportunityValue;
  double? trakFamilyMfCurrentValue;

  TrackerUserModel({
    this.name,
    this.taxyId,
    this.crn,
    this.trakCobOpportunityValue,
    this.trakFamilyMfCurrentValue,
  });

  TrackerUserModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    taxyId = WealthyCast.toStr(json['taxyId']);
    crn = WealthyCast.toStr(json['crn']);
    trakCobOpportunityValue =
        WealthyCast.toDouble(json['trakCobOpportunityValue']);
    trakFamilyMfCurrentValue =
        WealthyCast.toDouble(json['trakFamilyMfCurrentValue']);
  }
}
