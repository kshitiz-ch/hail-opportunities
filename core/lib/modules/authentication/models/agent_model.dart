import 'package:core/config/util_constants.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';

class AgentModel {
  AgentModel(
      {this.createdAt,
      this.name,
      this.email,
      this.phoneNumber,
      this.id,
      this.externalId,
      this.referralUrl,
      this.aadhaarLinked,
      this.manager,
      this.kycStatus,
      this.firstRewardAt,
      this.segment,
      this.panNumber,
      this.displayName,
      this.airtableUrl,
      this.code,
      this.dateOfActivation,
      this.imageUrl,
      this.agentType,
      this.salesPlanType,
      this.pst,
      this.emailVerifiedAt,
      this.phoneNumberVerifiedAt,
      this.gst,
      this.dob,
      this.bankDetail,
      this.isFirstTransactionCompleted,
      this.bankStatus,
      this.dematTncConsentAt,
      this.hasAcceptedActiveTnc,
      this.brokingApId});

  DateTime? createdAt;
  String? name;
  String? email;
  String? externalId;
  String? phoneNumber;
  String? panNumber;
  String? displayName;
  bool? aadhaarLinked;
  String? id;
  String? referralUrl;
  Manager? manager;
  Manager? pst;
  int? kycStatus;
  DateTime? firstRewardAt;
  DateTime? secondRewardAt;
  int? segment;
  String? code;
  String? airtableUrl;
  String? dateOfActivation;
  String? imageUrl;
  String? agentType;
  int? salesPlanType;
  DateTime? emailVerifiedAt;
  DateTime? phoneNumberVerifiedAt;
  GstModel? gst;
  DateTime? dob;
  AgentBankModel? bankDetail;
  bool? isFirstTransactionCompleted;
  String? bankStatus;
  DateTime? dematTncConsentAt;
  bool? hasAcceptedActiveTnc;
  String? brokingApId;

  bool get isAgentNew {
    if (createdAt == null) {
      return false;
    } else {
      return createdAt!.isAfter(DateTime(2023, 2, 1));
    }
  }

  // Temporary
  bool get showLastSevenDaysBanner {
    if (createdAt == null) {
      return false;
    } else {
      try {
        DateTime now = new DateTime.now();
        Duration difference = now.difference(createdAt!);
        int signedUpSince = difference.inDays;

        if (signedUpSince > 24 &&
            signedUpSince <= 31 &&
            firstRewardAt == null &&
            secondRewardAt == null) {
          return true;
        } else {
          return false;
        }
      } catch (error) {
        return false;
      }
    }
  }

  get isAgentFixed => agentType != null && agentType!.toLowerCase() == "fixed";
  get isActivated => dateOfActivation != null;
  get isImageUrlPresent => imageUrl != null;
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isPhoneVerified => phoneNumberVerifiedAt != null;

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      createdAt: WealthyCast.toDate(json["createdAt"]),
      name: WealthyCast.toStr(json["name"]),
      email: WealthyCast.toStr(json["email"]),
      phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
      id: WealthyCast.toStr(json["id"]),
      externalId: WealthyCast.toStr(json["externalId"]),
      segment: WealthyCast.toInt(json["segment"]),
      kycStatus: WealthyCast.toInt(json["kycStatus"]),
      firstRewardAt: WealthyCast.toDate(json["firstRewardAt"]),
      displayName: WealthyCast.toStr(json["displayName"]),
      agentType: WealthyCast.toStr(json["agentType"]),
      salesPlanType: WealthyCast.toInt(json["salesPlanType"]),
      aadhaarLinked: WealthyCast.toBool(json["aadhaarLinked"]),
      panNumber: WealthyCast.toStr(json["panNumber"]),
      code: WealthyCast.toStr(json["code"]),
      referralUrl: json["agentReferralData"] == null
          ? null
          : transformReferralUrl(
              WealthyCast.toStr(json["agentReferralData"]["referralUrl"])),
      manager:
          json["manager"] == null ? null : Manager.fromJson(json["manager"]),
      pst: json["pst"] == null ? null : Manager.fromJson(json["pst"]),
      airtableUrl: WealthyCast.toStr(json["airtable_url"]),
      dateOfActivation: WealthyCast.toStr(json["dateOfActivation"]),
      emailVerifiedAt: WealthyCast.toDate(json["emailVerifiedAt"]),
      phoneNumberVerifiedAt: WealthyCast.toDate(json["phoneNumberVerifiedAt"]),
      imageUrl: WealthyCast.toStr(json["imageUrl"]),
      gst: json["gst"] != null ? GstModel.fromJson(json["gst"]) : null,
      dob: json["dob"] != null ? WealthyCast.toDate(json["dob"]) : null,
      bankDetail: json['bankDetails'] != null
          ? AgentBankModel.fromJson(json['bankDetails'])
          : null,
      isFirstTransactionCompleted:
          WealthyCast.toBool(json['isFirstTransactionCompleted']),
      bankStatus: WealthyCast.toStr(json["bankStatus"]),
      dematTncConsentAt: WealthyCast.toDate(json['dematTncConsentAt']),
      hasAcceptedActiveTnc: WealthyCast.toBool(json['hasAcceptedActiveTnc']),
      brokingApId: WealthyCast.toStr(json['brokingApId']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "manager": manager == null ? null : manager!.toJson(),
        "code": code == null ? null : code,
        "email": email == null ? null : email,
        "airtable_url": airtableUrl == null ? null : airtableUrl,
      };
}

class GstModel {
  GstModel({
    this.corporateName,
    this.gstin,
    this.verifiedAt,
  });

  String? gstin;
  String? corporateName;
  DateTime? verifiedAt;

  factory GstModel.fromJson(Map<String, dynamic> json) => GstModel(
        corporateName: WealthyCast.toStr(json["corporateName"]),
        gstin: WealthyCast.toStr(json["gstin"]),
        verifiedAt: WealthyCast.toDate(json["verifiedAt"]),
      );
}

class AgentBankModel {
  AgentBankModel({
    this.bankAccountNo,
    this.bankIfscCode,
    this.bankName,
    this.nameAsPerBank,
  });

  String? bankAccountNo;
  String? bankIfscCode;
  String? bankName;
  String? nameAsPerBank;

  factory AgentBankModel.fromJson(Map<String, dynamic> json) => AgentBankModel(
        bankAccountNo: WealthyCast.toStr(json["bankAccountNo"]),
        bankIfscCode: WealthyCast.toStr(json["bankIfscCode"]),
        bankName: WealthyCast.toStr(json["bankName"]),
        nameAsPerBank: WealthyCast.toStr(json["nameAsPerBank"]),
      );
}
