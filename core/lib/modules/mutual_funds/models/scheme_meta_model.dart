import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';

class SchemeMetaModel {
  // Part of new MF lobby Fund API
  // =============================
  String? wpc;
  double? wRating;
  DateTime? launchDate;
  DateTime? closeDate;
  // =============================

  String? id;
  String? amc;
  String? amcName;
  String? schemeName;
  String? displayName;
  String? category;
  String? subcategory;
  String? fundType;
  double? expenseRatio;
  String? returnType;
  String? planType;
  String? schemeCode;
  String? wschemecode;
  int? exitLoadTime;
  String? exitLoadUnit;
  double? exitLoadPercentage;
  double? minDepositAmt;
  double? minAddDepositAmt;
  double? navAtLaunch;
  double? units;
  double? nav;
  DateTime? navDate;
  bool? isTaxSaver;
  double? minWithdrawalAmt;
  int? idealWeight;
  bool? forSwitch;
  double? amountEntered;
  bool? isNewFund;
  bool? wealthySelect;
  ReturnsModel? returns;
  // The below variables are not part of the scheme query
  bool? isDeprecated;
  FolioModel? folioOverview;
  List<FolioModel>? folioOverviews;
  double? currentInvestedValue;
  double? currentValue;
  String? transactionId;
  String? displayAmount;
  double? currentAbsoluteReturns;
  double? currentIrr;
  String? schemeStatus;
  String? amcCode;
  double? minSipDepositAmt;
  double? minAmcDepositAmt;
  bool? isPaymentAllowed;
  bool? isSipAllowed;
  String? classCode;
  double? wReturnScore;
  double? wRiskScore;
  double? wValuationScore;
  double? sd; // Standard Deviation
  double? pe;
  double? alpha;
  double? beta;
  double? aum;
  double? yieldTillMaturity;
  double? modifiedDuration;
  double? aaaSovereignAllocation;
  double? holdingInTop20Companies;
  double? wCreditQualityScore;

  String? benchmark;
  String? riskOMeterValue;
  String? taxationType;
  String? taxationTypeRemarks;
  String? objective;
  String? fundManagerProfile;
  String? fundManager;
  int? rankInCategory1Year;
  int? rankInCategory3Year;
  int? rankInCategory5Year;
  int? rankOutOfInCategory1Year;
  int? rankOutOfInCategory3Year;
  int? rankOutOfInCategory5Year;
  String? benchmarkTpid;
  bool? isNfo;
  DateTime? reopeningDate;
  DateTime? sipRegistrationStartDate;
  bool? isSif;

  // **** Any addition of fields should be reflected in the named constructor [clone]

  String get basketKey {
    if ((folioOverview?.exists ?? false) && wschemecode != null) {
      return '${wschemecode}${folioOverview!.folioNumber}';
    }

    return wschemecode ?? '';
  }

  SchemeMetaModel(
      {this.id,
      this.wpc,
      this.wRating,
      this.amc,
      this.amcName,
      this.schemeName,
      this.displayName,
      this.category,
      this.subcategory,
      this.fundType,
      this.expenseRatio,
      this.returnType,
      this.planType,
      this.schemeCode,
      this.wschemecode,
      this.exitLoadTime,
      this.exitLoadUnit,
      this.exitLoadPercentage,
      this.minDepositAmt,
      this.minAddDepositAmt,
      this.navAtLaunch,
      this.units,
      this.nav,
      this.navDate,
      this.idealWeight,
      this.isTaxSaver,
      this.minWithdrawalAmt,
      this.amountEntered,
      this.isNewFund = false,
      this.wealthySelect,
      this.isDeprecated,
      this.returns,
      this.currentInvestedValue,
      this.currentValue,
      this.folioOverview,
      this.folioOverviews,
      this.transactionId,
      this.displayAmount,
      this.currentAbsoluteReturns,
      this.currentIrr,
      this.amcCode,
      this.minSipDepositAmt,
      this.minAmcDepositAmt,
      this.schemeStatus,
      this.isPaymentAllowed,
      this.isSipAllowed,
      this.launchDate,
      this.closeDate,
      this.classCode,
      this.wReturnScore,
      this.wRiskScore,
      this.wValuationScore,
      this.sd,
      this.pe,
      this.alpha,
      this.beta,
      this.aum,
      this.yieldTillMaturity,
      this.modifiedDuration,
      this.aaaSovereignAllocation,
      this.holdingInTop20Companies,
      this.wCreditQualityScore,
      this.benchmark,
      this.riskOMeterValue,
      this.taxationType,
      this.taxationTypeRemarks,
      this.objective,
      this.fundManagerProfile,
      this.fundManager,
      this.rankInCategory1Year,
      this.rankInCategory3Year,
      this.rankInCategory5Year,
      this.rankOutOfInCategory1Year,
      this.rankOutOfInCategory3Year,
      this.rankOutOfInCategory5Year,
      this.benchmarkTpid,
      this.isNfo = false,
      this.sipRegistrationStartDate,
      this.reopeningDate,
      this.isSif});

