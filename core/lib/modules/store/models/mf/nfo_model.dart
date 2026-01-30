import 'package:core/modules/common/resources/wealthy_cast.dart';

class NfoModel {
  String? externalId;
  String? thirdPartyId;
  String? schemeName;
  String? companyName;
  DateTime? launchDate;
  DateTime? closeDate;
  double? minDepositAmt;
  double? minSipDepositAmt;
  String? offerPrice;
  String? schemeType;
  String? objective;
  String? size;
  String? category;
  String? fundType;
  String? classCode;
  bool? isPaymentAllowed;
  String? schemeCode;
  DateTime? allotmentDate;
  DateTime? reopeningDate;
  String? isin;
  String? wpc;

  NfoModel(
      {this.externalId,
      this.thirdPartyId,
      this.schemeName,
      this.companyName,
      this.launchDate,
      this.closeDate,
      this.minDepositAmt,
      this.offerPrice,
      this.schemeType,
      this.objective,
      this.size,
      this.category,
      this.fundType,
      this.classCode,
      this.isPaymentAllowed,
      this.schemeCode,
      this.allotmentDate,
      this.reopeningDate,
      this.isin,
      this.wpc});

  NfoModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    thirdPartyId = WealthyCast.toStr(json['third_party_id']);
    schemeName = WealthyCast.toStr(json['scheme_name']);
    companyName = WealthyCast.toStr(json['company_name']);
    launchDate = WealthyCast.toDate(json['launch_date']);
    closeDate = WealthyCast.toDate(json['close_date']);
    minDepositAmt = WealthyCast.toDouble(json['min_deposit_amt']);
    minSipDepositAmt = WealthyCast.toDouble(json['min_sip_deposit_amt']);
    offerPrice = WealthyCast.toStr(json['offer_price']);
    schemeType = WealthyCast.toStr(json['scheme_type']);
    objective = WealthyCast.toStr(json['objective']);
    size = WealthyCast.toStr(json['size']);
    category = WealthyCast.toStr(json['category']);
    fundType = WealthyCast.toStr(json['fund_type']);
    classCode = WealthyCast.toStr(json['class_code']);
    isPaymentAllowed = WealthyCast.toBool(json['is_payment_allowed']);
    schemeCode = WealthyCast.toStr(json['scheme_code']);
    allotmentDate = WealthyCast.toDate(json['allotment_date']);
    reopeningDate = WealthyCast.toDate(json['reopening_date']);
    isin = WealthyCast.toStr(json['isin']);
    wpc = WealthyCast.toStr(json['wpc']);
  }
}
