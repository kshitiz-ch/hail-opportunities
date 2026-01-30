import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

import 'insurance_investment_model.dart';

class UserPortfolioOverviewModel {
  UserPortfolioOverviewModel({
    this.asOn,
    this.total,
    this.mf,
    this.pms,
    this.fd,
    this.deb,
    this.preipo,
  });

  DateTime? asOn;
  GenericPortfolioOverviewModel? total;
  GenericPortfolioOverviewModel? mf;
  GenericPortfolioOverviewModel? fd;
  GenericPortfolioOverviewModel? pms;
  GenericPortfolioOverviewModel? deb;
  GenericPortfolioOverviewModel? preipo;
  GenericPortfolioOverviewModel? sif;

  UserPortfolioOverviewModel.fromJson(Map<String, dynamic> json) {
    asOn = WealthyCast.toDate(json['asOn']);
    total = json['total'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['total'])
        : null;
    mf = json['mf'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['mf'])
        : null;
    fd = json['fd'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['fd'])
        : null;
    pms = json['pms'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['pms'])
        : null;
    deb = json['deb'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['deb'])
        : null;
    preipo = json['preipo'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['preipo'])
        : null;
    sif = json['sif'] != null
        ? GenericPortfolioOverviewModel.fromJson(json['sif'])
        : null;
  }
}

class GenericPortfolioOverviewModel {
  GenericPortfolioOverviewModel({
    this.absoluteReturns,
    this.investedValue,
    this.currentValue,
    this.xirr,
    this.unrealisedGain,
    this.costOfCurrentInvestment,
  });

  double? unrealisedGain;
  double? absoluteReturns;
  double? currentValue;
  double? xirr;
  double? investedValue;
  double? costOfCurrentInvestment;

  GenericPortfolioOverviewModel.fromJson(Map<String, dynamic> json) {
    unrealisedGain = WealthyCast.toDouble(json['unrealisedGain']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    investedValue = WealthyCast.toDouble(json['investedValue']);
    absoluteReturns = WealthyCast.toDouble(json['absoluteReturns']);
    xirr = WealthyCast.toDouble(json['xirr']);
    costOfCurrentInvestment =
        WealthyCast.toDouble(json['costOfCurrentInvestment']);
  }
}

class ProductInvestmentModel {
  String? userID;
  double? investedValue;
  double? currentValue;
  double? xirr;
  String? name;
  String? instrumentType;
  double? absoluteReturn;
  double? unrealisedGain;
  InvestmentSchemeDataModel? schemeMetaData;

