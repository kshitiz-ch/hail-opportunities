import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerNomineeModel {
  String? id;
  String? name;
  DateTime? dob;
  String? address;
  String? relationship;
  String? guardianName;
  String? guardianAddress;
  int? percentage;

  PartnerNomineeModel({
    this.id,
    this.name,
    this.dob,
    this.address,
    this.relationship,
    this.guardianName,
    this.guardianAddress,
    this.percentage,
  });

  PartnerNomineeModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    name = WealthyCast.toStr(json['name']);
    dob = WealthyCast.toDate(json['dob']);
    address = WealthyCast.toStr(json['address']);
    relationship = WealthyCast.toStr(json['relationship']);
    guardianName = WealthyCast.toStr(json['guardianName']);
    guardianAddress = WealthyCast.toStr(json['guardianAddress']);
    percentage = WealthyCast.toInt(json['percentage']);
  }
}
