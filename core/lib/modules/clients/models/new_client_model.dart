import 'package:core/config/string_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class NewClientModel {
  String? name;
  String? email;
  DateTime? emailVerifiedAt;
  String? phoneNumber;
  DateTime? phoneVerifiedAt;
  DateTime? dob;
  String? gender;
  String? maritalStatus;
  String? crn;
  String? panNumber;
  int? noOfInsurance;
  int? tradingEnabled;
  DateTime? lastSeenAtDate;
  int? kycStatus;
  String? userId;
  String? customerId;
  DateTime? date;
  DateTime? asOnDate;
  int? agentId;
  String? agentExternalId;
  String? agentName;
  String? agentEmail;
  String? agentPhoneNumber;
  String? partnerNickname;
  List<int?>? accessibleTo;
  double? mfCurrentValue;
  double? mfCurrentInvestedValue;
  double? mfDebtCurrentValue;
  double? mfDebtCurrentInvestedValue;
  double? mfEquityCurrentValue;
  double? mfEquityCurrentInvestedValue;
  double? pmsCurrentValue;
  double? pmsCurrentInvestedValue;
  double? mldCurrentValue;
  double? mldCurrentInvestedValue;
  double? ncdCurrentValue;
  double? ncdCurrentInvestedValue;
  double? fdCurrentValue;
  double? fdCurrentInvestedValue;
  double? totalEquityCurrentValue;
  double? totalEquityCurrentInvestedValue;
  double? totalDebtCurrentValue;
  double? totalDebtCurrentInvestedValue;
  double? totalCommodityCurrentValue;
  double? totalCommodityCurrentInvestedValue;
  double? totalAlternativeCurrentValue;
  double? totalAlternativeCurrentInvestedValue;
  double? trakCobOpportunityValue;
  double? trakMfCurrentValue;
  DateTime? trakMfLastSyncedOnDate;
  double? totalCurrentValue;
  double? totalCurrentInvestedValue;
  String? panUsageType;
  String? panUsageSubtype;

  NewClientModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    email = WealthyCast.toStr(json['email']);
    emailVerifiedAt = WealthyCast.toDate(json['email_verified_at']);
    phoneNumber = WealthyCast.toStr(json['phone_number']);
    phoneVerifiedAt = WealthyCast.toDate(json['phone_verified_at']);
    dob = WealthyCast.toDate(json['dob']);
    gender = WealthyCast.toStr(json['gender']);
    maritalStatus = WealthyCast.toStr(json['marital_status']);
    crn = WealthyCast.toStr(json['crn']);
    panNumber = WealthyCast.toStr(json['pan_number']);
    noOfInsurance = WealthyCast.toInt(json['no_of_insurance']);
    tradingEnabled = WealthyCast.toInt(json['trading_enabled']);
    lastSeenAtDate = WealthyCast.toDate(json['last_seen_at_date']);
    kycStatus = WealthyCast.toInt(json['kyc_status']);
    userId = WealthyCast.toStr(json['user_id']);
    customerId = WealthyCast.toStr(json['customer_id']);
    date = WealthyCast.toDate(json['date']);
    asOnDate = WealthyCast.toDate(json['as_on_date']);
    agentId = WealthyCast.toInt(json['agent_id']);
    agentExternalId = WealthyCast.toStr(json['agent_external_id']);
    agentName = WealthyCast.toStr(json['agent_name']);
    agentEmail = WealthyCast.toStr(json['agent_email']);
    agentPhoneNumber = WealthyCast.toStr(json['agent_phone_number']);
    partnerNickname = WealthyCast.toStr(json['partner_nickname']);
    accessibleTo = WealthyCast.toList(json['accessible_to'])
        .map((e) => WealthyCast.toInt(e))
        .toList();
    mfCurrentValue = WealthyCast.toDouble(json['mf_current_value']);
    mfCurrentInvestedValue =
        WealthyCast.toDouble(json['mf_current_invested_value']);
    mfDebtCurrentValue = WealthyCast.toDouble(json['mf_debt_current_value']);
    mfDebtCurrentInvestedValue =
        WealthyCast.toDouble(json['mf_debt_current_invested_value']);
    mfEquityCurrentValue =
        WealthyCast.toDouble(json['mf_equity_current_value']);
    mfEquityCurrentInvestedValue =
        WealthyCast.toDouble(json['mf_equity_current_invested_value']);
    pmsCurrentValue = WealthyCast.toDouble(json['pms_current_value']);
    pmsCurrentInvestedValue =
        WealthyCast.toDouble(json['pms_current_invested_value']);
    mldCurrentValue = WealthyCast.toDouble(json['mld_current_value']);
    mldCurrentInvestedValue =
        WealthyCast.toDouble(json['mld_current_invested_value']);
    ncdCurrentValue = WealthyCast.toDouble(json['ncd_current_value']);
    ncdCurrentInvestedValue =
        WealthyCast.toDouble(json['ncd_current_invested_value']);
    fdCurrentValue = WealthyCast.toDouble(json['fd_current_value']);
    fdCurrentInvestedValue =
        WealthyCast.toDouble(json['fd_current_invested_value']);
    totalEquityCurrentValue =
        WealthyCast.toDouble(json['total_equity_current_value']);
    totalEquityCurrentInvestedValue =
        WealthyCast.toDouble(json['total_equity_current_invested_value']);
    totalDebtCurrentValue =
        WealthyCast.toDouble(json['total_debt_current_value']);
    totalDebtCurrentInvestedValue =
        WealthyCast.toDouble(json['total_debt_current_invested_value']);
    totalCommodityCurrentValue =
        WealthyCast.toDouble(json['total_commodity_current_value']);
    totalCommodityCurrentInvestedValue =
        WealthyCast.toDouble(json['total_commodity_current_invested_value']);
    totalAlternativeCurrentValue =
        WealthyCast.toDouble(json['total_alternative_current_value']);
    totalAlternativeCurrentInvestedValue =
        WealthyCast.toDouble(json['total_alternative_current_invested_value']);
    trakCobOpportunityValue =
        WealthyCast.toDouble(json['trak_cob_opportunity_value']);
    trakMfLastSyncedOnDate =
        WealthyCast.toDate(json['trak_mf_last_synced_on_date']);
    totalCurrentValue = WealthyCast.toDouble(json['total_current_value']);
    totalCurrentInvestedValue =
        WealthyCast.toDouble(json['total_current_invested_value']);
    panUsageType = WealthyCast.toStr(json['pan_usage_type']);
    panUsageSubtype = WealthyCast.toStr(json['pan_usage_subtype']);
    trakMfCurrentValue = WealthyCast.toDouble(json['trak_mf_current_value']);
  }

  Client getHydraClientModel() {
    final agentModel = AgentModel(
      name: agentName,
      email: agentEmail,
      phoneNumber: agentPhoneNumber,
      externalId: agentExternalId,
      id: agentId.toString(),
    );

    final nameList = name?.trim().split(' ') ?? [];
    final firstName = nameList.isNullOrEmpty ? name : nameList.first;
    final lastName = nameList.length > 1 ? nameList.last : '';

    return Client(
        agent: agentModel,
        id: customerId,
        taxyID: userId,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
        dob: dob,
        gender: gender,
        // accountId:,
        firstName: firstName,
        lastName: lastName,
        totalSelfCurrentValue: totalCurrentValue,
        lastSeenAt: lastSeenAtDate,
        totalNoOfInsurance: noOfInsurance,
        emailVerified: emailVerifiedAt != null,
        phoneVerified: phoneVerifiedAt != null,
        crn: crn,
        panNumber: panNumber,
        panUsageType: panUsageType,
        panUsageSubtype: panUsageSubtype,
        trakCobOpportunityValue: trakCobOpportunityValue,
        trakFamilyMfCurrentValue: trakMfCurrentValue);
  }
}
