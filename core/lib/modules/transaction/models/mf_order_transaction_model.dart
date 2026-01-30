import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/transaction/models/mf_scheme_transaction_model.dart';

class MfOrderTransactionModel {
  String? requestPrn;
  String? statusDisplay;
  String? sourceDisplay;
  int? orderType;
  String? goalTitleDisplay;
  double? lumsumAmount;
  int? status;
  String? failureReason;
  String? paymentBankName;
  String? paymentBankIfscCode;
  String? paymentBankAccountNumber;
  List<MfSchemeTransactionModel>? schemeOrders;
  List<OrderStageAudit>? orderStageAudit;
  String? crn;
  int? category;
  String? agentName;
  DateTime? lastUpdatedStageAt;
  DateTime? navAllocatedAt;
  String? transactionTypeDisplay;
  String? transactionSourceDisplay;
  Map? schemeStatusSummary;
  String? orderId;
  String? transactionId;

  MfOrderTransactionModel.fromJson(Map<String, dynamic> json) {
    orderId = WealthyCast.toStr(json['orderId']);
    transactionId = WealthyCast.toStr(json['transactionId']);
    requestPrn = WealthyCast.toStr(json['requestPrn']);
    statusDisplay = WealthyCast.toStr(json['statusDisplay']);
    sourceDisplay = WealthyCast.toStr(json['sourceDisplay']);
    orderType = WealthyCast.toInt(json['orderType']);
    goalTitleDisplay = WealthyCast.toStr(json['goalTitleDisplay']);
    lumsumAmount = WealthyCast.toDouble(json['lumsumAmount']);
    status = WealthyCast.toInt(json['status']);
    failureReason = WealthyCast.toStr(json['failureReason']);
    paymentBankName = WealthyCast.toStr(json['paymentBankName']);
    paymentBankIfscCode = WealthyCast.toStr(json['paymentBankIfscCode']);
    paymentBankAccountNumber =
        WealthyCast.toStr(json['paymentBankAccountNumber']);

    crn = WealthyCast.toStr(json['crn']);
    category = WealthyCast.toInt(json['category']);
    agentName = WealthyCast.toStr(json['agentName']);
    lastUpdatedStageAt = WealthyCast.toDate(json['lastUpdatedStageAt']);
    navAllocatedAt = WealthyCast.toDate(json['navAllocatedAt']);

    schemeStatusSummary = json['schemeStatusTitleDisplay'];
    transactionTypeDisplay = json['transactionTypeDisplay'];
    transactionSourceDisplay = json['transactionSourceDisplay'];

    if (json['schemeOrders'] != null) {
      schemeOrders = <MfSchemeTransactionModel>[];
      json['schemeOrders'].forEach((v) {
        schemeOrders!.add(MfSchemeTransactionModel.fromJson(v));
      });
    }
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

  String get insuranceStageText {
    switch (customerStageText?.toUpperCase()) {
      case 'PaymentInitiated':
        return 'Payment Initiated';
      case 'PaymentSuccessful':
        return 'Payment Successful';
      case 'PolicyGenereated':
        return 'Policy Genereated';
      case 'RevenueReleased':
        return 'Revenue Released';
      default:
        return '-';
    }
  }

  OrderStageAudit.fromJson(Map<String, dynamic> json) {
    customerStageText =
        WealthyCast.toStr(json['customerStageText'] ?? json['stageText']);
    stageEta = WealthyCast.toDate(json['stageEta']);
    stageLastUpdatedAt = WealthyCast.toDate(json['stageLastUpdatedAt']);
    stage = WealthyCast.toStr(json['stage']);
  }
}