  SchemeMetaModel.clone(SchemeMetaModel x)
      : this(
          id: x.id,
          wpc: x.wpc,
          wRating: x.wRating,
          amc: x.amc,
          amcName: x.amcName,
          schemeName: x.schemeName,
          displayName: x.displayName,
          category: x.category,
          subcategory: x.subcategory,
          fundType: x.fundType,
          expenseRatio: x.expenseRatio,
          returnType: x.returnType,
          planType: x.planType,
          schemeCode: x.schemeCode,
          wschemecode: x.wschemecode,
          exitLoadTime: x.exitLoadTime,
          exitLoadUnit: x.exitLoadUnit,
          exitLoadPercentage: x.exitLoadPercentage,
          minDepositAmt: x.minDepositAmt,
          minAddDepositAmt: x.minAddDepositAmt,
          navAtLaunch: x.navAtLaunch,
          units: x.units,
          nav: x.nav,
          navDate: x.navDate,
          idealWeight: x.idealWeight,
          isTaxSaver: x.isTaxSaver,
          minWithdrawalAmt: x.minWithdrawalAmt,
          amountEntered: x.amountEntered,
          isNewFund: x.isNewFund,
          wealthySelect: x.wealthySelect,
          isDeprecated: x.isDeprecated,
          returns: x.returns,
          currentInvestedValue: x.currentInvestedValue,
          currentValue: x.currentValue,
          folioOverview: x.folioOverview,
          folioOverviews: x.folioOverviews,
          transactionId: x.transactionId,
          displayAmount: x.displayAmount,
          currentIrr: x.currentIrr,
          currentAbsoluteReturns: x.currentAbsoluteReturns,
          amcCode: x.amcCode,
          minSipDepositAmt: x.minSipDepositAmt,
          minAmcDepositAmt: x.minAmcDepositAmt,
          schemeStatus: x.schemeStatus,
          isPaymentAllowed: x.isPaymentAllowed,
          isSipAllowed: x.isSipAllowed,
          launchDate: x.launchDate,
          closeDate: x.closeDate,
          wRiskScore: x.wRiskScore,
          wReturnScore: x.wReturnScore,
          wValuationScore: x.wValuationScore,
          sd: x.sd,
          pe: x.pe,
          alpha: x.alpha,
          beta: x.beta,
          aum: x.aum,
          yieldTillMaturity: x.yieldTillMaturity,
          modifiedDuration: x.modifiedDuration,
          aaaSovereignAllocation: x.aaaSovereignAllocation,
          holdingInTop20Companies: x.holdingInTop20Companies,
          wCreditQualityScore: x.wCreditQualityScore,
          benchmark: x.benchmark,
          riskOMeterValue: x.riskOMeterValue,
          taxationType: x.taxationType,
          taxationTypeRemarks: x.taxationTypeRemarks,
          objective: x.objective,
          fundManagerProfile: x.fundManagerProfile,
          fundManager: x.fundManager,
          rankInCategory1Year: x.rankInCategory1Year,
          rankInCategory3Year: x.rankInCategory3Year,
          rankInCategory5Year: x.rankInCategory5Year,
          rankOutOfInCategory1Year: x.rankOutOfInCategory1Year,
          rankOutOfInCategory3Year: x.rankOutOfInCategory3Year,
          rankOutOfInCategory5Year: x.rankOutOfInCategory5Year,
          benchmarkTpid: x.benchmarkTpid,
          isNfo: x.isNfo,
          sipRegistrationStartDate: x.sipRegistrationStartDate,
          reopeningDate: x.reopeningDate,
          isSif: x.isSif,
        );

