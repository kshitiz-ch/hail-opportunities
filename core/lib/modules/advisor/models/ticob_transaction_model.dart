import 'package:core/modules/common/resources/wealthy_cast.dart';

class TicobTransactionModel {
  String? name;
  String? email;
  double? units;
  String? userId;
  String? amc;
  String? amcName;
  double? amount;
  String? agentName;
  String? agentExternalId;
  DateTime? postDate;
  String? panNumber;
  String? folioNumber;
  String? crn;
  List<Schemes>? schemes;

  TicobTransactionModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    email = WealthyCast.toStr(json['email']);
    units = WealthyCast.toDouble(json['units']);
    userId = WealthyCast.toStr(json['userId']);
    amc = WealthyCast.toStr(json['amc']);
    amount = WealthyCast.toDouble(json['amount']);
    agentName = WealthyCast.toStr(json['agentName']);
    agentExternalId = WealthyCast.toStr(json['agentExternalId']);
    postDate = WealthyCast.toDate(json['postDate']);
    panNumber = WealthyCast.toStr(json['panNumber']);
    folioNumber = WealthyCast.toStr(json['folioNumber']);
    amcName = WealthyCast.toStr(json['amcName']);
    crn = WealthyCast.toStr(json['crn']);
    if (json['schemes'] != null) {
      schemes = <Schemes>[];
      json['schemes'].forEach((v) {
        schemes!.add(Schemes.fromJson(v));
      });
    }
  }
}

class Schemes {
  String? schemeName;
  double? units;
  double? amount;

  Schemes.fromJson(Map<String, dynamic> json) {
    schemeName = WealthyCast.toStr(json['schemeName']);
    units = WealthyCast.toDouble(json['units']);
    amount = WealthyCast.toDouble(json['amount']);
  }
}
