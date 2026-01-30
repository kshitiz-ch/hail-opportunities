import 'package:core/modules/common/resources/wealthy_cast.dart';

class EmpanelmentAddressModel {
  String? line1;
  String? line2;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? externalId;

  EmpanelmentAddressModel({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.externalId,
  });

  EmpanelmentAddressModel.fromJson(Map<String, dynamic> json) {
    line1 = WealthyCast.toStr(json['line1']);
    line2 = WealthyCast.toStr(json['line2']);
    city = WealthyCast.toStr(json['city']);
    state = WealthyCast.toStr(json['state']);
    postalCode = WealthyCast.toStr(json['postalCode']);
    country = WealthyCast.toStr(json['country']);
    externalId = WealthyCast.toStr(json['externalId']);
  }
}
