import 'package:core/modules/common/resources/wealthy_cast.dart';

class PmsTransactionModel {
  String? userId;
  String? pmsName;
  String? pmsClientId;
  String? manufacturer;
  String? status;
  String? segment;
  String? currentValue;
  String? currentInvestedValue;
  String? xirr;
  DateTime? asOnDate;
  DateTime? trnxDate;
  String? trnxType;
  String? amount;
  String? description;
  String? userName;
  String? userEmail;
  String? agentExternalId;
  String? agentName;

  String get transactionType => trnxType == 'D'
      ? 'Deposit'
      : trnxType == 'W'
          ? 'Withdrawal'
          : trnxType ?? '-';

  PmsTransactionModel({
    this.userId,
    this.pmsName,
    this.pmsClientId,
    this.manufacturer,
    this.status,
    this.segment,
    this.currentValue,
    this.currentInvestedValue,
    this.xirr,
    this.asOnDate,
    this.trnxDate,
    this.trnxType,
    this.amount,
    this.description,
    this.userName,
    this.userEmail,
    this.agentExternalId,
    this.agentName,
  });

  PmsTransactionModel.fromJson(Map<String, dynamic> json) {
    userId = WealthyCast.toStr(json['userId']);
    pmsName = WealthyCast.toStr(json['pmsName']);
    pmsClientId = WealthyCast.toStr(json['pmsClientId']);
    manufacturer = WealthyCast.toStr(json['manufacturer']);
    status = WealthyCast.toStr(json['status']);
    segment = WealthyCast.toStr(json['segment']);
    currentValue = WealthyCast.toStr(json['currentValue']);
    currentInvestedValue = WealthyCast.toStr(json['currentInvestedValue']);
    xirr = WealthyCast.toStr(json['xirr']);
    asOnDate = WealthyCast.toDate(json['asOnDate']);
    trnxDate = WealthyCast.toDate(json['trnxDate']);
    trnxType = WealthyCast.toStr(json['trnxType']);
    amount = WealthyCast.toStr(json['amount']);
    description = WealthyCast.toStr(json['description']);
    userName = WealthyCast.toStr(json['userName']);
    userEmail = WealthyCast.toStr(json['userEmail']);
    agentExternalId = WealthyCast.toStr(json['agentExternalId']);
    agentName = WealthyCast.toStr(json['agentName']);
  }
}