  get fundCategory =>
      subcategory != null && subcategory!.isNotEmpty ? subcategory : category;

  bool get isNfoFund {
    try {
      if (this.closeDate == null) {
        return false;
      }

      DateTime today = DateTime.now();

      if (today.isBefore(closeDate!)) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  bool get isSwitchInAllowed {
    try {
      final today = DateTime.now();
      final isInvalid = sipRegistrationStartDate != null &&
          today.isBefore(sipRegistrationStartDate!);
      return !isInvalid;
    } catch (_) {
      return true;
    }
  }

  SchemeMetaModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id'] ?? json['objectID']);
    wpc = WealthyCast.toStr(json['wpc']);
    amc = json["amc"] is int
        ? AmcNumberCode[json["amc"]]
        : WealthyCast.toStr(json['amc']);
    amcName = WealthyCast.toStr(json['amcName'] ?? json['amc_name']);
    amcCode = WealthyCast.toStr(json['amcCode'] ?? json["amc_code"]);
    launchDate = WealthyCast.toDate(json['launch_date'] ?? json['launchDate']);
    closeDate = WealthyCast.toDate(json['close_date'] ?? json['closeDate']);

    schemeName = WealthyCast.toStr(json["scheme_name"] ?? json['schemeName']);
    displayName =
        WealthyCast.toStr(json['display_name'] ?? json['displayName']);
    category = WealthyCast.toStr(json['category']);
    subcategory = WealthyCast.toStr(json['subcategory']);
    fundType = WealthyCast.toStr(json['fund_type'] ?? json['fundType']);
    idealWeight =
        WealthyCast.toInt(json['ideal_weight'] ?? json['idealWeight']);
    expenseRatio = WealthyCast.toDouble(json['expense_ratio']) ??
        WealthyCast.toDouble(json['expenseRatio']);
    returnType = WealthyCast.toStr(json['return_type'] ?? json['returnType']);
    planType = WealthyCast.toStr(json['plan_type'] ?? json['planType']);
    schemeCode = WealthyCast.toStr(json['scheme_code'] ?? json['schemeCode']);
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    exitLoadTime = WealthyCast.toInt(json['exit_load_time']) ??
        WealthyCast.toInt(json['exitLoadTime']);
    exitLoadUnit =
        WealthyCast.toStr(json['exit_load_unit'] ?? json['exitLoadUnit']);
    exitLoadPercentage = WealthyCast.toDouble(json['exit_load_percentage']) ??
        WealthyCast.toDouble(json['exitLoadPercentage']);

    navAtLaunch = WealthyCast.toDouble(json['nav_at_launch']) ??
        WealthyCast.toDouble(json['navAtLaunch']);
    units = WealthyCast.toDouble(json['units']);
    nav = WealthyCast.toDouble(json['nav']);
    navDate = WealthyCast.toDate(json['nav_date'] ?? json['navDate']);
    isTaxSaver = WealthyCast.toBool(json['is_tax_saver'] ?? json['isTaxSaver']);
    minWithdrawalAmt = WealthyCast.toDouble(json['min_withdrawal_amt']) ??
        WealthyCast.toDouble(json['minWithdrawalAmt']);
    isNewFund =
        WealthyCast.toBool(json['is_new_fund'] ?? json['isNewFund'] ?? false);
    amountEntered = WealthyCast.toDouble(json['amountEntered']) ?? 0;
    classCode = WealthyCast.toStr(json['classCode']) ??
        WealthyCast.toStr(json['class_code']);
    wealthySelect = WealthyCast.toBool(
        json['wealthy_select'] ?? json['wealthySelect'] ?? false);
    returns = _createReturnModel(json);

    // Top Up Portfolio fields
    // =======================
    isDeprecated = WealthyCast.toBool(json["isDeprecated"]);
    folioOverview = FolioModel.fromJson(
        json["folioOverview"] ?? json["folio_overview"] ?? {});
    currentInvestedValue = WealthyCast.toDouble(
        json['currentInvestedValue'] ?? json['current_invested_value']);
    currentValue =
        WealthyCast.toDouble(json['currentValue'] ?? json["current_value"]);
    transactionId = WealthyCast.toStr(json['transactionId']);
    displayAmount =
        WealthyCast.toStr(json['displayAmount'] ?? json["display_amount"]);
    schemeStatus = WealthyCast.toStr(json['schemeStatus']);
    currentIrr = WealthyCast.toDouble(json['currentIrr'] ?? json["currentIRR"]);
    currentAbsoluteReturns = WealthyCast.toDouble(
        json['currentAbsoluteReturns'] ?? json["current_absolute_returns"]);
    isPaymentAllowed =
        json['isPaymentAllowed'] ?? json["is_payment_allowed"] ?? true;
    isSipAllowed = json['sipAllowed'] ?? json["sip_allowed"] ?? true;

    // Score Related Fields
    // ====================
    wReturnScore = WealthyCast.toDouble(
        json["w_return_score"] ?? WealthyCast.toDouble(json["wReturnScore"]));
    wRiskScore =
        WealthyCast.toDouble(json["w_risk_score"] ?? json["wRiskScore"]);
    wValuationScore = WealthyCast.toDouble(
      json["w_valuation_score"] ?? json["wValuationScore"],
    );
    sd = WealthyCast.toDouble(json["sd"]);
    alpha = WealthyCast.toDouble(json["alpha"]);
    beta = WealthyCast.toDouble(json["beta"]);
    aum = WealthyCast.toDouble(json["aum"]);
    pe = WealthyCast.toDouble(json["pe"]);
    wRating = WealthyCast.toDouble(json['w_rating'] ?? json['wRating']);
    yieldTillMaturity = WealthyCast.toDouble(json['yieldTillMaturity']);
    modifiedDuration = WealthyCast.toDouble(json['modifiedDuration']);
    aaaSovereignAllocation =
        WealthyCast.toDouble(json['aaaSovereignAllocation']);
    holdingInTop20Companies =
        WealthyCast.toDouble(json['holdingInTop20Companies']);
    wCreditQualityScore = WealthyCast.toDouble(json['wCreditQualityScore']);

    benchmark = WealthyCast.toStr(json["benchmark"]);
    riskOMeterValue = WealthyCast.toStr(json["riskOMeterValue"]);
    taxationType = WealthyCast.toStr(json["taxationType"]);
    taxationTypeRemarks = WealthyCast.toStr(json["taxationTypeRemarks"]);
    objective = WealthyCast.toStr(json["objective"]);
    fundManagerProfile = WealthyCast.toStr(json["fundManagerProfile"]);
    fundManager = WealthyCast.toStr(json["fundManager"]);
    rankInCategory1Year = WealthyCast.toInt(json["rankInCategory1Year"]);
    rankInCategory3Year = WealthyCast.toInt(json["rankInCategory3Year"]);
    rankInCategory5Year = WealthyCast.toInt(json["rankInCategory5Year"]);
    rankOutOfInCategory1Year =
        WealthyCast.toInt(json["rankOutOfInCategory1Year"]);
    rankOutOfInCategory3Year =
        WealthyCast.toInt(json["rankOutOfInCategory3Year"]);
    rankOutOfInCategory5Year =
        WealthyCast.toInt(json["rankOutOfInCategory5Year"]);
    benchmarkTpid = WealthyCast.toStr(json["benchmarkTpid"]);

    // Amount Fields
    // =============
    minDepositAmt = WealthyCast.toDouble(json['min_deposit_amt']) ??
        WealthyCast.toDouble(json['minDepositAmt']) ??
        1000;
    minSipDepositAmt = WealthyCast.toDouble(json['minSipDepositAmt']) ??
        WealthyCast.toDouble(json['min_sip_deposit_amt']) ??
        1000;
    minAmcDepositAmt = WealthyCast.toDouble(json['minAmcDepositAmt']) ??
        WealthyCast.toDouble(json['min_amc_deposit_amt']);
    minAddDepositAmt = WealthyCast.toDouble(json['minAddDepositAmt']) ??
        WealthyCast.toDouble(json['min_add_deposit_amt']) ??
        0;

    if (minDepositAmt.isNullOrZero || minDepositAmt! <= 10) {
      minDepositAmt = 1000;
    }
    if (minSipDepositAmt.isNullOrZero || minSipDepositAmt! <= 10) {
      minSipDepositAmt = 1000;
    }

    sipRegistrationStartDate = WealthyCast.toDate(
        json["sipRegistrationStartDate"] ??
            json["sip_registration_start_date"]);
    // Logic for Min. Amount/ Min. SIP Amount:
    // For Null Values or <=10 ->  Min is 1000(Both One Time and SIP)
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amc'] = this.amc;
    data['amcName'] = this.amcName;
    data['wpc'] = this.wpc;
    data['schemeName'] = this.schemeName;
    data['displayName'] = this.displayName;
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    data['fundType'] = this.fundType;
    data['expenseRatio'] = this.expenseRatio;
    data['returnType'] = this.returnType;
    data['planType'] = this.planType;
    data['schemeCode'] = this.schemeCode;
    data['wschemecode'] = this.wschemecode;
    data['exitLoadTime'] = this.exitLoadTime;
    data['exitLoadUnit'] = this.exitLoadUnit;
    data['exitLoadPercentage'] = this.exitLoadPercentage;
    data['minDepositAmt'] = this.minDepositAmt;
    data['minAddDepositAmt'] = this.minAddDepositAmt ?? 0;
    data['minSipDepositAmt'] = this.minSipDepositAmt;
    data['minAmcDepositAmt'] = this.minAmcDepositAmt;
    data['minWithdrawalAmt'] = this.minWithdrawalAmt;
    data['navAtLaunch'] = this.navAtLaunch;
    data['nav'] = this.nav;
    data['navDate'] = this.navDate;
    data['isTaxSaver'] = this.isTaxSaver;
    data['isNewFund'] = this.isNewFund;
    data['amountEntered'] = this.amountEntered;
    data['isDeprecated'] = this.isDeprecated;
    if (this.folioOverview != null) {
      data['folioOverview'] = this.folioOverview!.toJson();
    }
    data['currentInvestedValue'] = this.currentInvestedValue;
    data['transactionId'] = this.transactionId;
    data['currentValue'] = this.currentValue;
    data['amcCode'] = this.amcCode;
    data['displayAmount'] = this.displayAmount;
    data['isPaymentAllowed'] = this.isPaymentAllowed;
    data['isSipAllowed'] = this.isSipAllowed;

    data['launch_date'] = this.launchDate!.toIso8601String();

    if (this.returns != null) {
      data['returns'] = this.returns!.toJson();
    }
    return data;
  }

  SchemeMetaModel copyWith({
    String? id,
    String? amc,
    String? amcName,
    String? schemeName,
    String? displayName,
    String? category,
    String? subcategory,
    String? fundType,
    double? expenseRatio,
    String? returnType,
    String? planType,
    String? schemeCode,
    String? wschemecode,
    int? exitLoadTime,
    String? exitLoadUnit,
    double? exitLoadPercentage,
    double? minDepositAmt,
    double? minAddDepositAmt,
    double? minAmcDepositAmt,
    double? navAtLaunch,
    double? nav,
    DateTime? navDate,
    bool? isTaxSaver,
    double? minWithdrawalAmt,
    double? amountEntered,
    bool? isNewFund,
    bool? wealthySelect,
    ReturnsModel? returns,
    bool? isDeprecated,
    bool? isSif,
  }) =>
      SchemeMetaModel(
          id: id ?? this.id,
          amc: amc ?? this.amc,
          amcName: amcName ?? this.amcName,
          schemeName: schemeName ?? this.schemeName,
          displayName: displayName ?? this.displayName,
          category: category ?? this.category,
          subcategory: subcategory ?? this.subcategory,
          fundType: fundType ?? this.fundType,
          expenseRatio: expenseRatio ?? this.expenseRatio,
          returnType: returnType ?? this.returnType,
          planType: planType ?? this.planType,
          schemeCode: schemeCode ?? this.schemeCode,
          wschemecode: wschemecode ?? this.wschemecode,
          exitLoadTime: exitLoadTime ?? this.exitLoadTime,
          exitLoadUnit: exitLoadUnit ?? this.exitLoadUnit,
          exitLoadPercentage: exitLoadPercentage ?? this.exitLoadPercentage,
          minDepositAmt: minDepositAmt ?? this.minDepositAmt,
          minAddDepositAmt: minAddDepositAmt ?? this.minAddDepositAmt,
          minAmcDepositAmt: minAmcDepositAmt ?? this.minAmcDepositAmt,
          navAtLaunch: navAtLaunch ?? this.navAtLaunch,
          nav: nav ?? this.nav,
          navDate: navDate ?? this.navDate,
          isTaxSaver: isTaxSaver ?? this.isTaxSaver,
          minWithdrawalAmt: minWithdrawalAmt ?? this.minWithdrawalAmt,
          amountEntered: amountEntered ?? this.amountEntered,
          isNewFund: isNewFund ?? this.isNewFund,
          wealthySelect: wealthySelect ?? this.wealthySelect,
          returns: returns ?? this.returns,
          isDeprecated: isDeprecated ?? this.isDeprecated,
          isSif: isSif ?? this.isSif);
}

class FolioModel {
  String? id;
  String? folioNumber;
  String? schemeCode;
  double? investedAmount;
  double? withdrawalUnitsAvailable;
  double? withdrawalAmountAvailable;
  double? exitLoadFreeAmount;
  double? liveLtcg;
  double? liveStcg;
  double? currentValue;
  double? investedValue;
  double? units;
  bool? isDemat;
  DateTime? asOn;
  String? advisorArn;
  double? lockedUnits;

