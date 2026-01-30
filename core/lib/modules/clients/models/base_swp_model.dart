import 'package:core/modules/common/resources/wealthy_cast.dart';

class BaseSwpModel {
  DateTime? createdAt;
  String? externalId;
  int? amount;
  List<int>? days;
  DateTime? startDate;
  DateTime? endDate;
  bool? isPaused;
  DateTime? pausedAt;
  DateTime? resumedAt;
  DateTime? nextSwp;
  List<SwpFunds>? swpFunds;

  BaseSwpModel({
    this.createdAt,
    this.externalId,
    this.amount,
    this.days,
    this.startDate,
    this.endDate,
    this.isPaused,
    this.pausedAt,
    this.resumedAt,
    this.nextSwp,
    this.swpFunds,
  });

  BaseSwpModel.fromJson(Map<String, dynamic> json) {
    createdAt = WealthyCast.toDate(json['createdAt']);
    externalId = WealthyCast.toStr(json['externalId']);
    amount = WealthyCast.toInt(json['amount']);
    days = (WealthyCast.toStr(json['days']) ?? '')
        .split(',')
        .map((day) => WealthyCast.toInt(day)!)
        .toList();
    startDate = WealthyCast.toDate(json['startDate']);
    endDate = WealthyCast.toDate(json['endDate']);
    isPaused = WealthyCast.toBool(json['isPaused']);
    pausedAt = WealthyCast.toDate(json['pausedAt']);
    resumedAt = WealthyCast.toDate(json['resumedAt']);
    nextSwp = WealthyCast.toDate(json['nextSwp']);
    swpFunds = WealthyCast.toList(json['swpFunds'])
        .map((swpFundJson) => SwpFunds.fromJson(swpFundJson))
        .toList();
  }

  // Deep copy
  BaseSwpModel clone() {
    return BaseSwpModel(
      createdAt: this.createdAt,
      externalId: this.externalId,
      amount: this.amount,
      days: this.days,
      startDate: this.startDate,
      endDate: this.endDate,
      isPaused: this.isPaused,
      pausedAt: this.pausedAt,
      resumedAt: this.resumedAt,
      nextSwp: this.nextSwp,
      swpFunds: this.swpFunds,
    );
  }
}

class SwpFunds {
  String? wschemecode;
  String? schemeName;
  double minWithdrawalAmt = 0;
  String? folioNumber;

  SwpFunds({
    this.wschemecode,
    this.schemeName,
    this.folioNumber,
  });

  SwpFunds.fromJson(Map<String, dynamic> json) {
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    schemeName = WealthyCast.toStr(json['schemeName']);
    folioNumber = WealthyCast.toStr(json['folioNumber']);
  }
}
