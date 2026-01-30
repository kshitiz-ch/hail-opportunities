import 'package:core/config/string_constants.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/clients/models/new_client_model.dart';

class ClientListModel {
  ClientListModel({
    this.id,
    this.clients,
    this.customerCount,
  });

  String? id;
  List<Client>? clients;
  int? customerCount;

  factory ClientListModel.fromJson(Map<String, dynamic> json) =>
      ClientListModel(
        id: WealthyCast.toStr(json["id"]),
        customerCount: WealthyCast.toInt(json['customerCount']),
        clients: List<Client>.from(
            WealthyCast.toList(json["clients"]).map((x) => Client.fromJson(x))),
      );
}

class Client {
  Client({
    this.id,
    this.taxyID,
    this.email,
    this.agent,
    this.mfEmail,
    this.phoneNumber,
    this.name,
    this.dob,
    this.gender,
    this.accountId,
    this.hasMandate,
    this.firstName,
    this.lastName,
    this.firstTransactionAt,
    this.source,
    this.wealthyInvestedValue,
    this.wealthyIrr,
    this.wealthyCurrentValue,
    this.trakMfIrr,
    this.totalFamilyCurrentValue,
    this.totalSelfCurrentValue,
    this.frequentSeenLocation,
    this.lastSeenAt,
    this.investorActivatedAt,
    this.privilegeActivatedAt,
    this.currentAgentAssignedAt,
    this.sourceType,
    this.investmentCurrentValue,
    this.loanCurrentValue,
    this.insuranceCurrentValue,
    this.agentTotalRevenue,
    this.currentMonthPipelinedRevenue,
    this.totalNoOfInsurance,
    this.unlistedStocksCurrentValue,
    this.isSourceContacts = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.relation,
    this.crn,
    this.panNumber,
    this.panUsageType,
    this.panUsageSubtype,
    this.totalMfPansTracked,
    this.trakCobOpportunityValue,
    this.trakFamilyMfCurrentValue,
  });

  get isProposalEnabled {
    // In case [panUsageType] not populated from backend
    if (panUsageType.isNullOrEmpty) {
      return true;
    }

    if (this.isClientIndividual || panUsageType == PanUsageType.JOINT) {
      return true;
    }

    return false;
  }

  get isClientIndividual {
    // In case [panUsageType] not populated from backend
    if (panUsageType.isNullOrEmpty) {
      return true;
    }

    if (panUsageType == PanUsageType.INDIVIDUAL ||
        panUsageType == PanUsageType.INDIVIDUALNRE ||
        panUsageType == PanUsageType.INDIVIDUALNRO) {
      return true;
    }

    return false;
  }

  String? id;
  String? taxyID;
  String? email;
  AgentModel? agent;
  String? mfEmail;
  String? phoneNumber;
  String? name;
  DateTime? dob;
  String? gender;
  String? accountId;
  bool? hasMandate;
  String? firstName;
  String? lastName;
  dynamic firstTransactionAt;
  String? source;
  double? wealthyInvestedValue;
  double? wealthyIrr;
  double? wealthyCurrentValue;
  double? trakMfIrr;
  double? totalFamilyCurrentValue;
  double? totalSelfCurrentValue;
  dynamic frequentSeenLocation;
  DateTime? lastSeenAt;
  dynamic investorActivatedAt;
  dynamic privilegeActivatedAt;
  DateTime? currentAgentAssignedAt;
  String? sourceType;
  double? investmentCurrentValue;
  double? loanCurrentValue;
  double? insuranceCurrentValue;
  double? unlistedStocksCurrentValue;
  double? currentMonthPipelinedRevenue;
  double? agentTotalRevenue;
  int? totalNoOfInsurance;
  bool isSourceContacts;
  bool? phoneVerified;
  bool? emailVerified;
  String? relation;
  String? crn;
  String? panNumber;
  String? panUsageType;
  String? panUsageSubtype;

