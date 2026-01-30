import 'package:core/modules/common/resources/wealthy_cast.dart';

class MfIndexModel {
  String? name;
  String? token;
  String? exchangeName;

  String get id {
    return "${exchangeName}-${token}".toUpperCase();
  }

  MfIndexModel({this.name, this.token, this.exchangeName});

  MfIndexModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    token = WealthyCast.toStr(json['token']);
    exchangeName = WealthyCast.toStr(json['exchange_name']);
  }
}
