import 'package:core/modules/common/resources/wealthy_cast.dart';

class BrokingActivityModel {
  String? userId;
  String? ucc;
  String? name;
  String? agentId;
  double? totalPayin;
  double? totalPayout;
  double? brokerageFno;
  double? brokerageNse;
  double? brokerageTotal;
  double? partnerBrokerage;

  BrokingActivityModel({
    this.userId,
    this.ucc,
    this.name,
    this.agentId,
    this.totalPayin,
    this.totalPayout,
    this.brokerageFno,
    this.brokerageNse,
    this.brokerageTotal,
  });

  BrokingActivityModel.fromJson(Map<String, dynamic> json, DateTime date) {
    userId = WealthyCast.toStr(json['userId']);
    ucc = WealthyCast.toStr(json['ucc']);
    name = WealthyCast.toStr(json['name']);
    agentId = WealthyCast.toStr(json['agentId']);
    totalPayin = WealthyCast.toDouble(json['totalPayin']);
    totalPayout = WealthyCast.toDouble(json['totalPayout']);
    brokerageFno = WealthyCast.toDouble(json['brokerageFno']);
    brokerageNse = WealthyCast.toDouble(json['brokerageNse']);
    brokerageTotal = WealthyCast.toDouble(json['brokerageTotal']);

    // For before sept(including sept)--> 50%
    // After sept 2024 --> 70%
    final partnerPercent = date.isAfter(DateTime(2024, 9, 30)) ? 0.7 : 0.5;
    partnerBrokerage = (brokerageTotal ?? 0) * partnerPercent;
  }
}