  FolioModel({
    this.id,
    this.folioNumber,
    this.currentValue,
    this.units,
    this.schemeCode,
    this.investedAmount,
    this.withdrawalUnitsAvailable,
    this.withdrawalAmountAvailable,
    this.exitLoadFreeAmount,
    this.liveLtcg,
    this.liveStcg,
    this.investedValue,
    this.isDemat,
    this.asOn,
    this.advisorArn,
    this.lockedUnits,
  });

  bool get exists => folioNumber != null;

  FolioModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    folioNumber =
        WealthyCast.toStr(json['folioNumber'] ?? json['folio_number']);
    schemeCode = WealthyCast.toStr(json['schemeCode']);
    investedAmount = WealthyCast.toDouble(json['investedAmount']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    investedValue = WealthyCast.toDouble(json['investedValue']);
    withdrawalUnitsAvailable =
        WealthyCast.toDouble(json["withdrawalUnitsAvailable"]);
    withdrawalAmountAvailable =
        WealthyCast.toDouble(json["withdrawalAmountAvailable"]);
    exitLoadFreeAmount = WealthyCast.toDouble(json["exitLoadFreeAmount"]);
    liveLtcg = WealthyCast.toDouble(json["liveLtcg"]);
    liveStcg = WealthyCast.toDouble(json["liveStcg"]);
    units = WealthyCast.toDouble(json['units']);
    isDemat = WealthyCast.toBool(json['isDemat']);
    advisorArn = WealthyCast.toStr(json['advisorArn']);
    asOn = WealthyCast.toDate(json['asOn']);
    lockedUnits = WealthyCast.toDouble(json['lockedUnits']);
  }

