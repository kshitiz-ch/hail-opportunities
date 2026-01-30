import 'package:core/modules/common/resources/wealthy_cast.dart';

class BaseSwitch {
  DateTime? createdAt;
  DateTime? startDate;
  DateTime? pausedAt;
  DateTime? endDate;
  DateTime? resumedAt;
  DateTime? nextSwitch;
  String? id;
  String? externalId;
  double? amount;
  String? frequency;
  String? days;
  bool? isPaused;
  String? pausedReason;
  String? ticketNumber;
  String? lastSwitchStatus;
  String? customerFailureReason;
  List<SwitchFundsModel>? switchFunds;
  // List<Null>? switches;

  BaseSwitch({
    this.createdAt,
    this.id,
    this.externalId,
    this.amount,
    this.frequency,
    this.days,
    this.startDate,
    this.endDate,
    this.isPaused,
    this.pausedAt,
    this.pausedReason,
    this.resumedAt,
    this.ticketNumber,
    this.nextSwitch,
    this.lastSwitchStatus,
    this.customerFailureReason,
    this.switchFunds,
    // this.switches,
  });

  String get statusDescription {
    return getStatusDescription(this.lastSwitchStatus);
  }

  BaseSwitch.fromJson(Map<String, dynamic> json) {
    createdAt = WealthyCast.toDate(json['createdAt']);
    id = WealthyCast.toStr(json['id']);
    externalId = WealthyCast.toStr(json['externalId']);
    amount = WealthyCast.toDouble(json['amount']);
    frequency = WealthyCast.toStr(json['frequency']);
    days = WealthyCast.toStr(json['days']);
    startDate = WealthyCast.toDate(json['startDate']);
    endDate = WealthyCast.toDate(json['endDate']);
    isPaused = WealthyCast.toBool(json['isPaused']);
    pausedAt = WealthyCast.toDate(json['pausedAt']);
    pausedReason = WealthyCast.toStr(json['pausedReason']);
    resumedAt = WealthyCast.toDate(json['resumedAt']);
    ticketNumber = WealthyCast.toStr(json['ticketNumber']);
    nextSwitch = WealthyCast.toDate(json['nextSwitch']);
    lastSwitchStatus = WealthyCast.toStr(json['lastSwitchStatus']);
    customerFailureReason = WealthyCast.toStr(json['customerFailureReason']);
    if (json['switchFunds'] != null) {
      switchFunds = <SwitchFundsModel>[];
      json['switchFunds'].forEach((v) {
        switchFunds!.add(new SwitchFundsModel.fromJson(v));
      });
    }
    // if (json['switches'] != null) {
    //   switches = <Null>[];
    //   json['switches'].forEach((v) {
    //     switches!.add(new Null.fromJson(v));
    //   });
    // }
  }
}

class SwitchFundsModel {
  String? id;
  String? externalId;
  String? switchinWschemecode;
  String? switchoutWschemecode;
  String? switchinSchemeName;
  String? switchoutSchemeName;
  double? amount;
  String? folioNumber;

  SwitchFundsModel({
    this.id,
    this.externalId,
    this.switchinWschemecode,
    this.switchoutWschemecode,
    this.switchinSchemeName,
    this.switchoutSchemeName,
    this.amount,
    this.folioNumber,
  });

  SwitchFundsModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    externalId = WealthyCast.toStr(json['externalId']);
    switchinWschemecode = WealthyCast.toStr(json['switchinWschemecode']);
    switchoutWschemecode = WealthyCast.toStr(json['switchoutWschemecode']);
    switchinSchemeName = WealthyCast.toStr(json['switchinSchemeName']);
    switchoutSchemeName = WealthyCast.toStr(json['switchoutSchemeName']);
    amount = WealthyCast.toDouble(json['amount']);
    folioNumber = WealthyCast.toStr(json['folioNumber']);
  }
}

class StpOrderModel {
  String? id;
  String? orderId;
  String? status;
  double? amount;
  DateTime? switchDate;
  String? customerFailureReason;

  StpOrderModel({
    this.id,
    this.orderId,
    this.status,
    this.amount,
    this.switchDate,
    this.customerFailureReason,
  });

  String get statusDescription {
    return getStatusDescription(this.status);
  }

  StpOrderModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    orderId = WealthyCast.toStr(json['orderId']);
    status = WealthyCast.toStr(json['status']);
    amount = WealthyCast.toDouble(json['amount']);
    switchDate = WealthyCast.toDate(json['switchDate']);
    customerFailureReason = WealthyCast.toStr(json['customerFailureReason']);
  }
}

String getStatusDescription(String? status) {
  switch (status) {
    case "CR":
      return "Created";
    case "PR":
      return "Processing";
    case "OC":
      return "Order Created";
    case "OS":
      return "Order Success";
    case "FL":
      return "Failed";
    case "PS":
      return "Paused";
    case "NAC":
      return "Nav Allocated";
    default:
      return "-";
  }
}