  ProductInvestmentModel.fromJson(Map<String, dynamic> json) {
    userID = WealthyCast.toStr(json['userID']);
    investedValue = WealthyCast.toDouble(json['investedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    xirr = WealthyCast.toDouble(json['xirr']);
    name = WealthyCast.toStr(json['name']);
    instrumentType = WealthyCast.toStr(json['instrumentType']);
    absoluteReturn = WealthyCast.toDouble(json['absoluteReturn']);
    unrealisedGain = WealthyCast.toDouble(json['unrealisedGain']);
    schemeMetaData = json["schemeMetaData"] != null
        ? InvestmentSchemeDataModel.fromJson(json["schemeMetaData"])
        : null;
  }
}

class InvestmentSchemeDataModel {
  double? inflow;
  double? outflow;
  double? netCapital;
  DateTime? lastUpdatedOn;

  InvestmentSchemeDataModel.fromJson(Map<String, dynamic> json) {
    inflow = WealthyCast.toDouble(json['inflow']);
    outflow = WealthyCast.toDouble(json['outflow']);
    netCapital = WealthyCast.toDouble(json['netCapital']);
    lastUpdatedOn = WealthyCast.toDate(json['lastUpdatedOn']);
  }
}

// TODO:
// Remove after integrating new holding API
class ClientInvestmentsModel {
  ClientInvestmentsModel({this.products, this.overview});

  InvestmentProductsModel? products;
  InvestmentOverviewModel? overview;

  ClientInvestmentsModel.fromJson(Map<String, dynamic> json) {
    overview = json['overview'] != null
        ? InvestmentOverviewModel.fromJson(json['overview'])
        : null;
    products = json['products'] != null
        ? InvestmentProductsModel.fromJson(json['products'])
        : null;
  }
}

class InvestmentProductsModel {
  InvestmentProductsModel(
      {this.mf,
      this.fd,
      this.pms,
      this.mld,
      this.unlistedStock,
      this.insurance});

  MfInvestmentModel? mf;
  GenericInvestmentModel? fd;
  GenericInvestmentModel? pms;
  GenericInvestmentModel? mld;
  GenericInvestmentModel? unlistedStock;
  InsuranceInvestmentModel? insurance;

  InvestmentProductsModel.fromJson(Map<String, dynamic> json) {
    mf = json['MF'] != null ? MfInvestmentModel.fromJson(json['MF']) : null;
    fd = json['FD'] != null
        ? GenericInvestmentModel<FixedDepositInvestmentModel>.fromJson(
            json['FD'])
        : null;
    pms = json['PMS'] != null
        ? GenericInvestmentModel<PmsInvestmentModel>.fromJson(json['PMS'])
        : null;
    mld = json['MLD'] != null
        ? GenericInvestmentModel<DebentureInvestmentModel>.fromJson(json['MLD'])
        : null;
    unlistedStock = json['UnlistedStock'] != null
        ? GenericInvestmentModel<UnlistedStockInvestmentModel>.fromJson(
            json['UnlistedStock'])
        : null;
    insurance = json['INSURANCE'] != null
        ? InsuranceInvestmentModel.fromJson(json['INSURANCE'])
        : null;
  }
}

// FD Investment Model
class GenericInvestmentModel<T> {
  GenericInvestmentModel({
    this.currentAbsoluteReturns,
    this.currentInvestedValue,
    this.currentValue,
    this.inprogress,
    this.products,
  });

  double? currentAbsoluteReturns;
  double? currentInvestedValue;
  double? currentValue;
  List<T>? inprogress;
  List<T>? products;

  GenericInvestmentModel.fromJson(Map<String, dynamic> json) {
    currentAbsoluteReturns =
        WealthyCast.toDouble(json['current_absolute_returns']);
    currentInvestedValue = WealthyCast.toDouble(json['current_invested_value']);
    currentValue = WealthyCast.toDouble(json['current_value']);
    inprogress = List<T>.from(
        WealthyCast.toList(json['inprogress']).map((x) => fromJson(x, T)));
    products = List<T>.from(
        WealthyCast.toList(json['products']).map((x) => fromJson(x, T)));
  }
}

fromJson(x, T) {
  if (T == DebentureInvestmentModel) {
    return DebentureInvestmentModel.fromJson(x);
  }

  if (T == UnlistedStockInvestmentModel) {
    return UnlistedStockInvestmentModel.fromJson(x);
  }

  if (T == PmsInvestmentModel) {
    return PmsInvestmentModel.fromJson(x);
  }

  if (T == FixedDepositInvestmentModel) {
    return FixedDepositInvestmentModel.fromJson(x);
  }
}

class InvestmentOverviewModel {
  InvestmentOverviewModel({this.currentInvestedValue, this.currentValue});

  double? currentInvestedValue;
  double? currentValue;

  InvestmentOverviewModel.fromJson(Map<String, dynamic> json) {
    currentInvestedValue = WealthyCast.toDouble(json["current_invested_value"]);
    currentValue = WealthyCast.toDouble(json["current_value"]);
  }
}

class DebentureInvestmentModel {
  String? externalId;
  String? schemeName;
  String? isin;
  int? status;
  int? currentInvestedValue;
  DateTime? settlementDate;
  DateTime? issueDate;
  DateTime? maturityDate;
  double? currentValue;
  bool? isMatured;

  DebentureInvestmentModel(
      {this.externalId,
      this.schemeName,
      this.isin,
      this.status,
      this.currentInvestedValue,
      this.settlementDate,
      this.issueDate,
      this.maturityDate,
      this.currentValue,
      this.isMatured});

  DebentureInvestmentModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    schemeName = WealthyCast.toStr(json['scheme_name']);
    isin = WealthyCast.toStr(json['isin']);
    status = WealthyCast.toInt(json['status']);
    currentInvestedValue = WealthyCast.toInt(json['current_invested_value']);
    settlementDate = WealthyCast.toDate(json['settlement_date']);
    issueDate = WealthyCast.toDate(json['issue_date']);
    maturityDate = WealthyCast.toDate(json['maturity_date']);
    currentValue = WealthyCast.toDouble(json['current_value']);
    isMatured = WealthyCast.toBool(json['is_matured']);
  }
}

class UnlistedStockInvestmentModel {
  String? externalId;
  String? securityName;
  String? isin;
  int? units;
  int? status;
  int? currentInvestedValue;
  DateTime? settlementDate;
  int? purchasePrice;
  int? currentPrice;
  int? currentValue;
  int? currentAbsoluteReturn;

