import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

import 'base_sip_model.dart';

class TransactionCategoryType {
  static const Deposit = 0;
  static const WithDrawal = 1;
  static const Siso = 2;
  static const SwitchIn = 3;
}

class ClientOrderModel {
  ClientOrderModel(
      {this.category,
      this.id,
      this.createdAt,
      this.displayAmount,
      this.orderId,
      this.paymentMode,
      this.requestPrn,
      this.source,
      this.status,
      this.estProcessedAt,
      this.navAllocatedAt,
      this.goal,
      this.schemeOrders});

  String? id;
  int? category;
  DateTime? createdAt;
  String? displayAmount;
  String? paymentMode;
  String? requestPrn;
  int? orderId;
  String? source;
  int? status;
  DateTime? estProcessedAt;
  DateTime? navAllocatedAt;
  ClientGoalModel? goal;
  List<SchemeOrderModel>? schemeOrders;

  bool get isProcessing => this.status == 2;

  String get categoryDescription {
    String description = '';
    switch (this.category) {
      case TransactionCategoryType.Deposit:
        description = "Deposit";
        break;
      case TransactionCategoryType.WithDrawal:
        description = "Withdrawal";
        break;
      case TransactionCategoryType.Siso:
        description = "SISO";
        break;
      case TransactionCategoryType.SwitchIn:
        description = "Switch In";
    }
    return description;
  }

  factory ClientOrderModel.fromJson(Map<String, dynamic> json) =>
      ClientOrderModel(
          id: WealthyCast.toStr(json["id"]),
          category: WealthyCast.toInt(json["category"]),
          createdAt: WealthyCast.toDate(json["createdAt"]),
          displayAmount: WealthyCast.toStr(json["displayAmount"]),
          orderId: WealthyCast.toInt(json["orderId"]),
          requestPrn: WealthyCast.toStr(json["requestPrn"]),
          paymentMode: WealthyCast.toStr(json["paymentMode"]),
          source: WealthyCast.toStr(json["source"]),
          status: WealthyCast.toInt(json["status"]),
          estProcessedAt: WealthyCast.toDate(json["estProcessedAt"]),
          navAllocatedAt: WealthyCast.toDate(json["navAllocatedAt"]),
          goal: json["goal"] != null
              ? ClientGoalModel.fromJson(json["goal"])
              : null,
          schemeOrders: WealthyCast.toList(json["schemeorders"])
              .map<SchemeOrderModel>((x) => SchemeOrderModel.fromJson(x))
              .toList());
}

class ClientGoalModel {
  ClientGoalModel({this.displayName, this.id, this.name, this.goalSubtype});

  String? id;
  String? displayName;
  String? name;
  GoalSubtype? goalSubtype;

  factory ClientGoalModel.fromJson(Map<String, dynamic> json) =>
      ClientGoalModel(
        id: WealthyCast.toStr(json["id"]),
        displayName: WealthyCast.toStr(json["displayName"]),
        name: WealthyCast.toStr(json["name"]),
        goalSubtype: json["goalSubtype"] != null
            ? GoalSubtype.fromJson(json["goalSubtype"])
            : null,
      );
}

class SchemeOrderModel {
  SchemeOrderModel({
    this.schemeName,
    this.id,
    this.amc,
    this.folioNumber,
    this.displayName,
    this.displayAmount,
    this.wschemecode,
    this.category,
    this.navAllocatedAt,
    this.transactionId,
    this.schemeStatus,
    this.units,
    this.nav,
  });

  String? schemeName;
  String? id;
  String? amc;
  String? folioNumber;
  String? displayName;
  String? displayAmount;
  String? wschemecode;
  int? category;
  DateTime? navAllocatedAt;
  String? transactionId;
  String? schemeStatus;
  double? units;
  double? nav;

  String get categoryDescription {
    String description = '';
    switch (this.category) {
      case TransactionCategoryType.Deposit:
        description = "Deposit";
        break;
      case TransactionCategoryType.WithDrawal:
        description = "Withdrawal";
        break;
      case TransactionCategoryType.Siso:
        description = "SISO";
        break;
      case TransactionCategoryType.SwitchIn:
        description = "Switch In";
    }
    return description;
  }

  SchemeOrderModel.fromJson(Map<String, dynamic> json) {
    schemeName = WealthyCast.toStr(json["schemeName"]);
    id = WealthyCast.toStr(json["id"]);
    amc = WealthyCast.toStr(json["amc"]);
    folioNumber = WealthyCast.toStr(json["folioNumber"]);
    displayName = WealthyCast.toStr(json["displayName"]);
    displayAmount = WealthyCast.toStr(json["displayAmount"]);
    wschemecode = WealthyCast.toStr(json["wschemecode"]);
    category = WealthyCast.toInt(json["category"]);
    navAllocatedAt = WealthyCast.toDate(json["navAllocatedAt"]);
    transactionId = WealthyCast.toStr(json["transactionId"]);
    schemeStatus = WealthyCast.toStr(json["schemeStatus"]);
    units = WealthyCast.toDouble(json["units"]);
    nav = WealthyCast.toDouble(json["nav"]);
  }
}
