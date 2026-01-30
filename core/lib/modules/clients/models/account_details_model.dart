import 'package:core/modules/common/resources/wealthy_cast.dart';

class AccountDetailsModel {
  AccountDetailsModel({
    this.id,
    this.accounts,
    this.bankAccounts,
    this.mandates,
    this.kycDetails,
    this.users,
  });

  String? id;
  List<Account>? accounts;
  List<BankAccountModel>? bankAccounts;
  List<dynamic>? mandates;
  List<dynamic>? kycDetails;
  List<User>? users;

  factory AccountDetailsModel.fromJson(Map<String, dynamic> json) =>
      AccountDetailsModel(
        id: WealthyCast.toStr(json["id"]),
        accounts: List<Account>.from(WealthyCast.toList(json["accounts"])
            .map((x) => Account.fromJson(x))),
        users: List<User>.from(
            WealthyCast.toList(json["users"]).map((x) => User.fromJson(x))),
        bankAccounts: List<BankAccountModel>.from(
            WealthyCast.toList(json["bankAccounts"])
                .map((x) => BankAccountModel.fromJson(x))),
        mandates: List<dynamic>.from(
            WealthyCast.toList(json["mandates"]).map((x) => x)),
        kycDetails: List<dynamic>.from(
            WealthyCast.toList(json["kycDetails"]).map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "accounts": accounts == null
            ? null
            : List<dynamic>.from(accounts!.map((x) => x.toJson())),
        "bankAccounts": bankAccounts == null
            ? null
            : List<dynamic>.from(bankAccounts!.map((x) => x.toJson())),
        "mandates": mandates == null
            ? null
            : List<dynamic>.from(mandates!.map((x) => x)),
        "kycDetails": kycDetails == null
            ? null
            : List<dynamic>.from(kycDetails!.map((x) => x)),
      };
}

class User {
  User({
    this.id,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.isEmailVerified,
    this.phoneVerifiedAt,
    this.isPhoneVerified,
    this.lastName,
    this.firstName,
    this.crn,
  });

  String? id;
  String? email;
  String? fullName;
  String? phoneNumber;
  bool? isEmailVerified;
  String? phoneVerifiedAt;
  bool? isPhoneVerified;
  String? lastName;
  String? firstName;
  String? crn;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: WealthyCast.toStr(json["id"]),
        fullName: WealthyCast.toStr(json["fullName"]),
        firstName: WealthyCast.toStr(json["firstName"]),
        lastName: WealthyCast.toStr(json["fullNamelastName"]),
        isEmailVerified: WealthyCast.toBool(json["isEmailVerified"]),
        phoneVerifiedAt: WealthyCast.toStr(json["phoneVerifiedAt"]),
        isPhoneVerified: json["phoneVerifiedAt"] != null,
        email: WealthyCast.toStr(json["email"]),
        phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
        crn: WealthyCast.toStr(json["crn"]),
      );
}

class Account {
  Account(
      {this.id,
      this.name,
      this.panNumber,
      this.kycStatus,
      this.investorActivatedAt,
      this.dob,
      this.email,
      this.phoneNumber,
      this.maritalStatus,
      this.gender,
      this.isNri,
      this.nominee,
      this.typename,
      this.transactionActive,
      this.isEmailVerified});

