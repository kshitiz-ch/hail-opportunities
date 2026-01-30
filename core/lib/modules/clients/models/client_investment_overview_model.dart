import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientInvestmentOverviewModel {
  String? userID;
  double? investedValue;
  double? currentValue;
  double? xirr;
  String? name;
  String? instrumentType;
  String? assetClass;
  DateTime? asOnDate;
  String? wschemecode;
  InvestmentSchemeData? schemeMetaData;

  ClientInvestmentOverviewModel({
    this.userID,
    this.investedValue,
    this.currentValue,
    this.xirr,
    this.name,
    this.instrumentType,
    this.assetClass,
    this.asOnDate,
    this.wschemecode,
    this.schemeMetaData,
  });

  ClientInvestmentOverviewModel.fromJson(Map<String, dynamic> json) {
    userID = WealthyCast.toStr(json['userID']);
    investedValue = WealthyCast.toDouble(json['investedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    xirr = WealthyCast.toDouble(json['xirr']);
    name = WealthyCast.toStr(json['name']);
    instrumentType = WealthyCast.toStr(json['instrumentType']);
    assetClass = WealthyCast.toStr(json['assetClass']);
    asOnDate = WealthyCast.toDate(json['asOnDate']);
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    schemeMetaData = json["schemeMetaData"] != null
        ? InvestmentSchemeData.fromJson(json["schemeMetaData"])
        : null;
  }
}

class InvestmentSchemeData {
  double? amount;
  DateTime? purchaseDate;
  double? interestRate;
  int? tenureMonths;
  String? payoutFreq;
  String? depositOption;
  double? currentInvestedValue;
  double? currentValue;
  double? currentIrr;
  DateTime? maturityDate;
  double? maturityAmount;
  String? ytm;
  String? units;
  String? isin;

  InvestmentSchemeData({
    this.amount,
    this.purchaseDate,
    this.interestRate,
    this.tenureMonths,
    this.payoutFreq,
    this.depositOption,
    this.currentInvestedValue,
    this.currentValue,
    this.currentIrr,
    this.maturityDate,
    this.maturityAmount,
    this.ytm,
    this.units,
    this.isin,
  });

  InvestmentSchemeData.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toDouble(json['amount']);
    purchaseDate = WealthyCast.toDate(json['purchaseDate']);
    interestRate = WealthyCast.toDouble(json['interestRate']);
    tenureMonths = WealthyCast.toInt(json['tenureMonths']);
    payoutFreq = WealthyCast.toStr(json['payoutFreq']);
    depositOption = WealthyCast.toStr(json['depositOption']);
    currentInvestedValue = WealthyCast.toDouble(json['currentInvestedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    currentIrr = WealthyCast.toDouble(json['currentIrr']);
    maturityDate = WealthyCast.toDate(json['maturityDate']);
    maturityAmount = WealthyCast.toDouble(json['maturityAmount']);
    ytm = WealthyCast.toStr(json['ytm']);
    units = WealthyCast.toStr(json['units']);
    isin = WealthyCast.toStr(json['isin']);
  }
}
