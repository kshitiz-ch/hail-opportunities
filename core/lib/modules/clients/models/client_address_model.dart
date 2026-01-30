import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientAddressModel {
  String? title;
  String? line1;
  String? line2;
  String? line3;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? address;
  String? id;
  String? externalID;

  ClientAddressModel({
    this.title,
    this.line1,
    this.line2,
    this.line3,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.address,
    this.id,
    this.externalID,
  });

  ClientAddressModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    externalID = WealthyCast.toStr(json['externalId']);
    title = WealthyCast.toStr(json['title']);
    line1 = WealthyCast.toStr(json['line1']);
    line2 = WealthyCast.toStr(json['line2']);
    line3 = WealthyCast.toStr(json['line3']);
    city = WealthyCast.toStr(json['city']);
    state = WealthyCast.toStr(json['state']);
    country = WealthyCast.toStr(json['country']);
    pincode = WealthyCast.toStr(json['pincode']);
    address = WealthyCast.toStr(json['address']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['externalId'] = this.externalID;
    data['title'] = this.title;
    data['line1'] = this.line1;
    data['line2'] = this.line2;
    data['line3'] = this.line3;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['pincode'] = this.pincode;
    data['address'] = this.address;
    return data;
  }
}