  // ticob opportunity
  double? trakFamilyMfCurrentValue;
  double? trakCobOpportunityValue;
  int? totalMfPansTracked;

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: WealthyCast.toStr(json["id"]),
        taxyID: WealthyCast.toStr(json["taxyId"] ?? json["taxy_id"]),
        email: WealthyCast.toStr(json["email"]) ?? json["client_email"] ?? "",
        agent:
            json["agent"] != null ? AgentModel.fromJson(json["agent"]) : null,
        mfEmail: WealthyCast.toStr(json["mfEmail"]) ?? "",
        phoneNumber: WealthyCast.toStr(json["phoneNumber"] ??
                json["phone_number"] ??
                json["client_phone"]) ??
            '',
        name: WealthyCast.toStr(json["name"] ?? json["client_name"]) ?? "",
        dob: WealthyCast.toDate(json["dob"]),
        gender: WealthyCast.toStr(json["gender"]),
        accountId: WealthyCast.toStr(json["accountId"]),
        hasMandate: WealthyCast.toBool(json["hasMandate"]),
        firstName: WealthyCast.toStr(json["firstName"]),
        lastName: WealthyCast.toStr(json["lastName"]),
        firstTransactionAt: json["firstTransactionAt"],
        source: WealthyCast.toStr(json["source"]),
        wealthyInvestedValue:
            WealthyCast.toDouble(json["wealthyInvestedValue"]),
        wealthyIrr: WealthyCast.toDouble(json["wealthyIrr"]),
        wealthyCurrentValue: WealthyCast.toDouble(json["wealthyCurrentValue"]),
        trakMfIrr: WealthyCast.toDouble(json["trakMfIrr"]),
        totalFamilyCurrentValue:
            WealthyCast.toDouble(json["totalFamilyCurrentValue"]),
        totalSelfCurrentValue:
            WealthyCast.toDouble(json["totalSelfCurrentValue"]),
        frequentSeenLocation: json["frequentSeenLocation"],
        lastSeenAt: WealthyCast.toDate(json["lastSeenAt"]),
        investorActivatedAt: json["investorActivatedAt"],
        privilegeActivatedAt: json["privilegeActivatedAt"],
        currentAgentAssignedAt:
            WealthyCast.toDate(json["currentAgentAssignedAt"]),
        sourceType: WealthyCast.toStr(json["sourceType"]),
        investmentCurrentValue:
            WealthyCast.toDouble(json["investmentCurrentValue"]),
        loanCurrentValue: WealthyCast.toDouble(json["loanCurrentValue"]),
        insuranceCurrentValue:
            WealthyCast.toDouble(json["insuranceCurrentValue"]),
        unlistedStocksCurrentValue:
            WealthyCast.toDouble(json["unlistedStocksCurrentValue"]),
        currentMonthPipelinedRevenue:
            WealthyCast.toDouble(json["currentMonthPipelinedRevenue"]),
        agentTotalRevenue: WealthyCast.toDouble(json["agentTotalRevenue"]),
        totalNoOfInsurance: WealthyCast.toInt(json["totalNoOfInsurance"]),
        emailVerified: WealthyCast.toBool(json["emailVerified"]),
        phoneVerified: WealthyCast.toBool(json["phoneVerified"]),
        crn: WealthyCast.toStr(json["crn"]),
        panNumber: WealthyCast.toStr(json['panNumber']),
        panUsageType: WealthyCast.toStr(json['panUsageType']) ??
            WealthyCast.toStr(json['pan_usage_type']),
        panUsageSubtype: WealthyCast.toStr(json['panUsageSubtype']) ??
            WealthyCast.toStr(json['pan_usage_sub_type']),
        trakCobOpportunityValue:
            WealthyCast.toDouble(json['trakCobOpportunityValue']),
        totalMfPansTracked: WealthyCast.toInt(json['totalMfPansTracked']),
        trakFamilyMfCurrentValue:
            WealthyCast.toDouble(json['trakFamilyMfCurrentValue']),
      );

  Client.clone(Client x)
      : this(
          id: x.id,
          taxyID: x.taxyID,
          email: x.email,
          agent: x.agent,
          mfEmail: x.mfEmail,
          phoneNumber: x.phoneNumber,
          name: x.name,
          dob: x.dob,
          gender: x.gender,
          accountId: x.accountId,
          hasMandate: x.hasMandate,
          firstName: x.firstName,
          lastName: x.lastName,
          firstTransactionAt: x.firstTransactionAt,
          source: x.source,
          wealthyInvestedValue: x.wealthyInvestedValue,
          wealthyIrr: x.wealthyIrr,
          wealthyCurrentValue: x.wealthyCurrentValue,
          trakMfIrr: x.trakMfIrr,
          totalFamilyCurrentValue: x.totalFamilyCurrentValue,
          totalSelfCurrentValue: x.totalSelfCurrentValue,
          frequentSeenLocation: x.frequentSeenLocation,
          lastSeenAt: x.lastSeenAt,
          investorActivatedAt: x.investorActivatedAt,
          privilegeActivatedAt: x.privilegeActivatedAt,
          currentAgentAssignedAt: x.currentAgentAssignedAt,
          sourceType: x.sourceType,
          investmentCurrentValue: x.investmentCurrentValue,
          loanCurrentValue: x.loanCurrentValue,
          insuranceCurrentValue: x.insuranceCurrentValue,
          agentTotalRevenue: x.agentTotalRevenue,
          currentMonthPipelinedRevenue: x.currentMonthPipelinedRevenue,
          totalNoOfInsurance: x.totalNoOfInsurance,
          unlistedStocksCurrentValue: x.unlistedStocksCurrentValue,
          isSourceContacts: x.isSourceContacts,
          emailVerified: x.emailVerified,
          phoneVerified: x.phoneVerified,
          relation: x.relation,
          crn: x.crn,
          panNumber: x.panNumber,
          panUsageType: x.panUsageType,
          totalMfPansTracked: x.totalMfPansTracked,
          trakCobOpportunityValue: x.trakCobOpportunityValue,
          trakFamilyMfCurrentValue: x.trakFamilyMfCurrentValue,
          panUsageSubtype: x.panUsageSubtype,
        );

  NewClientModel toNewClientModel() {
    return NewClientModel.fromJson({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'crn': crn,
      'pan_number': panNumber,
      'no_of_insurance': totalNoOfInsurance,
      'last_seen_at_date': lastSeenAt?.toIso8601String(),
      'user_id': taxyID,
      'customer_id': id,
      'agent_id': agent?.id != null ? int.tryParse(agent!.id!) : null,
      'agent_external_id': agent?.externalId,
      'agent_name': agent?.name,
      'agent_email': agent?.email,
      'agent_phone_number': agent?.phoneNumber,
      'total_current_value': totalSelfCurrentValue,
      'pan_usage_type': panUsageType,
      'pan_usage_subtype': panUsageSubtype,
      'trak_cob_opportunity_value': trakCobOpportunityValue,
      'trak_mf_current_value': trakFamilyMfCurrentValue,
    });
  }
}
