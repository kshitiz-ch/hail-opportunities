import 'package:core/modules/common/resources/wealthy_cast.dart';

class FamilyMembersModel {
  FamilyMembersModel({
    this.familyMembers,
  });

  List<FamilyMemberModel>? familyMembers;

  factory FamilyMembersModel.fromJson(Map<String, dynamic> json) =>
      FamilyMembersModel(
        familyMembers: WealthyCast.toList(json["familyMembers"])
            .map<FamilyMemberModel>((x) => FamilyMemberModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "familyMembers": familyMembers == null
            ? null
            : List<dynamic>.from(familyMembers!.map((x) => x.toJson())),
      };
}

class FamilyMemberModel {
  FamilyMemberModel({
    this.memberName,
    this.relation,
    this.id,
    this.userId,
    this.userEmail,
    this.memberEmail,
    this.memberUserId,
  });

  String? memberName;
  String? relation;
  String? id;
  String? userId;
  String? userEmail;
  String? memberEmail;
  String? memberUserId;

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      FamilyMemberModel(
        memberName: WealthyCast.toStr(json["memberName"]),
        relation: WealthyCast.toStr(json["relation"]),
        id: WealthyCast.toStr(json["id"]),
        userId: WealthyCast.toStr(json["userId"]),
        userEmail: WealthyCast.toStr(json["userEmail"]),
        memberEmail: WealthyCast.toStr(json["memberEmail"]),
        memberUserId: WealthyCast.toStr(json["memberUserId"]),
      );

  Map<String, dynamic> toJson() => {
        "memberName": memberName,
        "relation": relation,
        "id": id,
        "userId": userId,
        "userEmail": userEmail,
        "memberEmail": memberEmail,
      };
}
