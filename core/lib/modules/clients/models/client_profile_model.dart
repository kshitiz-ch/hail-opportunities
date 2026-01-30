import 'package:core/config/string_constants.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientAccountModel {
  ClientAccountModel({this.clientMfProfile, this.bankAccounts});

  ClientMfProfileModel? clientMfProfile;
  List<BankAccountModel>? bankAccounts;

  ClientAccountModel.fromJson(Map<String, dynamic> json) {
    clientMfProfile = json["wealthyMfProfile"] != null
        ? ClientMfProfileModel.fromJson(json["wealthyMfProfile"])
        : null;
    if (json["userBankAccounts"] != null &&
        json["userBankAccounts"].isNotEmpty) {
      List<BankAccountModel> userBankAccounts = [];
      json["userBankAccounts"].forEach((e) {
        userBankAccounts.add(BankAccountModel.fromJson(e));
      });

      bankAccounts = List.from(userBankAccounts);
    }
  }
}

class ClientMfProfileModel {
  ClientMfProfileModel(
      {this.id,
      this.externalId,
      this.userId,
      this.name,
      this.email,
      this.emailRelation,
      this.emailVerifiedAt,
      this.phoneNumber,
      this.phoneRelation,
      this.motherName,
      this.fatherName,
      this.phoneVerifiedAt,
      this.panNumber,
      this.panUsageType,
      this.panUsageSubtype,
      this.dob,
      this.activatedAt,
      this.kycStatus,
      this.transactionActiveAt,
      this.accountId,
      this.defaultBankAccountId,
      this.defaultPerAddressId,
      this.defaultCorrAddressId,
      this.maritalStatus,
      this.gender,
      this.citizenshipCountryCode,
      this.panUniquenessKey,
      this.pan2,
      this.pan3,
      this.guardianPan,
      this.guardianName,
      this.jointName2,
      this.jointName3});

  String? id;
  String? externalId;
  String? userId;
  String? name;
  String? fatherName;
  String? motherName;
  String? email;
  String? emailRelation;
  DateTime? emailVerifiedAt;
  String? phoneNumber;
  String? phoneRelation;
  DateTime? phoneVerifiedAt;
  String? panNumber;
  String? panUsageType;
  String? panUsageSubtype;
  DateTime? dob;
  DateTime? activatedAt;
  int? kycStatus;
  DateTime? transactionActiveAt;
  String? accountId;
  String? defaultBankAccountId;
  String? defaultPerAddressId;
  String? defaultCorrAddressId;
  String? maritalStatus;
  String? gender;
  String? citizenshipCountryCode;
  String? panUniquenessKey;
  String? pan2;
  String? pan3;
  String? guardianPan;
  String? guardianName;
  String? jointName2;
  String? jointName3;

  bool get isEmailVerified => this.emailVerifiedAt != null;
  bool get isPhoneVerified => this.phoneVerifiedAt != null;
  bool get isKycSubmittedOrApproved =>
      this.kycStatus == ClientKycStatus.SUBMITTEDBYCUSTOMER ||
      this.kycStatus == ClientKycStatus.APPROVED;

  ClientMfProfileModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    externalId = WealthyCast.toStr(json["externalId"]);
    userId = WealthyCast.toStr(json["userId"]);
    name = WealthyCast.toStr(json["name"]);
    fatherName = WealthyCast.toStr(json["fatherName"]);
    motherName = WealthyCast.toStr(json["motherName"]);
    email = WealthyCast.toStr(json["email"]);
    emailRelation = WealthyCast.toStr(json["emailRelation"]);
    emailVerifiedAt = WealthyCast.toDate(json["emailVerifiedAt"]);
    phoneNumber = WealthyCast.toStr(json["phoneNumber"]);
    phoneRelation = WealthyCast.toStr(json["phoneRelation"]);
    phoneVerifiedAt = WealthyCast.toDate(json["phoneVerifiedAt"]);
    panNumber = WealthyCast.toStr(json["panNumber"]);
    panUsageType = WealthyCast.toStr(json["panUsageType"]);
    panUsageSubtype = WealthyCast.toStr(json["panUsageSubtype"]);
    dob = WealthyCast.toDate(json["dob"]);
    activatedAt = WealthyCast.toDate(json["activatedAt"]);
    kycStatus = WealthyCast.toInt(json["kycStatus"]);
    transactionActiveAt = WealthyCast.toDate(json["transactionActiveAt"]);
    accountId = WealthyCast.toStr(json["accountId"]);
    defaultBankAccountId = WealthyCast.toStr(json["defaultBankAccountId"]);
    defaultPerAddressId = WealthyCast.toStr(json["defaultPerAddressId"]);
    defaultCorrAddressId = WealthyCast.toStr(json["defaultCorrAddressId"]);
    maritalStatus = WealthyCast.toStr(json["maritalStatus"]);
    gender = WealthyCast.toStr(json["gender"]);
    citizenshipCountryCode = WealthyCast.toStr(json["citizenshipCountryCode"]);
    panUniquenessKey = WealthyCast.toStr(json["panUniquenessKey"]);
    pan2 = WealthyCast.toStr(json["pan2"]);
    pan3 = WealthyCast.toStr(json["pan3"]);
    guardianPan = WealthyCast.toStr(json["guardianPan"]);
    guardianName = WealthyCast.toStr(json["guardianName"]);
    jointName2 = WealthyCast.toStr(json["jointName2"]);
    jointName3 = WealthyCast.toStr(json["jointName3"]);
  }
}

class UserDetailsPrefillModel {
  String? panNumber;
  String? email;
  String? name;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  DateTime? dob;
  String? maritalStatus;
  String? gender;
  List<FamilyPrefillModel>? families;
  // OwnerDetaiilsModel? ownderDetails;

  UserDetailsPrefillModel.fromJson(Map<String, dynamic> json) {
    panNumber = WealthyCast.toStr(json["panNumber"]);
    email = WealthyCast.toStr(json["email"]);
    name = WealthyCast.toStr(json["name"]);
    firstName = WealthyCast.toStr(json["firstName"]);
    lastName = WealthyCast.toStr(json["lastName"]);
    phoneNumber = WealthyCast.toStr(json["phoneNumber"]);
    isEmailVerified = WealthyCast.toBool(json["isEmailVerified"]);
    isPhoneVerified = WealthyCast.toBool(json["isPhoneVerified"]);
    dob = WealthyCast.toDate(json["dob"]);
    maritalStatus = WealthyCast.toStr(json["maritalStatus"]);
    gender = WealthyCast.toStr(json["gender"]);
    families = List<FamilyPrefillModel>.from(
      WealthyCast.toList(json["families"]).map(
        (x) {
          return FamilyPrefillModel.fromJson(x);
        },
      ),
    );
  }
}

class FamilyPrefillModel {
  OwnerDetaiilsModel? ownerDetails;

  FamilyPrefillModel.fromJson(Map<String, dynamic> json) {
    ownerDetails = json["ownerDetails"] != null
        ? OwnerDetaiilsModel.fromJson(json["ownerDetails"])
        : null;
  }
}

class OwnerDetaiilsModel {
  String? ownerUserId;
  String? email;
  String? phoneNumber;
  bool? isEmailVerified;
  bool? isPhoneVerified;

  OwnerDetaiilsModel.fromJson(Map<String, dynamic> json) {
    email = WealthyCast.toStr(json["email"]);
    ownerUserId = WealthyCast.toStr(json["ownerUserId"]);
    phoneNumber = WealthyCast.toStr(json["phoneNumber"]);
    isEmailVerified = WealthyCast.toBool(json["isEmailVerified"]);
    isPhoneVerified = WealthyCast.toBool(json["isPhoneVerified"]);
  }
}
