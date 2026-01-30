import 'package:core/modules/common/resources/wealthy_cast.dart';

class SifModel {
  DateTime? createdAt;
  DateTime? updatedAt;
  String? externalId;
  String? wpc;
  String? amc;
  String? amcName;
  String? schemeName;
  String? schemeCode;
  String? strategyType;
  String? benchmark;
  String? exitLoad;
  DateTime? launchDate;
  DateTime? closeDate;
  DateTime? allotmentDate;
  DateTime? reopeningDate;
  DateTime? maturityDate;
  String? amfiCode;
  String? isin;
  double? minDepositAmt;
  double? minSipDepositAmt;
  double? minAmcDepositAmt;
  String? objective;
  String? riskBand;
  String? benchmarkRiskBand;
  DateTime? navDate;
  double? nav;
  double? navAtLaunch;

  SifModel({
    this.createdAt,
    this.updatedAt,
    this.externalId,
    this.wpc,
    this.amc,
    this.amcName,
    this.schemeName,
    this.schemeCode,
    this.strategyType,
    this.benchmark,
    this.exitLoad,
    this.launchDate,
    this.closeDate,
    this.allotmentDate,
    this.reopeningDate,
    this.maturityDate,
    this.amfiCode,
    this.isin,
    this.minDepositAmt,
    this.minSipDepositAmt,
    this.minAmcDepositAmt,
    this.objective,
    this.riskBand,
    this.benchmarkRiskBand,
    this.navDate,
    this.nav,
    this.navAtLaunch,
  });

  factory SifModel.fromJson(Map<String, dynamic> json) {
    // If reopening date is not present, set it to 5 days after allotment date
    DateTime? reopeningDate = WealthyCast.toDate(json['reopening_date']);
    DateTime? allotmentDate = WealthyCast.toDate(json['allotment_date']);
    if (reopeningDate == null && allotmentDate != null) {
      reopeningDate = allotmentDate.add(Duration(days: 5));
    }
    return SifModel(
      createdAt: WealthyCast.toDate(json['created_at']),
      updatedAt: WealthyCast.toDate(json['updated_at']),
      externalId: WealthyCast.toStr(json['external_id']),
      wpc: WealthyCast.toStr(json['wpc']),
      amc: WealthyCast.toStr(json['amc']),
      amcName: WealthyCast.toStr(json['amc_name']),
      schemeName: WealthyCast.toStr(json['scheme_name']),
      schemeCode: WealthyCast.toStr(json['scheme_code']),
      strategyType: WealthyCast.toStr(json['strategy_type']),
      benchmark: WealthyCast.toStr(json['benchmark']),
      exitLoad: WealthyCast.toStr(json['exit_load']),
      launchDate: WealthyCast.toDate(json['launch_date']),
      closeDate: WealthyCast.toDate(json['close_date']),
      maturityDate: WealthyCast.toDate(json['maturity_date']),
      amfiCode: WealthyCast.toStr(json['amfi_code']),
      isin: WealthyCast.toStr(json['isin']),
      minDepositAmt: WealthyCast.toDouble(json['min_deposit_amt']),
      minSipDepositAmt:
          WealthyCast.toDouble(json['min_sip_deposit_amt']) ?? 10000,
      // Default SIP amount to 10,000 if not provided
      minAmcDepositAmt: WealthyCast.toDouble(json['min_amc_deposit_amt']),
      objective: WealthyCast.toStr(json['objective']),
      riskBand: WealthyCast.toStr(json['risk_band']),
      benchmarkRiskBand: WealthyCast.toStr(json['benchmark_risk_band']),
      allotmentDate: allotmentDate,
      reopeningDate: reopeningDate,
      navDate: WealthyCast.toDate(json['nav_date']),
      nav: WealthyCast.toDouble(json['nav']),
      navAtLaunch: WealthyCast.toDouble(json['nav_at_launch']),
    );
  }
}