  FolioModel.clone(FolioModel x)
      : this(
          id: x.id,
          folioNumber: x.folioNumber,
          schemeCode: x.schemeCode,
          investedAmount: x.investedAmount,
          withdrawalUnitsAvailable: x.withdrawalUnitsAvailable,
          withdrawalAmountAvailable: x.withdrawalAmountAvailable,
          exitLoadFreeAmount: x.exitLoadFreeAmount,
          liveLtcg: x.liveLtcg,
          liveStcg: x.liveStcg,
          currentValue: x.currentValue,
          investedValue: x.investedValue,
          units: x.units,
          isDemat: x.isDemat,
          asOn: x.asOn,
          advisorArn: x.advisorArn,
          lockedUnits: x.lockedUnits,
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["folioNumber"] = this.folioNumber;
    data['schemeCode'] = this.schemeCode;
    data['investedAmount'] = this.investedAmount;
    data['currentValue'] = this.currentValue;
    data['units'] = this.units;
    data['lockedUnits'] = this.lockedUnits;

    return data;
  }
}

ReturnsModel? _createReturnModel(Map<String, dynamic> json) {
  // From Metahouse graphql query
  if (json['returns'] != null) {
    return ReturnsModel.fromJson(json['returns']);
  }

  // From new MF Lobby Fund API
  return ReturnsModel(
    rtrnsSinceLaunch:
        WealthyCast.toDouble(divideBy100(json['returns_since_inception'])),
    oneWeekRtrns: WealthyCast.toDouble(divideBy100(json['returns_one_week'])),
    oneMtRtrns: WealthyCast.toDouble(divideBy100(json['returns_one_month'])),
    threeMtRtrns:
        WealthyCast.toDouble(divideBy100(json['returns_three_months'])),
    sixMtRtrns: WealthyCast.toDouble(divideBy100(json['returns_six_months'])),
    oneYrRtrns: WealthyCast.toDouble(divideBy100(json['returns_one_year'])),
    threeYrRtrns:
        WealthyCast.toDouble(divideBy100(json['returns_three_years'])),
    fiveYrRtrns: WealthyCast.toDouble(divideBy100(json['returns_five_years'])),
  );
}

// Metahouse provides return divided by 100
// New Fund API provides return directly, without divided by 100
// Since metahouse API used in most places, return / 100 is standardised
double divideBy100(double? rtrn) {
  if (rtrn.isNullOrZero) {
    return 0;
  }

  return rtrn! / 100;
}

Map<int, String> AmcNumberCode = {
  1001: 'FRN',
  1004: 'RIL',
  1005: 'TRS',
  1007: 'SBI',
  1008: 'KKM',
  1009: 'ICI',
  1011: 'SNM',
  1013: 'LNT',
  1016: 'CNR',
  1020: 'PBG',
  1021: 'BNP',
  1023: 'DSP',
  1025: 'ABS',
  1026: 'UTI',
  1028: 'IDF',
  1029: 'TAT',
  1030: 'HDF',
  1033: 'PNP',
  1040: 'AXS',
  1045: 'MRE',
  1046: 'MOS',
  1051: 'INV',
  1052: 'EDL',
  1048: 'ESS',
  1044: 'PRF',
  1053: 'PFS',
  1054: 'QTI',
  1055: 'OAK',
  1050: 'HSB',
  1056: 'IIF',
  1057: 'MHD',
  1058: 'UNN',
  1047: 'LIC',
  1049: 'IDB',
  1062: 'JMF',
  1059: 'SMC',
  1060: 'ITI',
  1061: 'QMF',
  1063: 'BMF',
  1064: 'HLS',
  1065: 'TRT',
  1066: 'OBR',
  1067: 'BOI',
  1068: 'IND',
  1069: 'CPM',
  1070: 'UNF',
  1071: 'SBIS',
  1072: 'EDLS',
  1073: 'TWC',
  1074: 'QTIS',
  1075: 'ITIS',
  1076: 'TATS',
  1077: 'ABK',
  1078: 'BDHS',
  1079: 'ICIS'
};
