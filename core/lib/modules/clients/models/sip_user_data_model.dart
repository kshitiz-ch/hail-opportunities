import 'package:core/modules/common/resources/wealthy_cast.dart';

class SipUserDataModel {
  String? id;
  String? userId;
  String? name;
  String? sipDays;
  String? fundName;
  DateTime? startDate;
  DateTime? endDate;
  double? sipAmount;
  DateTime? lastSipDate;
  String? lastSipStatus;
  String? failureReason;
  String? goalName;
  bool? isPaused;
  bool? mandateApproved;
  bool? isSipActive;
  bool? stepperEnabled;
  String? pauseReason;
  String? crn;
  String? agentName;
  String? email;
  String? phoneNumber;
  String? goalExternalId;
  int? goalType;
  String? incrementPeriod;
  int? incrementPercentage;
  List<SipDayData>? sipDayData;
  List<SipMetaScheme>? sipMetaFunds;

  String? sipMetaId;
  String? agentExternalId;

  String? paymentBankAccountId;

  bool get isTaxSaver => this.goalType == 0;

  String get stepUpPeriodText {
    if (incrementPeriod?.toLowerCase() == '6m') {
      return '6 Months';
    }
    return '1 Year';
  }

  SipUserDataModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    userId = WealthyCast.toStr(json['userId']);
    name = WealthyCast.toStr(json['name']);
    sipDays = WealthyCast.toStr(json['sipDays']);
    fundName = WealthyCast.toStr(json['fundName']);
    startDate = WealthyCast.toDate(json['startDate']);
    endDate = WealthyCast.toDate(json['endDate']);
    sipAmount = WealthyCast.toDouble(json['sipAmount']);
    lastSipDate = WealthyCast.toDate(json['lastSipDate']);
    lastSipStatus = WealthyCast.toStr(json['lastSipStatus']);
    failureReason = WealthyCast.toStr(json['failureReason']);
    goalName = WealthyCast.toStr(json['goalName']);
    isPaused = WealthyCast.toBool(json['isPaused']);
    mandateApproved = WealthyCast.toBool(json['mandateApproved']);
    isSipActive = WealthyCast.toBool(json['isSipActive']);
    stepperEnabled = WealthyCast.toBool(json['stepperEnabled']);
    pauseReason = WealthyCast.toStr(json['pauseReason']);
    crn = WealthyCast.toStr(json['crn']);
    agentName = WealthyCast.toStr(json['agentName']);
    email = WealthyCast.toStr(json['email']);
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    goalExternalId = WealthyCast.toStr(json['goalExternalId']);
    goalType = WealthyCast.toInt(json['goalType']);
    incrementPercentage = WealthyCast.toInt(json['incrementPercentage']);
    incrementPeriod = WealthyCast.toStr(json['incrementPeriod']);
    sipMetaId = WealthyCast.toStr(json['sipMetaId']);
    agentExternalId = WealthyCast.toStr(json['agentExternalId']);
    paymentBankAccountId = WealthyCast.toStr(json['paymentBankAccountId']);
    if (json['sipDayData'] != null) {
      sipDayData = <SipDayData>[];
      json['sipDayData'].forEach((v) {
        sipDayData!.add(new SipDayData.fromJson(v));
      });
    }
    if (json['sipMetaFunds'] != null) {
      sipMetaFunds = <SipMetaScheme>[];
      json['sipMetaFunds'].forEach((v) {
        sipMetaFunds!.add(new SipMetaScheme.fromJson(v));
      });
    }
  }
}

class SipDayData {
  int? day;
  String? status;
  DateTime? sipDate;
  String? sTypename;

  SipDayData({this.day, this.status, this.sipDate, this.sTypename});

  SipDayData.fromJson(Map<String, dynamic> json) {
    day = WealthyCast.toInt(json['day']);
    status = WealthyCast.toStr(json['status']);
    sipDate = WealthyCast.toDate(json['sipDate']);
    sTypename = WealthyCast.toStr(json['__typename']);
  }
}

class SipMetaScheme {
  String? wschemecode;
  double? amount;
  String? schemeName;

  SipMetaScheme({this.wschemecode, this.amount, this.schemeName});

  SipMetaScheme.fromJson(Map<String, dynamic> json) {
    schemeName = WealthyCast.toStr(json['schemeName']);
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    amount = WealthyCast.toDouble(json['amount']);
  }
}
