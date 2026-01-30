import 'package:core/modules/common/resources/wealthy_cast.dart';

class FamilyModel {
  String? id;
  String? memberCRN;
  // equivalent to taxy id
  String? memberUserID;
  String? relationship;
  String? memberName;
  String? memberPhoneNumber;
  String? emailAddress;

  FamilyModel(
      {this.id,
      this.memberCRN,
      this.memberUserID,
      this.relationship,
      this.memberPhoneNumber,
      this.memberName,
      this.emailAddress});

  FamilyModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    memberCRN = WealthyCast.toStr(json['crn']);
    memberUserID = WealthyCast.toStr(json['memberUserId']);
    relationship = WealthyCast.toStr(json['relation']);
    memberPhoneNumber = WealthyCast.toStr(json['memberPhoneNumber']);
    emailAddress = WealthyCast.toStr(json['memberEmail']);
    memberName = WealthyCast.toStr(json['memberName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['crn'] = this.memberCRN;
    data['memberUserId'] = this.memberUserID;
    data['relation'] = this.relationship;
    data['memberPhoneNumber'] = this.memberPhoneNumber;
    data['memberEmail'] = this.emailAddress;
    data['memberName'] = this.memberName;

    return data;
  }
}

class FamilyInfoModel {
  String? userId;
  String? name;

  FamilyInfoModel({this.userId, this.name});

  FamilyInfoModel.fromJson(Map<String, dynamic> json) {
    userId = WealthyCast.toStr(json["UserID"]);
    name = WealthyCast.toStr(json["Name"]);
  }
}

class FamilyResponse {
  String? id;
  String? familyMemberID;
  String? otp;
  String? message;

  FamilyResponse({
    this.id,
    this.familyMemberID,
    this.otp,
    this.message,
  });

  FamilyResponse.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['ID']);
    familyMemberID = WealthyCast.toStr(json['FamilyMemberID']);
    otp = WealthyCast.toStr(json['Otp']);
    message = WealthyCast.toStr(json['Message']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.id;
    data['FamilyMemberID'] = this.familyMemberID;
    data['Otp'] = this.otp;
    data['Message'] = this.message;

    return data;
  }
}
