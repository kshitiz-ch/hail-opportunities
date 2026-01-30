import 'package:core/modules/common/resources/wealthy_cast.dart';

class MfSchemeTransactionModel {
  String? orderId;
  String? agentName;
  String? schemeName;
  String? schemeStatus;
  String? schemeStatusDisplay;
  int? category;
  double? units;
  double? nav;
  DateTime? navAllocatedAt;
  double? amount;
  DateTime? lastCheckedAt;
  String? email;
  String? phoneNumber;
  String? panNumber;
  String? name;

  String? crn;
  String? paymentBankName;
  String? paymentBankIfscCode;
  String? paymentBankAccountNumber;
  String? transactionTypeDisplay;
  String? transactionSourceDisplay;

  MfSchemeTransactionModel({
    this.orderId,
    this.agentName,
    this.schemeName,
    this.schemeStatus,
    this.category,
    this.schemeStatusDisplay,
    this.units,
    this.nav,
    this.navAllocatedAt,
    this.amount,
    this.email,
    this.phoneNumber,
    this.panNumber,
    this.name,
    this.crn,
    this.lastCheckedAt,
    this.paymentBankName,
    this.paymentBankAccountNumber,
    this.paymentBankIfscCode,
    this.transactionSourceDisplay,
    this.transactionTypeDisplay,
  });

  MfSchemeTransactionModel.fromJson(Map<String, dynamic> json) {
    orderId = WealthyCast.toStr(json['orderId']);
    agentName = WealthyCast.toStr(json['agentName']);
    schemeName = WealthyCast.toStr(json['schemeName']);
    category = WealthyCast.toInt(json['category']);
    schemeStatus = WealthyCast.toStr(json['schemeStatus']);
    schemeStatusDisplay = WealthyCast.toStr(json['schemeStatusDisplay']);
    units = WealthyCast.toDouble(json['units']);
    nav = WealthyCast.toDouble(json['nav']);
    navAllocatedAt = WealthyCast.toDate(json['navAllocatedAt']);
    amount = WealthyCast.toDouble(json['amount']);
    lastCheckedAt = WealthyCast.toDate(json['lastCheckedAt']);
    email = WealthyCast.toStr(json['email']);
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    panNumber = WealthyCast.toStr(json['panNumber']);
    name = WealthyCast.toStr(json['name']);
    crn = WealthyCast.toStr(json['crn']);
    paymentBankName = WealthyCast.toStr(json['paymentBankName']);
    paymentBankIfscCode = WealthyCast.toStr(json['paymentBankIfscCode']);
    paymentBankAccountNumber =
        WealthyCast.toStr(json['paymentBankAccountNumber']);

    transactionSourceDisplay =
        WealthyCast.toStr(json['transactionSourceDisplay']);
    transactionTypeDisplay = WealthyCast.toStr(json['transactionTypeDisplay']);
  }
}
