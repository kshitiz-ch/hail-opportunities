import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:intl/intl.dart';

class MfTransactionModel {
  String? goalName;
  String? amc;
  String? folioNumber;
  String? fundType;
  String? category;
  String? transactionType;
  String? source;
  int? orderId;
  String? schemeOrderId;
  String? orderPrn;
  double? units;
  String? amount;
  String? nav;
  String? transactionId;
  String? schemeStatus;
  String? failureReason;
  String? createdAt;
  String? navAllocatedAt;
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? clientName;
  String? crn;
  String? userId;
  String? phoneNumber;
  DateTime? lastUpdatedAt;
  List<OrderStageAudit>? orderStageAudit;
  String? schemeName;
  bool? isSif;

  String get formatLastUpdatedAt {
    // Create a DateFormat object with the desired format.
    // d: Day of the month
    // MMM: Abbreviated month name
    // y: Year
    // jm: 12-hour format with minutes (e.g., 1:25 PM)
    final formatter = DateFormat('d MMM y, h:mm a');
    final data = lastUpdatedAt != null ? formatter.format(lastUpdatedAt!) : '-';
    return data;
  }

  bool get isNavAllocated {
    return navAllocatedAt != null;
  }

  bool get isSuccess {
    return schemeStatus == "S";
  }

  bool get isFailure {
    return schemeStatus == "F";
  }

  bool get isProgress {
    return schemeStatus == "P";
  }

  MfTransactionModel.fromJson(Map<String, dynamic> json) {
    goalName = WealthyCast.toStr(json['goalName']);
    amc = WealthyCast.toStr(json['amc']);
    folioNumber = WealthyCast.toStr(json['folioNumber']);
    fundType = WealthyCast.toStr(json['fundType']);
    category = WealthyCast.toStr(json['category']);
    transactionType = WealthyCast.toStr(json['transactionType']);
    source = WealthyCast.toStr(json['source']);
    orderId = WealthyCast.toInt(json['orderId']);
    schemeOrderId = WealthyCast.toStr(json['schemeOrderId']);
    orderPrn = WealthyCast.toStr(json['orderPrn']);
    units = WealthyCast.toDouble(json['units']);
    amount = WealthyCast.toStr(json['amount']);
    nav = WealthyCast.toStr(json['nav']);
    transactionId = WealthyCast.toStr(json['transactionId']);
    schemeStatus = WealthyCast.toStr(json['schemeStatus']);
    failureReason = WealthyCast.toStr(json['failureReason']);
    createdAt = WealthyCast.toStr(json['createdAt']);
    navAllocatedAt = WealthyCast.toStr(json['navAllocatedAt']);
    bankName = WealthyCast.toStr(json['bankName']);
    accountNumber = WealthyCast.toStr(json['accountNumber']);
    ifscCode = WealthyCast.toStr(json['ifscCode']);
    clientName = WealthyCast.toStr(json['clientName']);
    crn = WealthyCast.toStr(json['crn']);
    userId = WealthyCast.toStr(json['userId']);
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    lastUpdatedAt = WealthyCast.toDate(json['lastUpdatedAt']);
    schemeName = WealthyCast.toStr(json['schemeName']);
    // Parse isSif flag to identify SIF transactions for the SIF tab
    isSif = WealthyCast.toBool(json['isSif']);
    if (json['orderStageAudit'] != null) {
      orderStageAudit = <OrderStageAudit>[];
      json['orderStageAudit'].forEach((v) {
        orderStageAudit!.add(OrderStageAudit.fromJson(v));
      });
    }
  }
}

class OrderStageAudit {
  String? customerStageText;
  DateTime? stageEta;
  DateTime? stageLastUpdatedAt;
  String? stage;

  OrderStageAudit({
    this.customerStageText,
    this.stageEta,
    this.stageLastUpdatedAt,
    this.stage,
  });

  OrderStageAudit.fromJson(Map<String, dynamic> json) {
    customerStageText =
        WealthyCast.toStr(json['customerStageText'] ?? json['stageText']);
    stageEta = WealthyCast.toDate(json['stageEta']);
    stageLastUpdatedAt = WealthyCast.toDate(json['stageLastUpdatedAt']);
    stage = WealthyCast.toStr(json['stage']);
  }
}