  UnlistedStockInvestmentModel(
      {this.externalId,
      this.securityName,
      this.isin,
      this.units,
      this.status,
      this.currentInvestedValue,
      this.settlementDate,
      this.purchasePrice,
      this.currentPrice,
      this.currentValue,
      this.currentAbsoluteReturn});

  UnlistedStockInvestmentModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    securityName = WealthyCast.toStr(json['security_name']);
    isin = WealthyCast.toStr(json['isin']);
    units = WealthyCast.toInt(json['units']);
    status = WealthyCast.toInt(json['status']);
    currentInvestedValue = WealthyCast.toInt(json['current_invested_value']);
    settlementDate = WealthyCast.toDate(json['settlement_date']);
    purchasePrice = WealthyCast.toInt(json['purchase_price']);
    currentPrice = WealthyCast.toInt(json['current_price']);
    currentValue = WealthyCast.toInt(json['current_value']);
    currentAbsoluteReturn = WealthyCast.toInt(json['current_absolute_return']);
  }
}

class FixedDepositInvestmentModel {
  int? currentInvestedValue;
  int? currentValue;
  String? externalId;
  bool? isMatured;
  String? payoutFrequency;
  String? provider;
  double? returnsInterestRate;
  int? status;
  String? tenureMonths;

  FixedDepositInvestmentModel(
      {this.currentInvestedValue,
      this.currentValue,
      this.externalId,
      this.isMatured,
      this.payoutFrequency,
      this.provider,
      this.returnsInterestRate,
      this.status,
      this.tenureMonths});

  FixedDepositInvestmentModel.fromJson(Map<String, dynamic> json) {
    currentInvestedValue = WealthyCast.toInt(json['current_invested_value']);
    currentValue = WealthyCast.toInt(json['current_value']);
    externalId = WealthyCast.toStr(json['external_id']);
    isMatured = WealthyCast.toBool(json['is_matured']);
    payoutFrequency = WealthyCast.toStr(json['payout_frequency']);
    provider = WealthyCast.toStr(json['provider']);
    returnsInterestRate = WealthyCast.toDouble(json['returns_interest_rate']);
    status = WealthyCast.toInt(json['status']);
    tenureMonths = WealthyCast.toStr(json['tenure_months']);
  }
}

class PmsInvestmentModel {
  DateTime? accountOpenedAt;
  DateTime? asOnDate;
  int? currentInvestedValue;
  double? currentIrr;
  int? currentValue;
  String? externalId;
  String? manufacturer;
  String? pmsClientId;
  String? pmsName;
  String? status;

  PmsInvestmentModel(
      {this.accountOpenedAt,
      this.asOnDate,
      this.currentInvestedValue,
      this.currentIrr,
      this.currentValue,
      this.externalId,
      this.manufacturer,
      this.pmsClientId,
      this.pmsName,
      this.status});

  PmsInvestmentModel.fromJson(Map<String, dynamic> json) {
    accountOpenedAt = WealthyCast.toDate(json['account_opened_at']);
    asOnDate = WealthyCast.toDate(json['as_on_date']);
    currentInvestedValue = WealthyCast.toInt(json['current_invested_value']);
    currentIrr = WealthyCast.toDouble(json['current_irr']);
    currentValue = WealthyCast.toInt(json['current_value']);
    externalId = WealthyCast.toStr(json['external_id']);
    manufacturer = WealthyCast.toStr(json['manufacturer']);
    pmsClientId = WealthyCast.toStr(json['pms_client_id']);
    pmsName = WealthyCast.toStr(json['pms_name']);
    status = WealthyCast.toStr(json['status']);
  }
}