  String? id;
  String? name;
  String? panNumber;
  int? kycStatus;
  dynamic investorActivatedAt;
  DateTime? dob;
  String? email;
  String? phoneNumber;
  String? maritalStatus;
  String? gender;
  bool? isNri;
  bool? transactionActive;
  NomineeDetails? nominee;
  String? typename;
  bool? isEmailVerified;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: WealthyCast.toStr(json["id"]),
        name: WealthyCast.toStr(json["name"]),
        panNumber: WealthyCast.toStr(json["panNumber"]),
        kycStatus: WealthyCast.toInt(json["kycStatus"]),
        investorActivatedAt: json["investorActivatedAt"],
        dob: WealthyCast.toDate(json["dob"]),
        email: WealthyCast.toStr(json["email"]),
        phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
        maritalStatus: WealthyCast.toStr(json["maritalStatus"]),
        gender: WealthyCast.toStr(json["gender"]),
        isNri: WealthyCast.toBool(json["isNri"]),
        isEmailVerified: WealthyCast.toBool(json["isEmailVerified"]),
        transactionActive: WealthyCast.toBool(json["transactionActive"]),
        nominee: json["nominee"] == null
            ? null
            : NomineeDetails.fromJson(json["nominee"]),
        typename: WealthyCast.toStr(json["__typename"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "panNumber": panNumber,
        "kycStatus": kycStatus,
        "investorActivatedAt": investorActivatedAt,
        "dob": dob == null ? null : dob!.toIso8601String(),
        "email": email,
        "phoneNumber": phoneNumber,
        "maritalStatus": maritalStatus,
        "gender": gender,
        "isNri": isNri,
        "isEmailVerified": isEmailVerified,
        "nominee": nominee,
        "__typename": typename,
      };
}

class NomineeDetails {
  NomineeDetails({
    this.id,
    this.name,
    this.relationship,
    this.guardianName,
    this.dob,
    this.isAdult,
    this.deleted,
  });

  String? id;
  String? name;
  int? relationship;
  String? guardianName;
  DateTime? dob;
  bool? isAdult;
  bool? deleted;

  factory NomineeDetails.fromJson(Map<String, dynamic> json) => NomineeDetails(
        id: WealthyCast.toStr(json["id"]),
        name: WealthyCast.toStr(json["name"]),
        relationship: WealthyCast.toInt(json["relationship"]),
        guardianName: WealthyCast.toStr(json["guardianName"]),
        dob: WealthyCast.toDate(json["dob"]),
        isAdult: WealthyCast.toBool(json["isAdult"]),
        deleted: WealthyCast.toBool(json["deleted"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "relationship": relationship,
        "guardianName": guardianName,
        "dob": dob == null ? null : dob!.toIso8601String(),
        "isAdult": isAdult,
        "deleted": deleted,
      };
}

class BankAccountModel {
  BankAccountModel(
      {this.id,
      this.externalId,
      this.userId,
      this.bank,
      this.ifsc,
      this.micr,
      this.branch,
      this.number,
      this.isVerified,
      this.bankVerifiedStatus,
      this.bankVerifiedName,
      this.address,
      this.typename,
      this.accType,
      this.accountType});

  String? id;
  String? externalId;
  String? userId;
  String? bank;
  String? ifsc;
  int? micr;
  String? branch;
  String? number;
  bool? isVerified;
  int? bankVerifiedStatus;
  dynamic bankVerifiedName;
  String? address;
  String? typename;
  String? accType;
  String? accountType;

  bool _isMandateCompleted = false;

  set isMandateCompleted(bool? value) {
    this._isMandateCompleted = value ?? false;
  }

  bool get isMandateCompleted => this._isMandateCompleted;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      BankAccountModel(
        id: WealthyCast.toStr(json["id"]),
        externalId: WealthyCast.toStr(json["externalId"]),
        userId: WealthyCast.toStr(json["userId"]),
        bank: WealthyCast.toStr(json["bank"]),
        ifsc: WealthyCast.toStr(json["ifsc"]),
        micr: WealthyCast.toInt(json["micr"]),
        branch: WealthyCast.toStr(json["branch"]),
        number: WealthyCast.toStr(json["number"]),
        isVerified: WealthyCast.toBool(json["isVerified"]),
        bankVerifiedStatus: WealthyCast.toInt(json["bankVerifiedStatus"]),
        bankVerifiedName: json["bankVerifiedName"],
        address: WealthyCast.toStr(json["address"]),
        typename: WealthyCast.toStr(json["__typename"]),
        accType: WealthyCast.toStr(json["accType"]),
        accountType: WealthyCast.toStr(json["accountType"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bank": bank,
        "ifsc": ifsc,
        "micr": micr,
        "branch": branch,
        "number": number,
        "isVerified": isVerified,
        "bankVerifiedStatus": bankVerifiedStatus,
        "bankVerifiedName": bankVerifiedName,
        "address": address,
        "__typename": typename,
      };
}
