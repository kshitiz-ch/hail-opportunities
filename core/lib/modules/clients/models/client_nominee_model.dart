import 'package:core/modules/clients/models/client_address_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientNomineeModel {
  ClientNomineeModel({
    this.externalId,
    this.userId,
    this.name,
    this.relationship,
    this.panNumber,
    this.nameAsPerPan,
    this.guardianName,
    this.guardianDob,
    this.dob,
    this.source,
    this.percentage,
    this.aadhaarNumber,
    this.phoneNumber,
    this.email,
    this.nomineeIsNri,
    this.nomineeIdType,
    this.passportNumber,
    this.includeNomineeInSoa,
    this.guardianIdType,
    this.guardianIdValue,
    this.nomineeRelationWithGuardian,
    this.address,
  });

  String? externalId;
  String? userId;
  String? name;
  String? relationship;
  String? panNumber;
  String? nameAsPerPan;
  String? guardianName;
  DateTime? guardianDob;
  DateTime? dob;
  String? source;
  int? percentage;

  String? aadhaarNumber;
  String? phoneNumber;
  String? email;
  bool? nomineeIsNri;
  String? nomineeIdType;
  String? passportNumber;
  bool? includeNomineeInSoa;
  String? guardianIdType;
  String? guardianIdValue;
  String? nomineeRelationWithGuardian;
  ClientAddressModel? address;

  factory ClientNomineeModel.fromJson(Map<String, dynamic> json) {
    return ClientNomineeModel(
      externalId: WealthyCast.toStr(json["externalId"]),
      userId: WealthyCast.toStr(json["userId"]),
      name: WealthyCast.toStr(json["name"]),
      relationship: WealthyCast.toStr(json["relationship"]),
      panNumber: WealthyCast.toStr(json["panNumber"]),
      nameAsPerPan: WealthyCast.toStr(json["nameAsPerPan"]),
      guardianName: WealthyCast.toStr(json["guardianName"]),
      guardianDob: WealthyCast.toDate(json["guardianDob"]),
      dob: WealthyCast.toDate(json["dob"]),
      source: WealthyCast.toStr(json["source"]),
      aadhaarNumber: WealthyCast.toStr(json["aadhaarNumber"]),
      phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
      email: WealthyCast.toStr(json["email"]),
      nomineeIsNri: WealthyCast.toBool(json["nomineeIsNri"]),
      nomineeIdType: WealthyCast.toStr(json["nomineeIdType"]),
      passportNumber: WealthyCast.toStr(json["passportNumber"]),
      includeNomineeInSoa: WealthyCast.toBool(json["includeNomineeInSoa"]),
      guardianIdType: WealthyCast.toStr(json["guardianIdType"]),
      guardianIdValue: WealthyCast.toStr(json["guardianIdValue"]),
      nomineeRelationWithGuardian:
          WealthyCast.toStr(json["nomineeRelationWithGuardian"]),
      address: json["address"] != null
          ? ClientAddressModel.fromJson(json["address"])
          : null,
    );
  }
}
